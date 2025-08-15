import os, sys, time, logging
from typing import Optional, Dict, Deque
from collections import deque

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, EmailStr, constr
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, sessionmaker
from sqlalchemy import String, Integer, select, create_engine
from sqlalchemy.exc import IntegrityError, OperationalError
from pythonjsonlogger import jsonlogger

from prometheus_client import Counter, Histogram, Gauge
from prometheus_fastapi_instrumentator import Instrumentator

# -------------------- Config via env or file --------------------
def _from_file_or_env(key: str, default: str | None = None) -> str | None:
    fp = os.getenv(f"{key}_FILE")
    if fp and os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return f.read().strip()
    return os.getenv(key, default)


DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    DB_HOST = _from_file_or_env("DB_HOST")
    DB_PORT = int(_from_file_or_env("DB_PORT", "5432"))
    DB_NAME = _from_file_or_env("DB_NAME", "apidb")
    DB_USER = _from_file_or_env("DB_USER", "postgres")
    DB_PASSWORD = _from_file_or_env("DB_PASSWORD", "")
    DB_SSLMODE = _from_file_or_env("DB_SSLMODE", "require")

    if not DB_HOST or not DB_USER:
        raise RuntimeError("Set DATABASE_URL for tests or mount DB_* secrets in the pod")
    DATABASE_URL = (
        f"postgresql+psycopg://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
        f"?sslmode={DB_SSLMODE}"
    )
# basic in‑pod rate limiting (best effort)
RATE_LIMIT_RPM = int(os.getenv("RATE_LIMIT_RPM", "60"))  # requests per minute per client
MAX_BODY_BYTES = int(os.getenv("MAX_BODY_BYTES", "1048576"))  # 1MiB

# -------------------- Logging --------------------
logger = logging.getLogger("pmulani-api")
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(jsonlogger.JsonFormatter())
logger.setLevel(logging.INFO)
logger.addHandler(handler)

# -------------------- ORM --------------------
class Base(DeclarativeBase):
    pass

class Customer(Base):
    __tablename__ = "customers"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)


engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 3})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

try:
    Base.metadata.create_all(bind=engine)
except OperationalError as e:
    logger.error("db_init_failed", extra={"error": str(e)})

# -------------------- Prometheus metrics --------------------
HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total", "Total HTTP requests", ["method", "path", "status"]
)
HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "http_request_duration_seconds", "HTTP request latency (s)", ["method", "path"]
)
REQUESTS_IN_PROGRESS = Gauge(
    "http_requests_in_progress", "In-flight requests", ["method", "path"]
)
VALIDATION_FAILURES_TOTAL = Counter(
    "app_validation_failures_total", "Validation failures total"
)
RATE_LIMITED_TOTAL = Counter(
    "app_rate_limited_total", "Requests rejected by in-pod rate limiter"
)
DB_ERRORS_TOTAL = Counter(
    "app_db_errors_total", "Database operation errors"
)
DB_UP = Gauge("app_db_up", "1 if DB reachable during last check, else 0")

# -------------------- FastAPI app --------------------
app = FastAPI(title="pmulani customer API")

# Simple IP extractor (works behind ALB that sets XFF)
def client_ip(request: Request) -> str:
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()
    return request.client.host if request.client else "unknown"

# In-memory token bucket per IP (minute window)
WINDOW_SECONDS = 60
_buckets: Dict[str, Deque[float]] = {}

@app.middleware("http")
async def metered_and_limited(request: Request, call_next):
    method = request.method
    path = request.url.path

    # size guard
    cl = request.headers.get("content-length")
    if cl and int(cl) > MAX_BODY_BYTES:
        VALIDATION_FAILURES_TOTAL.inc()
        return HTTPException(status_code=413, detail="payload too large")

    # rate limit best‑effort
    now = time.time()
    ip = client_ip(request)
    q = _buckets.setdefault(ip, deque())
    # drop old timestamps
    while q and now - q[0] > WINDOW_SECONDS:
        q.popleft()
    if len(q) >= RATE_LIMIT_RPM:
        RATE_LIMITED_TOTAL.inc()
        return HTTPException(status_code=429, detail="rate limit exceeded")
    q.append(now)

    # metrics around the handler
    REQUESTS_IN_PROGRESS.labels(method, path).inc()
    start = time.time()
    try:
        response = await call_next(request)
        status = str(response.status_code)
        return response
    except Exception as e:
        status = "500"
        raise
    finally:
        duration = time.time() - start
        HTTP_REQUESTS_TOTAL.labels(method, path, status).inc()
        HTTP_REQUEST_DURATION_SECONDS.labels(method, path).observe(duration)
        REQUESTS_IN_PROGRESS.labels(method, path).dec()

# Auto expose /metrics plus default http metrics
Instrumentator().instrument(app).expose(app, include_in_schema=False, endpoint="/metrics")

# -------------------- Schemas --------------------
class CustomerCreate(BaseModel):
    name: constr(min_length=1, max_length=100)
    email: EmailStr

class CustomerUpdate(BaseModel):
    name: Optional[constr(min_length=1, max_length=100)] = None
    email: Optional[EmailStr] = None

class CustomerOut(BaseModel):
    id: int
    name: str
    email: EmailStr
    class Config:
        from_attributes = True

# -------------------- Health --------------------
@app.get("/livez")
def livez():
    # process is up; no DB check here
    return {"status": "alive"}

@app.get("/readyz")
def readyz():
    from sqlalchemy import select
    try:
        with engine.connect() as conn:
            conn.execute(select(1))
        DB_UP.set(1)
        return {"status": "ready"}
    except Exception:
        DB_UP.set(0)
        raise HTTPException(status_code=500, detail="db not ready")



# -------------------- CRUD --------------------
@app.post("/customers", response_model=CustomerOut, status_code=201)
def create_customer(payload: CustomerCreate):
    try:
        with SessionLocal() as db:
            cust = Customer(name=payload.name.strip(), email=payload.email.lower())
            db.add(cust)
            db.commit()
            db.refresh(cust)
            return cust
    except IntegrityError:
        VALIDATION_FAILURES_TOTAL.inc()
        raise HTTPException(status_code=409, detail="Email already exists")
    except Exception:
        DB_ERRORS_TOTAL.inc()
        raise

@app.get("/customers/{cid}", response_model=CustomerOut)
def get_customer(cid: int):
    with SessionLocal() as db:
        row = db.execute(select(Customer).where(Customer.id == cid)).scalar_one_or_none()
        if not row:
            raise HTTPException(status_code=404, detail="Not found")
        return row

@app.get("/customers")
def list_customers(limit: int = 50, offset: int = 0):
    limit = max(1, min(limit, 200))
    with SessionLocal() as db:
        rows = db.execute(select(Customer).offset(offset).limit(limit)).scalars().all()
        return [CustomerOut.model_validate(r) for r in rows]

@app.put("/customers/{cid}", response_model=CustomerOut)
def update_customer(cid: int, patch: CustomerUpdate):
    with SessionLocal() as db:
        obj = db.get(Customer, cid)
        if not obj:
            raise HTTPException(status_code=404, detail="Not found")
        if patch.name is not None:
            obj.name = patch.name.strip()
        if patch.email is not None:
            obj.email = patch.email.lower()
        try:
            db.commit()
            db.refresh(obj)
            return obj
        except IntegrityError:
            VALIDATION_FAILURES_TOTAL.inc()
            raise HTTPException(status_code=409, detail="Email already exists")

@app.delete("/customers/{cid}", status_code=204)
def delete_customer(cid: int):
    with SessionLocal() as db:
        obj = db.get(Customer, cid)
        if not obj:
            raise HTTPException(status_code=404, detail="Not found")
        db.delete(obj)
        db.commit()
        return {"deleted": cid}
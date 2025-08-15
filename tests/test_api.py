import os
# use in-memory sqlite so tests don't need Postgres
os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"

from fastapi.testclient import TestClient
from pmulaniapi.main import app, Base, engine
import pytest

client = TestClient(app)

@pytest.fixture(autouse=True)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield

def test_livez():
    r = client.get("/livez")
    assert r.status_code == 200
    assert r.json()["status"] == "alive"

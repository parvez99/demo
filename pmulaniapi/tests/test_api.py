# tests/test_api.py
import os
# Use an in-memory SQLite DB so tests don't need Postgres
os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"

from fastapi.testclient import TestClient
from pmulaniapi.main import app, Base, engine
import pytest

client = TestClient(app)

@pytest.fixture(autouse=True)
def reset_db():
    """Reset tables before each test."""
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield

def test_livez():
    r = client.get("/livez")
    assert r.status_code == 200
    assert r.json()["status"] == "alive"

def test_create_and_list_customer():
    payload = {"name": "Alice", "email": "alice@example.com"}
    r = client.post("/customers", json=payload)
    assert r.status_code == 201
    data = r.json()
    assert data["id"] > 0
    assert data["email"] == "alice@example.com"

    r2 = client.get("/customers")
    assert r2.status_code == 200
    emails = [c["email"] for c in r2.json()]
    assert "alice@example.com" in emails

def test_duplicate_email_conflict():
    payload = {"name": "Bob", "email": "dup@example.com"}
    assert client.post("/customers", json=payload).status_code == 201
    # same email again should 409
    assert client.post("/customers", json=payload).status_code == 409

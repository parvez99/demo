import os
os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"  # DB-less tests

from fastapi.testclient import TestClient
from pmulaniapi.main import app

client = TestClient(app)

def test_livez():
    r = client.get("/livez")
    assert r.status_code == 200
import os
os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"
from fastapi.testclient import TestClient
import main
client = TestClient(main.app)

def test_livez():
    r = client.get("/livez")
    assert r.status_code == 200

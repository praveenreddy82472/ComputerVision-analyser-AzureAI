import os
from azure.cosmos import CosmosClient
import uuid
from datetime import datetime, timezone

_client = None
_container = None

def get_container():
    global _client, _container
    if _container:
        return _container

    endpoint = os.getenv("COSMOS_ENDPOINT")
    key = os.getenv("COSMOS_KEY")
    db_name = os.getenv("COSMOS_DB_NAME", "cv_analyser")
    container_name = os.getenv("COSMOS_CONTAINER_NAME", "analyses")

    if not endpoint or not key:
        raise RuntimeError("Missing COSMOS_ENDPOINT or COSMOS_KEY")

    _client = CosmosClient(endpoint, credential=key)
    db = _client.get_database_client(db_name)
    _container = db.get_container_client(container_name)
    return _container


def upsert_analysis(item: dict) -> dict:
    c = get_container()

    # required for Cosmos + your partition key
    item.setdefault("id", str(uuid.uuid4()))
    item.setdefault("userId", "default")
    item.setdefault("createdAt", datetime.now(timezone.utc).isoformat())

    return c.upsert_item(item)



def get_analysis(item_id: str, user_id: str = "default") -> dict | None:
    c = get_container()
    try:
        return c.read_item(item=item_id, partition_key=user_id)
    except Exception:
        return None


def list_analyses(user_id: str = "default", limit: int = 20) -> list[dict]:
    c = get_container()
    query = "SELECT TOP @limit c.id, c.type, c.createdAt, c.fileName, c.blob_url FROM c WHERE c.userId=@userId ORDER BY c.createdAt DESC"
    params = [
        {"name": "@userId", "value": user_id},
        {"name": "@limit", "value": limit},
    ]
    return list(c.query_items(query=query, parameters=params, enable_cross_partition_query=True))

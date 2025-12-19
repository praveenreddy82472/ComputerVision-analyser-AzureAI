import uuid
from datetime import datetime, timezone

from azure.storage.blob import BlobServiceClient, ContentSettings

from .config import env


def upload_image_to_blob(image_bytes: bytes, content_type: str) -> dict:
    conn_str = env("AZURE_STORAGE_CONNECTION_STRING")
    container_name = env("AZURE_STORAGE_CONTAINER", "images")

    service = BlobServiceClient.from_connection_string(conn_str)
    container = service.get_container_client(container_name)

    # create container if not exists
    try:
        container.create_container()
    except Exception:
        pass

    job_id = str(uuid.uuid4())
    blob_name = f"{datetime.now(timezone.utc).strftime('%Y/%m/%d')}/{job_id}.jpg"

    blob = container.get_blob_client(blob_name)
    blob.upload_blob(
        image_bytes,
        overwrite=True,
        content_settings=ContentSettings(content_type=content_type or "image/jpeg"),
    )

    return {
        "job_id": job_id,
        "container": container_name,
        "blob_name": blob_name,
        "blob_url": blob.url,
    }

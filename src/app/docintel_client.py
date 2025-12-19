from azure.ai.documentintelligence import DocumentIntelligenceClient
from azure.core.credentials import AzureKeyCredential
from .config import env

def extract_layout_bytes(file_bytes: bytes) -> dict:
    client = DocumentIntelligenceClient(
        endpoint=env("DOCINTEL_ENDPOINT"),
        credential=AzureKeyCredential(env("DOCINTEL_KEY")),
    )

    poller = client.begin_analyze_document(
        model_id="prebuilt-layout",
        body=file_bytes,
        content_type="application/octet-stream",
    )
    result = poller.result()

    # Keep it simple: return plain text (you can expand to tables later)
    content = getattr(result, "content", None) or ""
    return {"content": content}

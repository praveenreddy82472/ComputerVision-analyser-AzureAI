import uuid
from pathlib import Path

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from datetime import datetime, timezone

from .vision_client import analyze_image_bytes
from .blob_client import upload_image_to_blob
from .openai_client import summarize_vision
from .docintel_client import extract_layout_bytes
from src.app.db.cosmos import upsert_analysis

app = FastAPI(title="CV Analyzer Backend")

BASE_DIR = Path(__file__).resolve().parent
UI_DIR = BASE_DIR / "ui"

# serve /static (js + css)
app.mount("/static", StaticFiles(directory=str(UI_DIR)), name="static")


@app.get("/health")
def health():
    return {"status": "ok"}


# UI page
@app.get("/", include_in_schema=False)
def ui_home():
    return FileResponse(str(UI_DIR / "index.html"))


# -----------------------
# IMAGE: Blob + Vision + OpenAI
# -----------------------
@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Please upload an image file.")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty file.")

    try:
        blob_info = upload_image_to_blob(image_bytes, file.content_type)
        vision = analyze_image_bytes(image_bytes)
        summary = summarize_vision(vision)

        result = {
            "id": blob_info["job_id"],  # Cosmos document id
            "userId": "default",        # Partition key value (update later if you add auth)
            "createdAt": datetime.now(timezone.utc).isoformat(),

            "job_id": blob_info["job_id"],
            "type": "image",
            "fileName": file.filename,
            "contentType": file.content_type,

            "blob_url": blob_info["blob_url"],
            "openai_summary": summary,
            "vision": vision,
            "document_intelligence": None,
        }

        # ✅ Save to Cosmos automatically
        upsert_analysis(result)

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------
# DOCUMENT: Document Intelligence (PDF)
# -----------------------
@app.post("/analyze-document")
async def analyze_document(file: UploadFile = File(...)):
    if not file.content_type or file.content_type.lower() != "application/pdf":
        raise HTTPException(status_code=400, detail="Please upload a PDF file.")

    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty file.")

    try:
        doc_result = extract_layout_bytes(data)
        job_id = str(uuid.uuid4())

        result = {
            "id": job_id,               # Cosmos document id
            "userId": "default",        # Partition key value
            "createdAt": datetime.now(timezone.utc).isoformat(),

            "job_id": job_id,
            "type": "document",
            "fileName": file.filename,
            "contentType": file.content_type,

            "blob_url": None,
            "openai_summary": None,  # later you can summarize doc_result["content"]
            "vision": None,
            "document_intelligence": doc_result,
        }

        # ✅ Save to Cosmos automatically
        upsert_analysis(result)

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

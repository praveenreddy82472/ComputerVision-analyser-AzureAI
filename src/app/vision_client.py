from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential

from .config import env


# ---------- helpers (safe, version-proof) ----------

def _get(obj: Any, attr: str, default=None):
    try:
        return getattr(obj, attr)
    except Exception:
        return default


def _bbox_to_dict(bb: Any) -> Optional[Dict[str, Any]]:
    """Normalize bounding boxes across SDK variants."""
    if not bb:
        return None
    x = _get(bb, "x", None)
    y = _get(bb, "y", None)

    w = _get(bb, "w", None)
    h = _get(bb, "h", None)
    if w is None:
        w = _get(bb, "width", None)
    if h is None:
        h = _get(bb, "height", None)

    return {"x": x, "y": y, "w": w, "h": h}


def _obj_label_and_conf(o: Any) -> Tuple[Optional[str], Optional[float]]:
    """
    In some versions, objects have o.tags[0].name/confidence.
    In others, there might be o.name / o.confidence.
    We'll support both without crashing.
    """
    # preferred: o.tags[0]
    tags = _get(o, "tags", None)
    if tags and len(tags) > 0:
        t0 = tags[0]
        return _get(t0, "name", None), _get(t0, "confidence", None)

    # fallback: direct fields if present
    return _get(o, "name", None), _get(o, "confidence", None)


def _flatten_ocr(result: Any) -> str:
    """
    READ output is structured. We'll return clean plain text.
    Handles missing blocks/lines safely.
    """
    read = _get(result, "read", None)
    blocks = _get(read, "blocks", None) if read else None
    if not blocks:
        return ""

    lines_out: List[str] = []
    for block in blocks:
        lines = _get(block, "lines", None) or []
        for line in lines:
            txt = _get(line, "text", None)
            if txt:
                lines_out.append(txt)

    return "\n".join(lines_out)


# ---------- main function ----------

def analyze_image_bytes(image_bytes: bytes) -> dict:
    endpoint = env("AZURE_VISION_ENDPOINT")  # https://<name>.cognitiveservices.azure.com/
    key = env("AZURE_VISION_KEY")

    client = ImageAnalysisClient(
        endpoint=endpoint,
        credential=AzureKeyCredential(key),
    )

    result = client.analyze(
        image_data=image_bytes,
        visual_features=[
            VisualFeatures.CAPTION,
            VisualFeatures.TAGS,
            VisualFeatures.OBJECTS,
            VisualFeatures.READ,     # OCR
            VisualFeatures.PEOPLE,
        ],
        gender_neutral_caption=True,
    )

    # caption
    caption_obj = _get(result, "caption", None)
    caption_text = _get(caption_obj, "text", None) if caption_obj else None
    caption_conf = _get(caption_obj, "confidence", None) if caption_obj else None

    # tags
    tags_obj = _get(result, "tags", None)
    tags_list = _get(tags_obj, "list", None) if tags_obj else None
    tags_out = []
    if tags_list:
        for t in tags_list:
            tags_out.append(
                {"name": _get(t, "name", None), "confidence": _get(t, "confidence", None)}
            )

    # objects
    objects_obj = _get(result, "objects", None)
    objects_list = _get(objects_obj, "list", None) if objects_obj else None
    objects_out = []
    if objects_list:
        for o in objects_list:
            name, conf = _obj_label_and_conf(o)
            bb = _get(o, "bounding_box", None)
            objects_out.append(
                {"name": name, "confidence": conf, "bbox": _bbox_to_dict(bb)}
            )

    # people
    people_obj = _get(result, "people", None)
    people_list = _get(people_obj, "list", None) if people_obj else None
    people_out = []
    if people_list:
        for p in people_list:
            bb = _get(p, "bounding_box", None)
            people_out.append(
                {"confidence": _get(p, "confidence", None), "bbox": _bbox_to_dict(bb)}
            )

    return {
        "caption": caption_text,
        "caption_confidence": caption_conf,
        "tags": tags_out,
        "objects": objects_out,
        "people": people_out,
        "ocr_text": _flatten_ocr(result),
    }

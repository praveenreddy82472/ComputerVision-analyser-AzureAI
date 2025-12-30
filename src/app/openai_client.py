from openai import AzureOpenAI
from .config import env

def summarize_vision(vision: dict) -> str:
    client = AzureOpenAI(
        api_key=env("AZURE_OPENAI_API_KEY"),
        azure_endpoint=env("AZURE_OPENAI_ENDPOINT"),
        api_version=env("AZURE_OPENAI_API_VERSION", "2024-12-01-preview"),
    )

    deployment = env("AZURE_OPENAI_DEPLOYMENT")

    caption = vision.get("caption") or ""
    tags = [t.get("name") for t in (vision.get("tags") or []) if t.get("name")]
    objects = [o.get("name") for o in (vision.get("objects") or []) if o.get("name")]
    ocr = vision.get("ocr_text") or ""

    prompt = f"""
You are an assistant that writes a 200 words short, factual summary of an image using ONLY the extracted signals below.
If OCR text exists, mention it. If not, don't invent text.

CAPTION: {caption}
TAGS: {", ".join(tags[:20])}
OBJECTS: {", ".join(objects[:20])}
OCR TEXT:
{ocr[:2000]}
""".strip()

    resp = client.chat.completions.create(
        model=deployment,
        messages=[
            {"role": "system", "content": "Return a concise summary in 2-4 sentences. No guessing."},
            {"role": "user", "content": prompt},
        ],
        temperature=0.2,
        max_tokens=200,
    )

    return resp.choices[0].message.content.strip()

import os
from dotenv import load_dotenv

load_dotenv()  # loads .env if present

def env(name: str, default: str | None = None) -> str:
    v = os.getenv(name, default)
    if v is None or v.strip() == "":
        raise RuntimeError(f"Missing env var: {name}")
    return v

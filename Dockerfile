# ---- Base image ----
FROM python:3.11-slim

# ---- System settings ----
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Optional but helpful for some Python deps
RUN pip install --no-cache-dir --upgrade pip

# ---- Install deps first (better caching) ----
# Expect requirements.txt at repo root
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# ---- Copy app code ----
COPY . /app

# Container Apps will route to this port via ingress targetPort later
EXPOSE 8000

# ---- Start FastAPI ----
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8000"]

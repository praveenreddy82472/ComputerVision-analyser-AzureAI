const fileInput = document.getElementById("file");
const analyzeBtn = document.getElementById("analyzeBtn");
const statusEl = document.getElementById("status");

const previewArea = document.getElementById("previewArea");
const metaType = document.getElementById("metaType");
const metaJob = document.getElementById("metaJob");
const metaBlob = document.getElementById("metaBlob");

const summaryEl = document.getElementById("summary");
const visionEl = document.getElementById("vision");
const docEl = document.getElementById("document");
const rawEl = document.getElementById("raw");

let selectedFile = null;

function setStatus(text) {
  statusEl.textContent = text;
}

function setMeta({ type, job_id, blob_url }) {
  metaType.textContent = type || "-";
  metaJob.textContent = job_id || "-";

  if (blob_url) {
    metaBlob.textContent = blob_url;
    metaBlob.href = blob_url;
  } else {
    metaBlob.textContent = "-";
    metaBlob.href = "#";
  }
}

function clearOutputs() {
  summaryEl.textContent = "No result yet.";
  visionEl.textContent = "No vision result yet.";
  docEl.textContent = "No document result yet.";
  rawEl.textContent = "No result yet.";
}

function showImagePreview(file) {
  const url = URL.createObjectURL(file);
  previewArea.innerHTML = `<img alt="preview" src="${url}" />`;
}

function showPdfPreview(file) {
  previewArea.innerHTML = `<div class="muted">PDF selected: <b>${file.name}</b></div>`;
}

fileInput.addEventListener("change", () => {
  selectedFile = fileInput.files?.[0] || null;
  clearOutputs();
  setMeta({ type: "-", job_id: "-", blob_url: null });

  if (!selectedFile) {
    previewArea.innerHTML = `<div class="muted">Choose a file to preview it.</div>`;
    return;
  }

  if (selectedFile.type.startsWith("image/")) showImagePreview(selectedFile);
  else if (selectedFile.type === "application/pdf") showPdfPreview(selectedFile);
  else previewArea.innerHTML = `<div class="muted">Unsupported file type: ${selectedFile.type}</div>`;
});

function setActiveTab(tabName) {
  document.querySelectorAll(".tab").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.tab === tabName);
  });
  document.querySelectorAll(".pane").forEach(pane => pane.classList.remove("active"));
  document.getElementById(`pane-${tabName}`).classList.add("active");
}

document.querySelectorAll(".tab").forEach(btn => {
  btn.addEventListener("click", () => setActiveTab(btn.dataset.tab));
});

analyzeBtn.addEventListener("click", async () => {
  if (!selectedFile) {
    setStatus("Pick a file first.");
    return;
  }

  if (!(selectedFile.type.startsWith("image/") || selectedFile.type === "application/pdf")) {
    setStatus(`Unsupported file type: ${selectedFile.type}`);
    return;
  }

  analyzeBtn.disabled = true;
  setStatus("Uploading + analyzing...");
  clearOutputs();

  try {
    const form = new FormData();
    form.append("file", selectedFile);

    const endpoint = selectedFile.type.startsWith("image/")
      ? "/analyze"
      : "/analyze-document";

    const res = await fetch(endpoint, { method: "POST", body: form });
    const data = await res.json();

    if (!res.ok) {
      throw new Error(data?.detail || `Request failed: ${res.status}`);
    }

    setStatus("Done.");
    setMeta(data);

    // Summary tab
    summaryEl.textContent = data.openai_summary || "(No OpenAI summary for this file type yet.)";

    // Vision tab
    if (data.vision) {
      const v = data.vision;
      const tagNames = (v.tags || []).slice(0, 20).map(t => `${t.name} (${(t.confidence ?? 0).toFixed(3)})`);
      const objNames = (v.objects || []).slice(0, 20).map(o => `${o.name} (${(o.confidence ?? 0).toFixed(3)})`);

      visionEl.textContent =
        `Caption: ${v.caption || "-"}\n` +
        `Caption confidence: ${v.caption_confidence ?? "-"}\n\n` +
        `Tags:\n- ${tagNames.join("\n- ") || "(none)"}\n\n` +
        `Objects:\n- ${objNames.join("\n- ") || "(none)"}\n\n` +
        `OCR:\n${v.ocr_text || "(none)"}`;
    } else {
      visionEl.textContent = "No vision output for this file.";
    }

    // Document tab
    if (data.document_intelligence) {
      // your docintel returns {"content": "..."}
      docEl.textContent = data.document_intelligence.content || JSON.stringify(data.document_intelligence, null, 2);
    } else {
      docEl.textContent = "No document output for this file.";
    }

    // Raw JSON tab
    rawEl.textContent = JSON.stringify(data, null, 2);
    setActiveTab("summary");
  } catch (err) {
    setStatus(`Error: ${err.message}`);
  } finally {
    analyzeBtn.disabled = false;
  }
});

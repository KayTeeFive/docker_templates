#!/usr/bin/env bash
set -euo pipefail

MODEL="${MODEL:?MODEL env var is required}"
#HOST="${HOST:-127.0.0.1:11434}"
HOST="127.0.0.1:11434"  # It's always 127.0.0.1:11434 in docker env

echo "[INFO] Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

cleanup() {
  echo "[INFO] Stopping Ollama (PID $OLLAMA_PID)..."
  kill "$OLLAMA_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "[INFO] Waiting for Ollama API to become ready..."

# Check Ollama start
#until curl -sf "http://$HOST/api/tags" >/dev/null; do
#  sleep 0.5
#done

sleep 5

echo "[INFO] Ollama is ready"

# Check model to exist
if ollama list | awk '{print $1}' | grep -qx "$MODEL"; then
  echo "[INFO] Model '$MODEL' already present — skipping pull"
else
  echo "[INFO] Pulling model '$MODEL'..."
  ollama pull "$MODEL"
  echo "[INFO] Model pulled"
fi

echo "[INFO] Ollama running (PID $OLLAMA_PID)"
wait "$OLLAMA_PID"

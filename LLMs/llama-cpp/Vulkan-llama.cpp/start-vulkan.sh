#!/bin/bash
# Usage:
#   ./start-vulkan.sh          — default log verbosity (3 = info)
#   ./start-vulkan.sh -v       — verbosity 4 (trace)
#   ./start-vulkan.sh -d       — verbosity 5 (debug)
#   ./start-vulkan.sh -vv      — --log-verbose (all messages, ∞)
#   ./start-vulkan.sh -vvv     — --log-verbose (same as -vv)

# ── Parse CLI arguments ───────────────────────────────────────────────────────
_VERBOSITY_LEVEL=3
_LOG_VERBOSE=0

for _arg in "$@"; do
    case "$_arg" in
        -d)
            _VERBOSITY_LEVEL=5
            ;;
        -v*)
            _vcount=$(printf '%s' "$_arg" | tr -cd 'v' | wc -c)
            if [ "$_vcount" -ge 2 ]; then
                _LOG_VERBOSE=1
            else
                _VERBOSITY_LEVEL=4
            fi
            ;;
    esac
done

#if [[ ! -f .env ]]; then
#    cp -vf env-file.template .env
#fi
cp -vf env-file.template .env

echo "Updating .env file..."
sed -e "s|/home/dockeruser|${HOME}|g" -i .env

export $(grep -v '^#' .env | xargs)

# ── Set log verbosity flag (overrides anything from .env) ─────────────────────
if [ "$_LOG_VERBOSE" -eq 1 ]; then
    export LLAMA_LOG_VERBOSITY_FLAG="--log-verbose"
else
    export LLAMA_LOG_VERBOSITY_FLAG="--log-verbosity ${_VERBOSITY_LEVEL}"
fi

echo "Launching OLLAMA AI..."
echo "OLLAMA MODEL: ${LLAMA_MODEL}"
echo "OLLAMA MODELS PATH: ${LLAMA_MODELS_DIR}"
echo "OLLAMA DATA PATH: ${LLAMA_CACHE_DIR}"
echo "Open-WEBUI DATA PATH: ${WEBUI_DATA}"

if [[ ! -d ${LLAMA_MODELS_DIR} ]]; then
    echo "OLLAMA models path ${LLAMA_MODELS_DIR} not found. Creating..."
    mkdir -p ${LLAMA_MODELS_DIR}
fi

if [[ ! -d ${LLAMA_CACHE_DIR} ]]; then
    echo "OLLAMA cache path ${LLAMA_CACHE_DIR} not found. Creating..."
    mkdir -p ${LLAMA_CACHE_DIR}
fi

if [[ ! -d ${WEBUI_DATA} ]]; then
    echo "Open-WEBUI data path ${WEBUI_DATA} not found. Creating..."
    mkdir -p ${WEBUI_DATA}
fi

echo "Starting service on http://${HOST_IP}:${HOST_PORT}..."

docker container rm '/llama-open-webui'
docker rm llama-vulkan-llm
docker rm open-webui

docker compose -f docker-compose-vulkan.yml up

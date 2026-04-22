#!/bin/bash

#if [[ ! -f .env ]]; then
#    cp -vf env-file.template .env
#fi
cp -vf env-file.template .env

echo "Updating .env file..."
sed -e "s|/home/dockeruser|${HOME}|g" -i .env

export $(grep -v '^#' .env | xargs)


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
docker rm llama-sycl-llm
docker rm open-webui

docker compose -f docker-compose-sycl.yml up

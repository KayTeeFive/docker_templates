#!/bin/bash

cp -vf env-file.template .env

echo "Updating .env file..."
sed -e "s|/home/dockeruser|${HOME}|g" -i .env

export $(grep -v '^#' .env | xargs)


echo "Launching OLLAMA AI..."
echo "OLLAMA MODEL: ${OLLAMA_LLM_MODEL}"
echo "OLLAMA DATA PATH: ${OLLAMA_DATA}"
echo "Open-WEBUI DATA PATH: ${WEBUI_DATA}"

if [[ ! -d ${OLLAMA_DATA} ]]; then
    echo "OLLAMA data path ${OLLAMA_DATA} not found. Creating..."
    mkdir -p ${OLLAMA_DATA}
fi

if [[ ! -d ${WEBUI_DATA} ]]; then
    echo "Open-WEBUI data path ${WEBUI_DATA} not found. Creating..."
    mkdir -p ${WEBUI_DATA}
fi

echo "Starting service on http://${HOST_IP}:${HOST_PORT}..."

docker rm ollama-llm-model
docker rm ollama-open-webui

docker compose -f docker-compose-vulkan.yml up

#!/bin/bash

cp -vf env-file.template .env

echo "Updating .env file..."
sed -e "s|/home/dockeruser|${HOME}|g" -i .env

export $(grep -v '^#' .env | xargs)


echo "Launching OLLAMA AI..."
echo "OLLAMA LLM MODEL: ${OLLAMA_LLM_MODEL}"
echo "OLLAMA EMBED MODEL: ${OLLAMA_EMBED_MODEL}"
echo "OLLAMA DATA PATH: ${OLLAMA_DATA}"
echo "QDRANT DATA PATH: ${QDRANT_DATA}"
echo "Anythingllm DATA PATH: ${ANYLLM_DATA}"


if [[ ! -d ${OLLAMA_DATA} ]]; then
    echo "OLLAMA data path ${OLLAMA_DATA} not found. Creating..."
    mkdir -p ${OLLAMA_DATA}
fi

if [[ ! -d ${QDRANT_DATA} ]]; then
    echo "Qdrant data path ${QDRANT_DATA} not found. Creating..."
    mkdir -p ${QDRANT_DATA}
fi

if [[ ! -d ${ANYLLM_DATA} ]]; then
    echo "Anythingllm data path ${ANYLLM_DATA} not found. Creating..."
    mkdir -p ${ANYLLM_DATA}/storage
    touch "${ANYLLM_DATA}/.env"
fi

echo "Starting service on http://${HOST_IP}:${HOST_PORT}..."

docker rm ollama-rag-llm-model
docker rm ollama-rag-embed-model
docker rm ollama-rag-qdrant
docker rm ollama-rag-anythingllm

docker compose -f docker-compose-rag-vulkan.yml up

# Run LLaMa by Ollama
## General commands

```commandline
docker compose build   
docker compose up
docker compose stop 
docker compose rm
```

### Simple LLM start (using web: Open-WebUI)
Just run script: `./start.sh`

### RAG Launching (using web: Anything LLM)

For RAG you need run `./start-rag.sh`

RAG contains:
- ollama docker for inference 
- ollama docker for embedding
- qdrant docker vector database
- AnythingLLM docker vector database

### Scripts
- `start.sh` - start Ollama with Open-WebUI
- `start-rag.sh` - start RAG on CPU
- `start-rag-ipex-llm.sh` - start RAG for Intel Arc GPUs using IPEX/SYCL LLM toolkit 
- `start-rag-rocm.sh` - start RAG for AMD GPUs using ROCm toolkit
- `start-rag-vulkan.sh` - universal Vulkan API for launching LLMs on AMD, Intel , nVidia GPUs


# LLM tips

## Default system prompt

### AnythingLLM

For AnythingLLM recommended default system prompt:
```
You are a helpful, knowledgeable AI assistant.
Answer questions concisely and factually.
Always cite sources when available.
Use retrieved documents if necessary.

Always respond in the same language as the user's latest message.
Do not change the response language unless the user explicitly asks to.

Never respond in Russian.
If the user's message is in Russian, respond in Ukrainian or English instead.
```

## Deterministic model
### Setup temperature to zero
#### AnythingLLM
`Workspace settings > Chat Settings > LLM Temperature: 0`

#### LM Studio
- Enable Developer mode
- Change settings in Chat > Sidebar > Settings > Temperatire: 0
- `optionally` save new settings as new preset

In `My Models` tab, you can also tune model settings.

### Create deterministic model
- create `gpt-oss.modelfile`:
    ```
    FROM gpt-oss:20b
    PARAMETER temperature 0
    PARAMETER top_k 1
    PARAMETER top_p 1
    PARAMETER repeat_penalty 1.1
    ```
- create new model from main LLM model:
    ```
    ollama create gpt-oss:20b-deterministic -f ./gpt-oss.modelfile
    ```
- now you have tuned deterministic model

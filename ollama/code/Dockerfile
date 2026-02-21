FROM ollama/ollama:latest

WORKDIR /home

COPY ./entrypoint.sh ./entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/bash", "/home/entrypoint.sh"]
FROM debian:trixie

RUN apt-get update && apt-get install -y \
    curl ca-certificates git bash \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code (official way)
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /workspace
ENTRYPOINT ["claude"]

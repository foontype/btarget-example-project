FROM ubuntu

ARG CONTAINER_UID
ARG CONTAINER_GID

RUN apt-get update \
 && apt-get install -y \
        sudo \
        git \
        curl \
        jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# init container
ADD run/devcontainer/init-container /init-container

# init container: vscode local terminal
ENV INIT_CONTAINER_VSCODE_LOCAL_TERMINAL=1

# init container: workspace
ENV INIT_CONTAINER_WORKSPACE=1

# init container: npm
ENV INIT_CONTAINER_NPM=1
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*
RUN node -v && npm -v

# init container: python
ENV INIT_CONTAINER_PYTHON=1
ENV PYTHONPYCACHEPREFIX="/workspace/run/devcontainer/.pycache"
RUN apt-get update \
 && apt-get install -y \
        python3 \
        python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/python3 /usr/bin/python

# init container: uv
ENV INIT_CONTAINER_UV=1
ENV UV_INSTALL_DIR="/workspace/run/devcontainer/.uv"
ENV PATH="${UV_INSTALL_DIR}:${PATH}"

# init container: claude code
ENV INIT_CONTAINER_CLAUDE_CODE=1
ENV CLAUDE_CONFIG_DIR="/workspace/run/devcontainer/.claude"
RUN npm config set os linux
RUN npm install -g @anthropic-ai/claude-code

# container user
ENV CONTAINER_USER="${CONTAINER_UID}:${CONTAINER_GID}"
ENV CONTAINER_UID="${CONTAINER_UID}"
ENV CONTAINER_GID="${CONTAINER_GID}"
RUN if [ ! "${CONTAINER_UID}:${CONTAINER_GID}" = "0:0" ]; then \
        deluser ubuntu \
        && addgroup --gid ${CONTAINER_GID} nonroot \
        && adduser --uid ${CONTAINER_UID} --gid ${CONTAINER_GID} --disabled-password nonroot \
        && echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers; \
    fi

USER ${CONTAINER_UID}:${CONTAINER_GID}

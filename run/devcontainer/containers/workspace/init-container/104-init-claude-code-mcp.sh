#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_CLAUDE_CODE}" -a -n "${INIT_CONTAINER_UV}" ]; then
    # https://www.claudemcp.com/servers

    # mcp-server-fetch
    claude mcp add mcp-server-fetch \
        -- uvx mcp-server-fetch

    # mcp-shell-server
    claude mcp add mcp-shell-sever \
        -e ALLOW_COMMANDS="${MCP_SHELL_SERVER_ALLOW_COMMANDS:-ls,cat,pwd,grep,wc,touch,find}" \
        -- uvx mcp-shell-server

    # git
    claude mcp add mcp-server-git \
        -- uvx mcp-server-git --repository /workspace

    # memory
    claude mcp add memory \
        -- npx -y @modelcontextprotocol/server-memory
fi

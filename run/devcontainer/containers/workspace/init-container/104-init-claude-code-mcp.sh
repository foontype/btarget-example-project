#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_CLAUDE_CODE}" -a -n "${INIT_CONTAINER_UV}" ]; then
    # https://www.claudemcp.com/servers
    # example) claude mcp add mcp-server-fetch uvx mcp-server-fetch
    claude mcp add mcp-server-fetch uvx mcp-server-fetch
fi

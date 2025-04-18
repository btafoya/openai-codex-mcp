# openai-codex-mcp

An MCP server to wrap the OpenAI Codex CLI tool for use with Claude Code.

## Overview

This project provides a simple JSON-RPC server that allows Claude Code to interact with the OpenAI Codex CLI tool. This enables Claude Code to use OpenAI's models for code generation, explanation, and problem-solving when needed.

## Prerequisites

- Python 3.12+
- OpenAI Codex CLI tool (`npm install -g @openai/codex`)
- Valid OpenAI API key (for the Codex CLI, not for this server)

## Installation and Setup

This project uses a PEP‑621 `pyproject.toml`. Follow these steps:

```bash
# 1. Create & activate a venv
uv venv                     # creates a .venv/ directory
source .venv/bin/activate   # on Windows: .\.venv\Scripts\activate

# 2. Install package and dependencies into the venv
uv pip install .
```

After installation, the `codex_server` entrypoint is available in your PATH.

## Running the Server

1. Make sure the Codex CLI is installed and properly configured with your OpenAI API key
2. Start the server:
   ```bash
   codex_server
   ```
   *Alternatively, use uvicorn directly:* `uvicorn codex_server:app`

## Integrating with Claude Code

Once your MCP server is running, register it in Claude Code so that tasks can be routed through Codex:

1. In Claude Code, navigate to **Settings → Tools → Manage MCP Tools**.
2. Create a new tool with:
   - **Name**: `openai_codex`
   - **Description**: `OpenAI Codex CLI integration via MCP server`
   - **Base URL**: `http://localhost:8000/`
   - **Protocol**: `JSON-RPC 2.0`
   - **Authentication**: _leave blank_
3. Save the tool.

Now, Claude Code can use the OpenAI Codex CLI tool for tasks where a different perspective or approach is desired. You can invoke it by asking Claude to use the OpenAI models for a particular task.

## API Usage

For low-level debugging or direct testing, you can POST a raw JSON–RPC request:

```bash
curl -X POST http://localhost:8000/ \
     -H 'Content-Type: application/json' \
     -d '{
       "jsonrpc": "2.0",
       "method": "codex_completion",
       "params": {
         "prompt": "Write a JavaScript function to sort an array of objects by a property value",
         "model": "o4-mini"
       },
       "id": 1
     }'
```

### Available Parameters

- `prompt` (required): The prompt to send to Codex
- `model` (optional): The model to use (e.g., "o4-mini", "o4-preview")
- `images` (optional): List of image paths or data URIs to include
- `additional_args` (optional): Additional CLI arguments to pass to Codex

## Example Usage with Claude Code

Once configured, you can ask Claude to use OpenAI Codex for specific tasks:

```
User: Can you use OpenAI Codex to write a Python function that generates prime numbers?

Claude: I'll use OpenAI Codex to write that function for you.

[Claude would then use the MCP server to send the request to Codex and return the results]
```

This allows you to leverage both Claude and OpenAI's capabilities seamlessly within the same interface.
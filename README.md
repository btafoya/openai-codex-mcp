# openai-codex-mcp
An MCP server to wrap the OpenAI Codex API for use with Claude Code.

## Installation and Setup

Requires Python 3.7+.

This project uses a PEP‑621 `pyproject.toml`. We recommend using the `uv` CLI to create and manage a virtual environment and install:

```bash
# 1. Create & activate a venv
uv venv                     # creates a .venv/ directory
source .venv/bin/activate   # on Windows: .\.venv\Scripts\activate

# 2. Install package and dependencies
uv pip install .
```
After installation, the `codex_server` entrypoint is available in your PATH.

## Running the Server

1. Ensure your venv is active and set your API key:
   ```bash
   export OPENAI_API_KEY="your_openai_api_key"
   ```
2. Start the server (reads `[tool.uvicorn]` from `pyproject.toml`):
   ```bash
   uv
   ```
   *Alternatively, launch directly via the console script:* `codex_server`

## Integrating with Claude Code

Once your MCP server is running, register it in Claude Code so that tasks can automatically route through Codex:

1. In Claude Code, navigate to **Settings → Tools → Manage MCP Tools**.
2. Create a new tool with:
   - **Name**: `openai_codex`
   - **Description**: `OpenAI Codex completion via MCP server`
   - **Base URL**: `http://localhost:8000/`
   - **Protocol**: `JSON-RPC 2.0`
   - **Authentication**: _leave blank_
3. Save the tool.

Now, whenever you ask Claude Code to generate or complete code, it will transparently invoke your `openai_codex` tool (choosing model, prompt, etc., based on your prompt context). You do not need to manually craft JSON–RPC requests.

> For low-level debugging or direct testing, you can still POST a raw JSON–RPC request:
> ```bash
> curl -X POST http://localhost:8000/ \
>      -H 'Content-Type: application/json' \
>      -d '{"jsonrpc":"2.0","method":"complete","params":{"model":"o4-mini","prompt":"print(\"Hello, world!\")","max_tokens":64},"id":1}'
> ```

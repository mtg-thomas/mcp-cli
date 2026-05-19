---
name: mcp-cli
description: Use the mcp-cli command line interface to discover and call MCP (Model Context Protocol) server tools from shell-driven agents. Use when an agent needs MCP-backed access to external tools, APIs, filesystems, databases, GitHub, or other configured MCP servers, especially when direct MCP tools are unavailable or when schema discovery should happen on demand.
---

# MCP-CLI

Access MCP servers through the command line. Prefer `mcp-cli` whenever MCP-backed tools are needed and the executable is available on `PATH`.

Start with discovery. Do not guess tool arguments when `info` can show the schema.

```bash
mcp-cli --version
mcp-cli info
mcp-cli grep "*file*"
mcp-cli info filesystem read_file
```

## Commands

| Command | Output |
|---------|--------|
| `mcp-cli` | List all servers and tools |
| `mcp-cli info <server>` | Show server tools and parameters |
| `mcp-cli info <server> <tool>` | Get tool JSON schema |
| `mcp-cli grep "<pattern>"` | Search tools by name |
| `mcp-cli call <server> <tool>` | Call tool (reads JSON from stdin if no args) |
| `mcp-cli call <server> <tool> '<json>'` | Call tool with arguments |

**Both formats work:** `<server> <tool>` or `<server>/<tool>`

## Workflow

1. **Check availability**: `mcp-cli --version`
2. **Discover**: `mcp-cli info` or `mcp-cli` to see available servers
3. **Search**: `mcp-cli grep "<pattern>"` to find likely tools
4. **Inspect**: `mcp-cli info <server> <tool>` to get the full JSON schema
5. **Execute**: `mcp-cli call <server> <tool> '<json>'` with the smallest needed arguments
6. **Report evidence**: include the command result or relevant output summary in your answer

Use `-c <path>` when the repository or task provides a specific MCP config file.

## Examples

```bash
# List all servers
mcp-cli

# With descriptions  
mcp-cli -d

# See server tools
mcp-cli info filesystem

# Get tool schema (both formats work)
mcp-cli info filesystem read_file
mcp-cli info filesystem/read_file

# Call tool
mcp-cli call filesystem read_file '{"path": "./README.md"}'

# Pipe from stdin (no '-' needed!)
cat args.json | mcp-cli call filesystem read_file

# Search for tools
mcp-cli grep "*file*"

# Output is raw text (pipe-friendly)
mcp-cli call filesystem read_file '{"path": "./file"}' | head -10
```

### PowerShell JSON

PowerShell quoting is easiest with stdin for nested JSON:

```powershell
'{"path":"./README.md"}' | mcp-cli call filesystem read_file
@'
{"query":"mcp server","per_page":5}
'@ | mcp-cli call github search_repositories
```

## Advanced Chaining

```bash
# Chain: search files → read first match
mcp-cli call filesystem search_files '{"path": ".", "pattern": "*.md"}' \
  | head -1 \
  | xargs -I {} mcp-cli call filesystem read_file '{"path": "{}"}'

# Loop: process multiple files
mcp-cli call filesystem list_directory '{"path": "./src"}' \
  | while read f; do mcp-cli call filesystem read_file "{\"path\": \"$f\"}"; done

# Conditional: check before reading
mcp-cli call filesystem list_directory '{"path": "."}' \
  | grep -q "README" \
  && mcp-cli call filesystem read_file '{"path": "./README.md"}'

# Multi-server aggregation
{
  mcp-cli call github search_repositories '{"query": "mcp", "per_page": 3}'
  mcp-cli call filesystem list_directory '{"path": "."}'
}

# Save to file
mcp-cli call github get_file_contents '{"owner": "x", "repo": "y", "path": "z"}' > output.txt
```

**Note:** `call` outputs raw text content directly (no jq needed for text extraction)

## Options

| Flag | Purpose |
|------|---------|
| `-d` | Include descriptions |
| `-c <path>` | Specify config file |

## Guardrails

- Inspect schemas with `mcp-cli info <server> <tool>` before first use of a tool.
- Treat destructive MCP tools like any other mutating shell command: only call them when the user asked for that action or the task clearly requires it.
- Keep secret values out of chat. Report presence, shape, status, or redacted evidence instead.
- Prefer stdin JSON for complex arguments, especially in PowerShell.
- If daemon caching looks stale, retry with `MCP_NO_DAEMON=1` after checking whether a fresh connection is safe.

## Common Errors

| Wrong Command | Error | Fix |
|---------------|-------|-----|
| `mcp-cli server tool` | AMBIGUOUS_COMMAND | Use `call server tool` or `info server tool` |
| `mcp-cli run server tool` | UNKNOWN_SUBCOMMAND | Use `call` instead of `run` |
| `mcp-cli list` | UNKNOWN_SUBCOMMAND | Use `info` instead of `list` |
| `mcp-cli call server` | MISSING_ARGUMENT | Add tool name |
| `mcp-cli call server tool {bad}` | INVALID_JSON | Use valid JSON with quotes |

## Exit Codes

- `0`: Success
- `1`: Client error (bad args, missing config)
- `2`: Server error (tool failed)
- `3`: Network error

# Contributing

This fork is maintained as the MTG operator-ready fork of `mcp-cli`.

## Development Setup

Install dependencies with the locked Bun manifest:

```bash
bun install --frozen-lockfile
```

## Required Local Checks

Run these before opening a pull request:

```bash
bun run typecheck
bun run lint
bun test --timeout 60000 tests/config.test.ts tests/output.test.ts tests/client.test.ts tests/errors.test.ts tests/filter.test.ts tests/grep.test.ts tests/cli-errors.test.ts
bun test --timeout 60000 tests/integration/
bun run build:all
```

## Pull Request Expectations

- Keep changes narrowly scoped and describe user-visible behavior.
- Include Windows impact when touching paths, process spawning, daemon IPC, or shell commands.
- Do not commit real MCP server credentials, tokens, customer data, or local-only config.
- Update `README.md`, `SKILL.md`, or release notes when behavior changes.

## Release Expectations

Releases are tag-driven from `main` through `.github/workflows/release.yml`.
Use `./scripts/release.sh X.Y.Z` after CI is green and the release scope is
reviewed. Release artifacts should include Linux x64, Linux ARM64, macOS x64,
macOS ARM64, Windows x64, and `checksums.txt`.

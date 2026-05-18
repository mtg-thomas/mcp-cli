# Security Policy

## Supported Versions

Security fixes are applied to the current `main` branch. Releases are cut from tags after CI and release-build checks pass.

## Reporting a Vulnerability

Please report suspected vulnerabilities privately to the maintainers before opening public issues. Include:

- affected version or commit;
- operating system and installation method;
- minimal reproduction steps;
- expected impact;
- any relevant logs with secrets removed.

Do not include tokens, API keys, private MCP server payloads, or customer data in reports.

## Security Baseline

This project is expected to keep:

- locked dependency installs in CI and release workflows;
- GitHub Actions with least-privilege permissions;
- CodeQL or equivalent static analysis enabled;
- dependency and GitHub Actions update PRs through Dependabot;
- cross-platform CI for Linux and Windows before release.

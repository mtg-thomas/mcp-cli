# Repo Hardening Posture

This document tracks the repository maturity baseline for the MTG fork.

## Current Baseline

- CI runs on `ubuntu-latest` and `windows-latest`.
- CI gates typecheck, lint, unit tests, integration tests, and release-target build smoke.
- Workflows use locked dependency installation with `bun install --frozen-lockfile`.
- GitHub Actions permissions default to `contents: read`; release creation is the only job with `contents: write`.
- Dependabot is configured for npm and GitHub Actions updates.
- Security reporting expectations live in `SECURITY.md`.
- PR expectations live in `.github/pull_request_template.md` and `CONTRIBUTING.md`.
- Code ownership is declared in `.github/CODEOWNERS`.
- Release artifacts cover Linux x64, Linux ARM64, macOS x64, macOS ARM64, and Windows x64 with SHA-256 checksums.

## Recommended Required Checks

Configure branch protection or a ruleset for `main` to require:

- `Lint (ubuntu-latest)`
- `Lint (windows-latest)`
- `Test (ubuntu-latest)`
- `Test (windows-latest)`
- `Build smoke`
- CodeQL JavaScript/TypeScript analysis, when enabled on the repository

Require pull requests before merge, stale review dismissal after new commits,
and linear history or squash merge according to the repo's preferred merge
style.

## Remaining Admin Tasks

These settings are repository-admin work rather than tracked-code changes:

- Enable or confirm GitHub secret scanning and push protection.
- Enable or confirm Dependabot security updates.
- Enable or confirm CodeQL default setup for JavaScript/TypeScript.
- Apply the required-check ruleset for `main`.
- Decide whether this fork publishes npm packages or only GitHub release binaries.

## Release Guardrails

- Cut releases only from `main` after CI is green.
- Use annotated `vX.Y.Z` tags.
- Do not publish artifacts that were built outside the release workflow unless an incident note explains why.
- Verify `checksums.txt` is included with every binary release.

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
skills_root="${CODEX_HOME:-"$HOME/.codex"}/skills"
skill_name="${1:-mcp-cli}"
target_dir="$skills_root/$skill_name"

mkdir -p "$target_dir"
cp "$repo_root/SKILL.md" "$target_dir/SKILL.md"

printf 'Installed mcp-cli skill to %s\n' "$target_dir/SKILL.md"

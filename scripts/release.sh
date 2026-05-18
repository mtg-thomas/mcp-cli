#!/bin/bash
# Release script for mcp-cli
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 0.1.0"
    exit 1
fi

VERSION=$1
BUN_BIN=${BUN_BIN:-bun}

if ! command -v "$BUN_BIN" &> /dev/null; then
    if command -v bun.exe &> /dev/null; then
        BUN_BIN=bun.exe
    elif [ -n "${USERPROFILE:-}" ]; then
        USER_BUN="$USERPROFILE/.bun/bin/bun.exe"
        if command -v cygpath &> /dev/null; then
            USER_BUN=$(cygpath -u "$USER_BUN")
        fi
        if [ -x "$USER_BUN" ]; then
            BUN_BIN=$USER_BUN
        fi
    fi
fi

if ! command -v "$BUN_BIN" &> /dev/null && [ ! -x "$BUN_BIN" ]; then
    echo -e "${RED}Error: Bun executable not found${NC}"
    echo "Install Bun or set BUN_BIN to the Bun executable path."
    exit 1
fi

# Validate version format (semver)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Version must be in format: X.Y.Z (e.g., 0.1.0)"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}Warning: Not on main branch (current: $CURRENT_BRANCH)${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: Uncommitted changes detected${NC}"
    echo "Please commit or stash your changes first."
    exit 1
fi

# Check if tag already exists
if git tag -l "v$VERSION" | grep -q "v$VERSION"; then
    echo -e "${RED}Error: Tag v$VERSION already exists${NC}"
    exit 1
fi

echo -e "${GREEN}Preparing release v$VERSION${NC}"

# Update version in package.json
echo "Updating package.json..."
if command -v jq &> /dev/null; then
    jq ".version = \"$VERSION\"" package.json > package.json.tmp && mv package.json.tmp package.json
else
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" package.json
    rm -f package.json.bak
fi

# Update version in src/version.ts (used by compiled binary)
echo "Updating src/version.ts..."
cat > src/version.ts << EOF
/**
 * Version constant - single source of truth
 * This file is auto-updated by scripts/release.sh
 */
export const VERSION = '$VERSION';
EOF

# Run the same local gates expected before releasing
echo "Running verification..."
"$BUN_BIN" run typecheck
"$BUN_BIN" run lint
"$BUN_BIN" test --timeout 60000 tests/config.test.ts tests/output.test.ts tests/client.test.ts tests/errors.test.ts tests/filter.test.ts tests/grep.test.ts tests/cli-errors.test.ts
"$BUN_BIN" test --timeout 60000 tests/integration/
"$BUN_BIN" run build:all

echo -e "${GREEN}Verification passed!${NC}"

# Commit version bump
echo "Committing version bump..."
git add package.json src/version.ts
git commit -m "Release v$VERSION"

# Create tag
echo "Creating tag v$VERSION..."
git tag -a "v$VERSION" -m "Release v$VERSION"

# Push changes and tag
echo "Pushing to origin..."
git push origin main
git push origin "v$VERSION"

echo ""
echo -e "${GREEN}✓ Release v$VERSION created successfully!${NC}"
echo ""
echo "GitHub Actions will now:"
echo "  1. Run the full test suite"
echo "  2. Build binaries for Linux, macOS, and Windows"
echo "  3. Create the GitHub release"
echo ""
echo "Monitor the release at:"
echo "  https://github.com/MTG-Thomas/mcp-cli/actions"

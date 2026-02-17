#!/bin/bash
set -e

echo "======================================"
echo "Setting up GitHub Agentic Workflows development environment..."
echo "======================================"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "⚠ GitHub CLI (gh) is not installed. The devcontainer features should install it."
    echo "  If this error persists, check the devcontainer configuration."
    exit 1
fi

# Verify installation
echo ""
echo "Verifying installation..."
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI (gh) version: $(gh --version | head -1)"
fi

if command -v node &> /dev/null; then
    echo "✓ Node.js version: $(node --version)"
fi

if command -v npm &> /dev/null; then
    echo "✓ npm version: $(npm --version)"
fi
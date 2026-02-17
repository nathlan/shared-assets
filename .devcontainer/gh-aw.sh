#!/usr/bin/env bash

# Authenticate with GitHub CLI
echo "Checking gh auth status..."
if ! gh auth status >/dev/null 2>&1; then
    echo "You need to authenticate with GitHub CLI to use gh-aw features"
    gh auth login -w -p https
    if gh auth status >/dev/null 2>&1; then
        echo "✓ gh CLI authenticated successfully"
    else
        echo "✗ gh CLI authentication failed"
        exit 1
    fi
else
    echo "✓ gh CLI already authenticated"
fi

# Install gh-aw CLI extension
echo "Installing gh-aw CLI extension..."
if ! gh extension list | grep -q "gh-aw"; then
    gh extension install github/gh-aw
    echo "✓ gh-aw CLI extension installed"
else
    echo "✓ gh-aw CLI extension already installed"
fi

if gh aw --help >/dev/null 2>&1; then
    echo "Initialising gh-aw..."
    gh aw init
    echo "✓ gh-aw initialised"
else
    echo "✗ gh-aw CLI extension not available after install"
    exit 1
fi

echo ""
echo "======================================"
echo "Setup complete! You can now:"
echo "  - Use GitHub Copilot Chat"
echo "  - Run 'gh aw' commands (after authenticating with 'gh auth login')"
echo "  - Create and manage agentic workflows"
echo "======================================"

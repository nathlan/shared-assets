#!/usr/bin/env bash

[ -f "$BROWSER" ] && ! command -v xdg-open > /dev/null && sudo ln -s "$BROWSER" /usr/local/bin/xdg-open

# Authenticate with GitHub CLI
echo "Checking gh auth status..."
if ! gh auth status >/dev/null 2>&1; then
    echo "You need to authenticate with \`gh\` CLI to use some gh-aw features"
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

echo ""
echo "=========================================================================="
echo "Setup complete!"
echo "You can now use GitHub Copilot Chat to create and manage agentic workflows"
echo "=========================================================================="

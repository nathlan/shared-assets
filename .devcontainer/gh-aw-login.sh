#!/usr/bin/env bash

[ -f "$BROWSER" ] && ! command -v xdg-open > /dev/null && sudo ln -s "$BROWSER" /usr/local/bin/xdg-open

# Inform user about gh authentication
echo ""
echo "=========================================================================="
echo "GitHub CLI Authentication Required"
echo "=========================================================================="
echo ""
echo "To use all GitHub Agentic Workflow (gh-aw) features, authenticate with GitHub CLI by running:"
echo ""
echo "  gh auth login"
echo ""
echo "=========================================================================="

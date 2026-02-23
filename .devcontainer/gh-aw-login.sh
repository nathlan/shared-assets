#!/usr/bin/env bash

[ -f "$BROWSER" ] && ! command -v xdg-open > /dev/null && sudo ln -s "$BROWSER" /usr/local/bin/xdg-open

# Inform user about gh authentication
echo ""
echo "=========================================================================="
echo "GitHub CLI Authentication Required"
echo "=========================================================================="
echo ""
echo "This repo contains GitHub Agentic Workflows (gh-aw). To use all features,"
echo "you need to authenticate with GitHub CLI by running:"
echo ""
echo "  gh auth login"
echo ""
echo "=========================================================================="

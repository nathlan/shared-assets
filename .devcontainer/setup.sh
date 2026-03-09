#!/bin/bash
set -euo pipefail

echo "Setting up development environment..."

# Install terraform-docs
echo "Installing terraform-docs..."
TERRAFORM_DOCS_VERSION="0.19.0"
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

curl -fsSL -o "${TEMP_DIR}/terraform-docs.tar.gz" "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz"
tar -xzf "${TEMP_DIR}/terraform-docs.tar.gz" -C "${TEMP_DIR}"
chmod +x "${TEMP_DIR}/terraform-docs"
sudo mv "${TEMP_DIR}/terraform-docs" /usr/local/bin/
echo "terraform-docs version: $(terraform-docs --version)"

# Install Python tools (Checkov and pre-commit)
echo "Installing Python tools..."
python3 -m pip install --upgrade pip
python3 -m pip install checkov pre-commit
echo "Checkov version: $(checkov --version)"
echo "pre-commit version: $(pre-commit --version)"

# Initialize TFLint plugins
echo "Initializing TFLint..."
tflint --init

# Create Terraform plugin cache directory
PLUGIN_CACHE_DIR="${PWD}/.terraform.d/plugin-cache"
mkdir -p "${PLUGIN_CACHE_DIR}"
echo "Created Terraform plugin cache directory: ${PLUGIN_CACHE_DIR}"

# Install gh-aw
echo "Installing GitHub Agentic Workflows (gh-aw)..."
curl -fsSL https://raw.githubusercontent.com/github/gh-aw/refs/heads/main/install-gh-aw.sh | bash -s v0.50.1

echo "Development environment setup complete!"
echo ""
echo "Available tools:"
echo "  - Terraform: $(terraform --version | head -n1)"
echo "  - TFLint: $(tflint --version)"
echo "  - terraform-docs: $(terraform-docs --version)"
echo "  - Checkov: $(checkov --version)"
echo "  - pre-commit: $(pre-commit --version)"
echo "  - Node.js: $(node --version)"
echo "  - Python: $(python3 --version)"
echo "  - GitHub CLI: $(gh --version | head -n1)"


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

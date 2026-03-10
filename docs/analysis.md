# Repository Analysis: shared-assets

## Overview

**shared-assets** is a centralized repository providing reusable GitHub Actions workflows, GitHub Agentic Workflows (gh-aw), custom Copilot agents, prompts, instructions, and DevContainer configurations for deployment automation across the organization.

This repository is designed to be **synced into consuming repositories** via the `sync-shared-assets` agentic workflow, which replicates content from the `sync/` directory into matching paths in target repositories.

## Repository Structure

```
shared-assets/
├── .devcontainer/                          # DevContainer configuration
│   ├── devcontainer.json                   # Container setup with tools
│   └── setup.sh                            # Post-create setup script
├── .github/
│   ├── agents/                             # Copilot custom agents
│   │   ├── agentic-workflows.agent.md      # Dispatcher for gh-aw tasks
│   │   ├── cicd-workflows.agent.md         # CI/CD workflow generator
│   │   ├── documentation-conductor.agent.md # Documentation orchestrator
│   │   └── se-technical-writer.agent.md    # Technical writing specialist
│   ├── aw/                                 # GitHub Agentic Workflows workspace
│   │   └── actions-lock.json               # MCP server configuration
│   ├── instructions/                       # Reusable instruction sets
│   │   ├── github-actions-ci-cd-best-practices.instructions.md
│   │   ├── markdown.instructions.md
│   │   └── terraform.instructions.md
│   ├── prompts/                            # VS Code prompts
│   │   ├── architecture-blueprint-generator.prompt.md
│   │   ├── documentation-writer.prompt.md
│   │   ├── generate-documentation.prompt.md
│   │   └── readme-blueprint-generator.prompt.md
│   └── workflows/                          # Reusable & Agentic Workflows
│       ├── alz-vending-dispatcher.md       # [Agentic workflow definition]
│       ├── alz-vending-dispatcher.lock.yml # [Compiled agentic workflow]
│       ├── azure-terraform-cicd-reusable.yml # [Reusable workflow - CI/CD]
│       ├── copilot-setup-steps.yml         # [Standard workflow]
│       ├── github-config-dispatcher.md     # [Agentic workflow definition]
│       └── github-config-dispatcher.lock.yml # [Compiled agentic workflow]
├── .vscode/                                # VS Code configuration
│   └── mcp.json                            # MCP server definitions (github, terraform, gh-aw)
├── sync/                                   # Synchronized content (replicated to other repos)
│   ├── .devcontainer/
│   ├── .github/
│   └── .vscode/
└── README.md                               # Repository entry point
```

## Artifacts Provided

### 1. Reusable Workflows

| Workflow | Type | Purpose | Location |
|----------|------|---------|----------|
| **Azure Terraform CI/CD** | Reusable | Standardized Terraform validation, security scanning, planning, and deployment to Azure using Flexible Federated Identity Credentials (OIDC). No secrets required — all auth values are `vars.*` inherited from the calling repo's context. | `.github/workflows/azure-terraform-cicd-reusable.yml` |

**Key Features:**
- Four-job pipeline: Validate → Security Scan → Plan → Apply
- **Flexible Federated Identity Credentials (OIDC):** No secrets passed — all values are `vars.*` (org-level and repo-level) inherited by the calling repo
- Two separate managed identities per repo: PLAN (Reader) and APPLY (Owner) for principle of least privilege
- Separate TFSTATE managed identity for backend state access
- Terraform workspace support using `github.event.repository.name` as workspace name
- Smart Checkov config detection (checks for `checkov.yml` and `.checkov.yml`)
- PR comment upsert pattern: finds existing bot comment → updates, else creates new
- No `environment` input — flexible federated credentials remove the need for per-repo credential setup
- No apply PR comment (dead code removed — branch protections prevent direct push to main)

### 2. GitHub Agentic Workflows

| Workflow | Definition File | Compiled File | Purpose | Engine | Safe Outputs |
|----------|-----------------|---------------|---------|--------|--------------|
| **ALZ Vending Dispatcher** | `alz-vending-dispatcher.md` | `alz-vending-dispatcher.lock.yml` | Dispatches `alz-vending` Copilot agent on ALZ vending issues; orchestrates cross-repo handoff to `<YOUR_GITHUB_ORG>/github-config` on close | Copilot | `assign-to-agent`, `add-comment`, `create-issue` |
| **GitHub Config Dispatcher** | `github-config-dispatcher.md` | `github-config-dispatcher.lock.yml` | Dispatches `github-config` Copilot agent on GitHub configuration issues; notifies requester on completion | Copilot | `assign-to-agent`, `add-comment` |

**Authentication:**
- Both workflows require `${{ secrets.GH_AW_AGENT_TOKEN }}` — a fine-grained PAT with:
  - **Issues**: Read & write (for assigning agents and creating cross-repo issues)
  - **Repository access**: Both the triggering repo and `<YOUR_GITHUB_ORG>/github-config` (for ALZ dispatcher cross-repo issue creation)

### 3. Custom Copilot Agents

| Agent | File | Description | Model | Target | Invocation |
|-------|------|-------------|-------|--------|-----------|
| **Agentic Workflows** | `.github/agents/agentic-workflows.agent.md` | Dispatcher agent for GitHub Agentic Workflows (gh-aw) — routes user requests to specialized prompts for creating, updating, debugging, upgrading workflows | Claude Opus 4.6 | VSCode | Handoff from other agents |
| **CI/CD Workflows** | `.github/agents/cicd-workflows.agent.md` | Generates production-ready GitHub Actions workflows for Terraform deployments (GitHub & Azure providers) with validation, security scanning, and approval gates | Claude Opus 4.6 | VSCode | Handoff from documentation conductor or direct invocation |
| **Documentation Conductor** | `.github/agents/documentation-conductor.agent.md` | Master orchestrator for repository documentation generation — validates artifact freshness, regenerates stale outputs, and auto-handoffs to specialized agents | Claude Opus 4.6 | VSCode | Invoked via `/generate-documentation` prompt |
| **SE: Tech Writer** | `.github/agents/se-technical-writer.agent.md` | Technical writing specialist for developer documentation, technical blogs, tutorials, and educational content | GPT-5 | VSCode | Handoff from Documentation Conductor |

**Note:** `.github/agents/documentation-conductor.agent.md` and `.github/agents/se-technical-writer.agent.md` are **documentation tooling only** and must be excluded from sync/scanning.

### 4. VS Code Prompts

| Prompt | File | Command Name | Purpose | Agent |
|--------|------|--------------|---------|-------|
| **Generate Documentation** | `.github/prompts/generate-documentation.prompt.md` | `/generate-documentation` | Collects target org details and invokes Documentation Conductor for end-to-end documentation generation | Documentation Conductor |
| **Documentation Writer** | `.github/prompts/documentation-writer.prompt.md` | (Internal) | Diátaxis Framework expert for creating high-quality software documentation | SE: Tech Writer |
| **Architecture Blueprint Generator** | `.github/prompts/architecture-blueprint-generator.prompt.md` | (Internal) | Analyzes codebases and generates detailed architectural documentation | (Delegated agent) |
| **README Blueprint Generator** | `.github/prompts/readme-blueprint-generator.prompt.md` | (Internal) | Intelligent README.md generation by analyzing documentation files | (Delegated agent) |

**Note:** The last two prompts are **documentation tooling only** and excluded from sync/scanning.

### 5. Instructions (Copilot Context)

| Instruction | Scope | Purpose |
|-------------|-------|---------|
| **GitHub Actions CI/CD Best Practices** | `.sync/.github/workflows/*.yml` | Comprehensive guide for building robust, secure, and efficient CI/CD pipelines using GitHub Actions; covers workflow structure, jobs, steps, environment variables, secret management, caching, matrix strategies, testing, and deployment strategies |
| **Markdown Standards** | `**/*.md` | Documentation and content creation standards; enforces heading structures, link formatting, code blocks, line length limits, and front matter requirements |
| **Terraform Conventions** | `**/*.tf` | Terraform conventions and guidelines; covers security, modularity, maintainability, style/formatting, documentation, and testing best practices |
## External Dependencies

| Dependency | Source | Type | Purpose | Migration Action |
|------------|--------|------|---------|------------------|
| **GitHub Agentic Workflows CLI (gh-aw)** | GitHub official | CLI extension | Workflow creation and compilation (`.md` → `.lock.yml`) | Install via `gh extension install github/gh-aw` |
| **GitHub API MCP Server** | GitHub official | MCP server | GitHub API access for agentic workflows (read/write issues, repos, PRs) | Available via `https://api.githubcopilot.com/mcp/x/all` |
| **Terraform MCP Server** | HashiCorp | Docker MCP server | Terraform provider/module information for CI/CD workflows | `docker run hashicorp/terraform-mcp-server:0.4.0` |
| **ALZ Vending Agent** | Source org | Custom agent | Referenced at `<YOUR_GITHUB_ORG>/alz-subscriptions` — must exist in target org | Fork or mirror from source |
| **GitHub Config Agent** | Source org | Custom agent | Referenced at `<YOUR_GITHUB_ORG>/github-config` — must exist in target org | Fork or mirror from source |
| **Shared Standards** | Source org | Standards repo | Compliance standards (referenced by sync'd compliance agent) at `<YOUR_GITHUB_ORG>/shared-standards` | Fork or mirror from source |

## Org-Specific Strings Requiring Migration

**SOURCE ORG: `nathlan`**
**TARGET ORG: `insight-agentic-platform-project`**

| Location | Current Value | Replace With | Context |
|----------|---------------|-------------|---------|
| `.github/workflows/alz-vending-dispatcher.md` | `nathlan/github-config` | `<YOUR_GITHUB_ORG>/github-config` | Cross-repo issue creation target |
| `.github/workflows/alz-vending-dispatcher.md` | `nathlan/alz-subscriptions` | `<YOUR_GITHUB_ORG>/alz-subscriptions` | Reference to ALZ vending repo |
| `.github/workflows/github-config-dispatcher.md` | `nathlan` | `<YOUR_GITHUB_ORG>` | Repository location reference |
| `.github/workflows/azure-terraform-cicd-reusable.yml` | `nathlan/shared-assets` | `<YOUR_GITHUB_ORG>/shared-assets` | Reusable workflow repository reference |
| (In compiled `.lock.yml` files) | `nathlan/...` | `<YOUR_GITHUB_ORG>/...` | Auto-generated from source `.md` files |
| `sync/.github/workflows/sync-shared-assets.md` | `nathlan/shared-assets` | `<YOUR_GITHUB_ORG>/shared-assets` | Source repository for sync workflow |
| `sync/.github/workflows/grumpy-compliance-officer.md` | `nathlan/shared-standards` | `<YOUR_GITHUB_ORG>/shared-standards` | Standards repository reference |
| `sync/.github/agents/grumpy-compliance-officer.agent.md` | `nathlan/shared-standards` | `<YOUR_GITHUB_ORG>/shared-standards` | Standards source for compliance agent |

## DevContainer Configuration

The `.devcontainer/devcontainer.json` provides a complete development environment:

**Base Image:** `mcr.microsoft.com/devcontainers/base:ubuntu`

**Pre-installed Features:**
- Docker CLI (Docker-outside-of-Docker)
- Terraform CLI (latest)
- Python 3.11 + pylint, black formatter
- Node.js LTS + npm
- git (latest)
- GitHub CLI (gh)

**VS Code Extensions:**
- `hashicorp.terraform` — Terraform syntax & language support
- `ms-python.python` + `ms-python.vscode-pylance` — Python with Pylance
- `Github.copilot` + `Github.copilot-chat` — Copilot UI
- `GitHub.vscode-pull-request-github` — GitHub PR integration

**VS Code Settings:**
- GitHub Copilot enabled for markdown files
- Terraform language server enabled
- Terraform auto-format on save
- Copilot coding agent UI integration enabled

**Environment Variables:**
- `TF_PLUGIN_CACHE_DIR` — Terraform plugin caching

**Mounted Volumes:**
- `~/.azure/` (read-write) — Azure credentials
- `~/.ssh/` (read-only) — SSH keys

**Post-Create Commands:**
- `.devcontainer/setup.sh` — Custom environment initialization

## GitHub Actions Secrets & Variables Required

### Secrets Referenced

| Secret | Usage | Required For | Scope |
|--------|-------|--------------|-------|
| `GH_AW_AGENT_TOKEN` | Agentic workflows (`alz-vending-dispatcher.md`, `github-config-dispatcher.md`) | Agent assignment, cross-repo issue creation | Organization-level |

### Variables Referenced

The reusable workflow `azure-terraform-cicd-reusable.yml` uses **vars-based** authentication via Flexible Federated Identity Credentials. All values are non-sensitive identifiers resolved via OIDC token exchange — no secrets required.

**Organization-level vars** (set once at org level, inherited by all repos):

| Variable | Usage | Purpose | Scope |
|----------|-------|---------|-------|
| `AZURE_CLIENT_ID_TFSTATE` | `azure-terraform-cicd-reusable.yml` | Managed Identity client ID for Terraform state access | Org-level |
| `AZURE_SUBSCRIPTION_ID_TFSTATE` | `azure-terraform-cicd-reusable.yml` | Subscription ID for Terraform state backend | Org-level |
| `AZURE_TENANT_ID` | `azure-terraform-cicd-reusable.yml` | Azure AD tenant ID | Org-level |
| `BACKEND_STORAGE_ACCOUNT` | `azure-terraform-cicd-reusable.yml` | Storage account name for Terraform state | Org-level |
| `BACKEND_CONTAINER` | `azure-terraform-cicd-reusable.yml` | Blob container name for Terraform state | Org-level |

**Repository-level vars** (set per consuming repo):

| Variable | Usage | Purpose | Scope |
|----------|-------|---------|-------|
| `AZURE_CLIENT_ID_PLAN` | `azure-terraform-cicd-reusable.yml` | Managed Identity client ID for plan (Reader role) | Repo-level |
| `AZURE_CLIENT_ID_APPLY` | `azure-terraform-cicd-reusable.yml` | Managed Identity client ID for apply (Owner role) | Repo-level |
| `AZURE_SUBSCRIPTION_ID` | `azure-terraform-cicd-reusable.yml` | Target Azure subscription ID | Repo-level |

## Workflow Triggers & Environments

### Agentic Workflows

**ALZ Vending Dispatcher:**
- **Triggers:** Issue opened, issue closed
- **Label Scope:** `alz-vending` label required
- **Environment:** None (cloud execution)

**GitHub Config Dispatcher:**
- **Triggers:** Issue opened, issue closed
- **Label Scope:** `github-config` label required
- **Environment:** None (cloud execution)

### Reusable Workflows

**Azure Terraform CI/CD:**
- **Called by:** Consuming repositories via `uses: <YOUR_GITHUB_ORG>/shared-assets/.github/workflows/azure-terraform-cicd-reusable.yml@main`
- **Parameters:**
  - `working-directory` (optional, default: `terraform`) — Directory containing Terraform code
- **Authentication:** Flexible Federated Identity Credentials (OIDC) — no secrets passed; all values are `vars.*` inherited from the calling repo's context
- **Workspace:** Uses `github.event.repository.name` as Terraform workspace name
- **Permissions Required:**
  - `contents: read` — Checkout code
  - `pull-requests: write` — Comment on PRs (upsert pattern)
  - `id-token: write` — OIDC token generation
  - `issues: write` — Create issue comments
  - `security-events: write` — SARIF upload

## MCP Servers Configured

| Server | Transport | Endpoint/Command | Tools | Purpose |
|--------|-----------|------------------|-------|---------|
| **github-agentic-workflows** | stdio | `gh aw mcp-server` | All gh-aw tools | Workflow creation & compilation |
| **github** | HTTP | `https://api.githubcopilot.com/mcp/x/all` | All GitHub APIs | GitHub API access (issues, repos, PRs, etc.) |
| **terraform** | Docker | `docker run hashicorp/terraform-mcp-server:0.4.0` | Provider search, provider details, module search, module details | Terraform provider/module information |

## Summary

**shared-assets** is a **centralized library repository** containing:
- ✅ **1 reusable Terraform deployment workflow** (Azure)
- ✅ **2 GitHub Agentic Workflow dispatchers** (ALZ + GitHub Config)
- ✅ **4 custom Copilot agents** (Workflows, CI/CD, Documentation, Writing)
- ✅ **4 VS Code prompts** (Documentation generation, architecture/README)
- ✅ **3 instruction files** (CI/CD best practices, Markdown standards, Terraform conventions)
- ✅ **Complete DevContainer** with Terraform, Python, Node.js, Docker, GitHub CLI
- ✅ **Sync mechanism** to distribute content to consuming repositories

**No Terraform configuration is provided** — this is purely a shared library / template repository.

The repository is designed to be **migrated as-is into a target GitHub organization**, with org-specific strings (`nathlan`) replaced throughout to point to the target organization's equivalent repositories and agents.

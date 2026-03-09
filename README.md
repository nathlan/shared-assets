# shared-assets

**Centralized library providing reusable GitHub Actions workflows, GitHub Agentic Workflows, custom Copilot agents, prompts, and DevContainer configurations for automation across the organization.**

> ⚠️ **Migrating to `insight-agentic-platform-project`?**
>
> This source repository (`nathlan/shared-assets`) must be migrated to your target organization. All references to `nathlan` need to be updated to `insight-agentic-platform-project`. See the [Migration Checklist](docs/prerequisites.md#migration-checklist) for a complete list of required changes.

## What You'll Need

- GitHub organization with CLI access (`gh auth login`)
- GitHub Agentic Workflows CLI extension: `gh extension install github/gh-aw`
- Docker (for DevContainer and MCP servers)
- Three prerequisite repositories in your org:
  - `alz-subscriptions` (ALZ vending)
  - `github-config` (GitHub repository provisioning)
  - `shared-standards` (compliance standards)

See [Prerequisites Reference](docs/prerequisites.md) for complete setup instructions.

## Getting Started

1. **Review the architecture** — [Architecture Overview](docs/ARCHITECTURE.md) explains how components work together
2. **Follow the setup guide** — [Setup Guide](docs/SETUP.md) provides step-by-step migration instructions
3. **Run in VS Code** — Open with DevContainer for full development environment with Terraform, Python, Node.js, and GitHub CLI pre-installed

## Repository Structure

```
shared-assets/
├── .devcontainer/                          # VS Code dev environment
│   ├── devcontainer.json                   # Container config with tools
│   └── setup.sh                            # Post-create initialization
├── .github/
│   ├── agents/                             # Custom Copilot agents
│   │   ├── agentic-workflows.agent.md      # gh-aw dispatcher
│   │   ├── cicd-workflows.agent.md         # CI/CD generator
│   │   ├── documentation-conductor.agent.md # [Documentation tooling]
│   │   └── se-technical-writer.agent.md    # [Documentation tooling]
│   ├── instructions/                       # Copilot context
│   │   ├── github-actions-ci-cd-best-practices.instructions.md
│   │   └── markdown.instructions.md
│   ├── prompts/                            # VS Code prompts
│   │   ├── generate-documentation.prompt.md
│   │   ├── architecture-blueprint-generator.prompt.md  # [Documentation tooling]
│   │   ├── documentation-writer.prompt.md  # [Documentation tooling]
│   │   └── readme-blueprint-generator.prompt.md # [Documentation tooling]
│   └── workflows/                          # Reusable & Agentic Workflows
│       ├── alz-vending-dispatcher.md       # [Agentic Workflow definition]
│       ├── alz-vending-dispatcher.lock.yml # [Compiled agentic workflow]
│       ├── azure-terraform-deploy.yml     # [Reusable workflow]
│       ├── copilot-setup-steps.yml         # [Standard workflow]
│       ├── github-config-dispatcher.md     # [Agentic Workflow definition]
│       └── github-config-dispatcher.lock.yml # [Compiled agentic workflow]
├── .vscode/                                # VS Code settings
│   ├── mcp.json                            # MCP servers (github, terraform, gh-aw)
│   └── settings.json                       # Editor config
├── sync/                                   # Sync'd content (replicated to other repos)
│   ├── .devcontainer/
│   ├── .github/
│   └── .vscode/
└── docs/
    ├── analysis.md                         # Codebase analysis
    ├── prerequisites.md                    # Setup requirements
    ├── SETUP.md                            # Step-by-step setup
    ├── ARCHITECTURE.md                     # How it works
    └── .artifact-state.json                # Documentation artifact metadata
```

## Agent Workflows

### [Local agent] `/generate-documentation` (`.github/prompts/generate-documentation.prompt.md`, `.github/agents/documentation-conductor.agent.md`)

Master orchestrator for repository documentation generation. Validates artifact freshness, regenerates stale outputs, and auto-handoffs to specialized agents. Invoked via VS Code command: `/generate-documentation`

**Model:** Claude Opus 4.6  
**Invocation:** VS Code Copilot Chat

---

### [Agentic Workflow] `alz-vending-dispatcher` (`.github/workflows/alz-vending-dispatcher.md`)

Dispatches the `alz-vending` Copilot coding agent to issues labeled with `alz-vending`. On issue close, orchestrates cross-repository handoff to `<YOUR_GITHUB_ORG>/github-config`.

**Triggers:** Issue opened, issue closed  
**Safe Outputs:** `assign-to-agent`, `add-comment`, `create-issue`  
**Authentication:** `GH_AW_AGENT_TOKEN` (fine-grained PAT)

---

### [Agentic Workflow] `github-config-dispatcher` (`.github/workflows/github-config-dispatcher.md`)

Dispatches the `github-config` Copilot coding agent to issues labeled with `github-config`. End of orchestration chain; notifies requester on completion.

**Triggers:** Issue opened, issue closed  
**Safe Outputs:** `assign-to-agent`, `add-comment`  
**Authentication:** `GH_AW_AGENT_TOKEN` (fine-grained PAT)

---

### [Reusable Workflow] `azure-terraform-deploy.yml`

Production-ready Terraform deployment pipeline: validation → security scan (Checkov) → plan → apply. OIDC-based Azure authentication with separate Plan (Reader) and Apply (Owner) managed identities.

**Used by:** Consuming repositories via `uses: <YOUR_GITHUB_ORG>/shared-assets/.github/workflows/azure-terraform-deploy.yml@main`  
**Jobs:** validate, security, plan, apply (with approval gate)  
**Permissions:** `id-token: write` (OIDC), `pull-requests: write` (PR comments), `issues: write`, `security-events: write` (SARIF)

---

## Configuration Reference

| Component | File | Type | Purpose |
|-----------|------|------|---------|
| **ALZ Vending Dispatch** | `.github/workflows/alz-vending-dispatcher.md` | Agentic Workflow | Issue → Agent assignment + cross-repo handoff |
| **GitHub Config Dispatch** | `.github/workflows/github-config-dispatcher.md` | Agentic Workflow | Issue → Agent assignment + notification |
| **Terraform Deploy** | `.github/workflows/azure-terraform-deploy.yml` | Reusable Workflow | Plan → Security scan → Apply with OIDC auth |
| **CI/CD Workflows Agent** | `.github/agents/cicd-workflows.agent.md` | Copilot Agent | Generates production GitHub Actions workflows |
| **Agentic Workflows Agent** | `.github/agents/agentic-workflows.agent.md` | Copilot Agent | Dispatcher for gh-aw tasks (create, update, debug, upgrade) |
| **GitHub CLI Extension** | (External) | Dependency | `gh aw` — Workflow compilation and deployment |
| **GitHub Agentic Workflows** | v0.50.1 | Framework | Engine for AI-powered GitHub automation |

## Developer Experience

Open this repository in **VS Code with DevContainer** for a complete, pre-configured development environment:

```bash
code .
# When prompted: "Reopen in Container"
```

**What you get:**
- ✅ **Terraform CLI** (latest) with language server, auto-format, TFLint
- ✅ **Python 3.11** with pip, pylint, black formatter
- ✅ **Node.js LTS** with npm
- ✅ **Docker CLI** (Docker-outside-of-Docker) for MCP servers
- ✅ **GitHub CLI** with `gh-aw` extension pre-installed
- ✅ **Git** (latest) with credential forwarding
- ✅ **VS Code Extensions:**
  - HashiCorp Terraform
  - Python + Pylance
  - GitHub Copilot + Copilot Chat
  - GitHub Pull Requests

**Environment:**
- Azure credentials mounted from `~/.azure/` (read-write)
- SSH keys mounted from `~/.ssh/` (read-only)
- Terraform plugin cache enabled (`.terraform.d/plugin-cache`)

## Key Features

- **Dispatcher Pattern** — Agentic workflows listen for labels and dispatch agents
- **Cross-Repo Orchestration** — ALZ vending → GitHub config handoff with automatic issue creation
- **Organization-Aware** — All org-specific strings (`nathlan` → `insight-agentic-platform-project`) flagged for migration
- **Zero State Management** — This is a library repo; no managed infrastructure or Terraform state
- **DevContainer-First** — All tools pre-configured for immediate productivity
- **Copilot-Native** — Custom agents, prompts, and agentic workflows for intelligent automation

## Next Steps

1. **Review prerequisites** → [Prerequisites Reference](docs/prerequisites.md)
2. **Follow setup guide** → [Setup Guide](docs/SETUP.md) (includes org string migration steps)
3. **Understand architecture** → [Architecture Overview](docs/ARCHITECTURE.md)
4. **Deploy to your org** → Use GitHub CLI to create repos and deploy shared-assets

## Documentation

- [**Analysis**](docs/analysis.md) — Complete inventory of repository components and dependencies
- [**Prerequisites**](docs/prerequisites.md) — Setup requirements, secrets, checklist, migration guide
- [**Setup Guide**](docs/SETUP.md) — Phase-by-phase deployment instructions with validation steps
- [**Architecture**](docs/ARCHITECTURE.md) — How components work together, authentication models, lifecycle
- [**README**](README.md) — This file; entry point and quick reference

## License

[Specify your license here, if applicable]

## Support

For issues or questions:
- Check the [FAQ in Prerequisites](docs/prerequisites.md#troubleshooting)
- Review the [Architecture Overview](docs/ARCHITECTURE.md) for detailed explanations
- Consult the [Setup Guide](docs/SETUP.md) for common tasks and troubleshooting

---

**Built with ❤️ for GitHub-native automation**

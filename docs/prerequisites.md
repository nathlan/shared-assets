# Prerequisites Reference

## Target Organization Setup

> ⚠️ **Migration Context:**
> All references to `nathlan` (source organization) in this document should be replaced with `insight-agentic-platform-project` (target organization).

This document outlines everything needed to deploy **shared-assets** into the `insight-agentic-platform-project` organization and configure it for use by consuming repositories.

## GitHub Organization Requirements

### Required Repositories

The following repositories **must exist** in the target organization before deploying shared-assets:

| Repository | Purpose | Source | Migration Action |
|------------|---------|--------|------------------|
| `shared-assets` | This repository — shared workflows, agents, and configurations | Define new repo or fork from source | Create new repository in target org |
| `alz-subscriptions` | ALZ vending/provisioning repository — dispatched by `alz-vending-dispatcher` workflow | Fork from source | Must exist; referenced in agentic workflows |
| `github-config` | GitHub repository configuration — dispatched by `alz-vending-dispatcher` cross-repo issue | Fork from source | Must exist; target for cross-repo issue creation |
| `shared-standards` | Shared compliance standards — referenced by sync'd compliance agent | Fork from source | Must exist; compliance validation relies on it |
| `.github-workflows` (optional) | Reusable workflows library (if you intend to centralize beyond shared-assets) | Create or fork | Optional; not required by shared-assets itself |

**Critical:** Agentic workflows in shared-assets reference these repositories. If they do not exist when the workflows are invoked, agent assignment will fail. Create them **before** using shared-assets agentic workflows in your organization.

### GitHub Actions Secrets (Organization or Repository Level)

Configure these secrets in your **GitHub organization** or in **consuming repositories** as needed:

#### `GH_AW_AGENT_TOKEN`

**Required for:** Agentic workflows (`alz-vending-dispatcher.md`, `github-config-dispatcher.md`)

**Purpose:** Fine-grained PAT for agentic workflow agent assignment and cross-repo issue creation

**Permissions:**
- **Repository access:** 
  - `insight-agentic-platform-project/shared-assets` (this repo)
  - `insight-agentic-platform-project/github-config` (cross-repo issue target)
  - Any repo where `alz-vending` or `github-config` labels trigger workflows
- **Fine-grained permissions:**
  - **Issues** — `Read & Write` (assign agents, create/read issues, add comments)
  - **Pull Requests** — `Read & Write` (for agent handoff context)

**How to Create:**
1. Navigate to GitHub org Settings → Developer Settings → Personal access tokens → Fine-grained tokens
2. Create a new token with a descriptive name (e.g., `shared-assets-agentic-workflows`)
3. Select repositories: all repos that will run agentic workflows + `github-config` (for cross-repo issues)
4. Select permissions: `Issues` (R&W), `Pull Requests` (R&W)
5. Copy the token and store as `GH_AW_AGENT_TOKEN` in org-level Actions secrets

**Org-Level Setting:** Settings → Secrets and variables → Actions → Repository secrets → New secret

#### Azure Terraform Variables (For Consuming Repositories)

These variables are **NOT** required by shared-assets itself, but **consuming repositories** that use the `azure-terraform-cicd-reusable.yml` reusable workflow must have them set as GitHub Actions variables. No secrets are needed — all values are non-sensitive identifiers resolved via OIDC token exchange using Flexible Federated Identity Credentials.

**Organization-level vars** (set once at org level, inherited by all repos):

| Variable | Purpose | Source |
|----------|---------|--------|
| `AZURE_CLIENT_ID_TFSTATE` | Managed Identity client ID for Terraform state access | Azure Entra ID — UAMI created in target tenant |
| `AZURE_SUBSCRIPTION_ID_TFSTATE` | Subscription ID for Terraform state backend | Azure portal |
| `AZURE_TENANT_ID` | Azure AD tenant ID for OIDC token exchange | Azure portal |
| `BACKEND_STORAGE_ACCOUNT` | Storage account name for Terraform state | Azure portal |
| `BACKEND_CONTAINER` | Blob container name for Terraform state | Azure portal |

**Repository-level vars** (set per consuming repo):

| Variable | Purpose | Source |
|----------|---------|--------|
| `AZURE_CLIENT_ID_PLAN` | Managed Identity client ID for Terraform plan (Reader role) | Azure Entra ID — UAMI created per repo |
| `AZURE_CLIENT_ID_APPLY` | Managed Identity client ID for Terraform apply (Owner role) | Azure Entra ID — UAMI created per repo |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription for deployments | Azure portal |

**Note:** These are inherited by the reusable workflow from the calling repo's `vars.*` context. No `secrets:` or `inputs:` are required to pass them.

## DevContainer Prerequisites

The `.devcontainer/devcontainer.json` includes the following dependencies:

### Pre-installed Tools

These tools are automatically installed during container startup:

- **Docker CLI** — Docker daemon communication (Docker-outside-of-Docker)
- **Terraform CLI** — Latest version
- **Python 3.11** — Includes pip3, pylint, black
- **Node.js LTS** — npm included
- **git** — Latest version
- **GitHub CLI (gh)** — Latest version

### Additional Setup: GitHub CLI Extensions

After container startup, install the following GitHub CLI extensions:

```bash
# Install GitHub Agentic Workflows extension
gh extension install github/gh-aw

# Install the extension version used by this repository
gh extension install github/gh-aw --version v0.50.1
```

**How to verify installation:**
```bash
gh aw --version
```

Should output something like: `gh-aw v0.50.1`

### VS Code Extensions

The devcontainer includes these extensions (auto-installed):

- `hashicorp.terraform` — Terraform language support
- `ms-python.python` + `ms-python.vscode-pylance` — Python development
- `Github.copilot` + `Github.copilot-chat` — Copilot UI and chat
- `GitHub.vscode-pull-request-github` — PR and issue integration

### Local Environment Mounts

The devcontainer mounts the following directories from the host system:

| Host Directory | Container Path | Mode | Purpose |
|----------------|-----------------|------|---------|
| `~/.azure/` | `/home/vscode/.azure/` | Read-Write | Azure credentials (az CLI, SDK) |
| `~/.ssh/` | `/home/vscode/.ssh/` | Read-Only | SSH keys for Git operations |

**Prerequisite:** Ensure these directories exist on your host system before opening the container.

```bash
# Create if missing
mkdir -p ~/.azure
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

## Agentic Workflow Dependencies

### GitHub Agentic Workflows (gh-aw) Version

**Required Version:** v0.50.1 (or compatible)

**Installation:**
```bash
# Inside the devcontainer
gh extension install github/gh-aw
```

**Verification:**
```bash
gh aw --version
gh aw mcp-server --help  # Should not error
```

### MCP Servers

Three MCP servers are configured in `.vscode/mcp.json`. Ensure these are available:

| Server | Status | Notes |
|--------|--------|-------|
| **github-agentic-workflows** | ✅ Built-in | Provided by `gh aw mcp-server` CLI; no external setup needed |
| **github** | ✅ Built-in | Provided by GitHub's official MCP server at `https://api.githubcopilot.com/mcp/x/all` |
| **terraform** | ✅ Docker-based | Auto-pulled from `hashicorp/terraform-mcp-server:0.4.0`; requires Docker daemon |

**Verify MCP setup:**
```bash
# Inside devcontainer
gh aw mcp-server --help
docker ps  # Verify Docker daemon access
```

## GitHub Actions Environment & Approvals

### Environments

Consuming repositories that use `azure-terraform-cicd-reusable.yml` may define environments for approval gates:

| Environment | Purpose | Used By | Approval Required |
|-------------|---------|---------|------------------|
| `azure-production` | Production Azure deployments | Consuming repo workflows | Yes (recommended) |
| `github-admin` | GitHub admin operations | GitHub Config workflows | Yes (recommended) |

**How to configure:**
1. Repository Settings → Environments
2. Create environment (e.g., `azure-production`)
3. Set "Deployment branches" to allowed branches (e.g., `main`)
4. Add required reviewers if approval gate is desired

** ⚠️ Note:** shared-assets itself does not define environments (it provides templates). Consuming repositories define their own based on deployment needs.

## Migration Checklist

Follow these steps in order to migrate shared-assets to the target organization:

### Phase 1: Pre-Deployment (In Target Org)

- [ ] **Repositories Created**: `alz-subscriptions`, `github-config`, `shared-standards` exist in target org (or fork them from source)
- [ ] **GitHub CLI configured**: `gh auth login` and authenticated against target org
- [ ] **gh-aw extension installed**: `gh extension install github/gh-aw`
- [ ] **Docker daemon available**: `docker ps` works without errors

### Phase 2: String Migration (Before Deploying shared-assets)

Before pushing any code to the target org's shared-assets repository, perform these replacements:

| File(s) | Search | Replace With |
|---------|--------|-------------|
| `.github/workflows/alz-vending-dispatcher.md` | `nathlan/github-config` | `insight-agentic-platform-project/github-config` |
| `.github/workflows/alz-vending-dispatcher.md` | `nathlan/alz-subscriptions` | `insight-agentic-platform-project/alz-subscriptions` |
| `.github/workflows/github-config-dispatcher.md` | `nathlan` | `insight-agentic-platform-project` |
| `.github/workflows/azure-terraform-cicd-reusable.yml` | `nathlan/shared-assets` | `insight-agentic-platform-project/shared-assets` |
| `sync/.github/workflows/sync-shared-assets.md` | `nathlan/shared-assets` | `insight-agentic-platform-project/shared-assets` |
| `sync/.github/workflows/grumpy-compliance-officer.md` | `nathlan/shared-standards` | `insight-agentic-platform-project/shared-standards` |
| `sync/.github/agents/grumpy-compliance-officer.agent.md` | `nathlan/shared-standards` | `insight-agentic-platform-project/shared-standards` |

**Recommendation:** Use a search-and-replace tool or a git hook to ensure all occurrences are updated. The `.lock.yml` files will be auto-regenerated after updating source `.md` files.

### Phase 3: Deployment (Push to Target Org)

- [ ] **Create shared-assets repository** in target org
- [ ] **Apply string migrations** (see Phase 2 above)
- [ ] **Push code** to target org shared-assets repository
- [ ] **Verify agentic workflow compilation**: Commit `.md` files and verify `.lock.yml` files are generated by CI/CD
- [ ] **Test ALZ vending dispatcher** — Create a test issue in `alz-subscriptions` with `alz-vending` label and verify agent assignment

### Phase 4: Organization Configuration

- [ ] **Create `GH_AW_AGENT_TOKEN` secret** in target org (or repo-level in alz-subscriptions and github-config repos)
  - Fine-grained PAT with `Issues: R&W` scope
  - Repository access: `alz-subscriptions`, `github-config`, `shared-assets`
- [ ] **Update consuming repositories** to reference target org's shared-assets in `uses:` clauses
- [ ] **Grant token permissions** — Ensure `GH_AW_AGENT_TOKEN` can access all target repos

### Phase 5: Validation

- [ ] **Agentic workflows compile without errors** (`gh aw compile` runs successfully)
- [ ] **Agents can be assigned** — Test by creating an issue with appropriate label
- [ ] **Cross-repo issues are created** — ALZ dispatcher creates issues in github-config without auth errors
- [ ] **Terraform workflow can be invoked** — Call `azure-terraform-cicd-reusable.yml` from a test repo and verify plan step works

## Dependent Teams/Repositories

The following teams/repositories depend on shared-assets and will need updates:

| Team/Repo | Impact | Action Required |
|-----------|--------|-----------------|
| **ALZ Vending Team** | Uses `alz-vending-dispatcher.md` to assign agents | Update workflow references in `alz-subscriptions` |
| **GitHub Config Team** | Uses `github-config-dispatcher.md` for repository automation | Update workflow references in `github-config` |
| **Compliance Team** | Uses synced `grumpy-compliance-officer` agent | Ensure `shared-standards` repository exists and is accessible |
| **All teams** | Call `azure-terraform-cicd-reusable.yml` in CI/CD pipelines | Update `uses:` references to point to target org |

## Common Issues & Troubleshooting

### Issue: `GH_AW_AGENT_TOKEN` Permission Denied

**Symptom:** Agents fail to assign; "permission denied" or "403 Unauthorized" in workflow logs

**Solution:**
1. Verify token has `Issues: R&W` scope
2. Verify token repository access includes the target repo
3. Verify token is not expired
4. Regenerate the token if needed and update the secret

### Issue: Cross-Repo Issue Creation Fails

**Symptom:** `create_issue` safe-output fails; "repository not found" or "403 Forbidden"

**Solution:**
1. Verify `nathlan/github-config` has been replaced with `insight-agentic-platform-project/github-config`
2. Verify the `github-config` repository exists in the target org
3. Verify `GH_AW_AGENT_TOKEN` has repository access to `github-config`

### Issue: `.lock.yml` Files Not Generated

**Symptom:** `.lock.yml` files are stale or missing after pushing `.md` files

**Solution:**
1. Ensure `gh aw` extension is installed (`gh extension install github/gh-aw`)
2. Run `gh aw compile` locally to generate lock files
3. Commit and push both `.md` and generated `.lock.yml` files
4. Verify GitHub Actions has permission to commit back to the repo (use `GITHUB_TOKEN` with write access or a bot PAT)

### Issue: DevContainer Fails to Start

**Symptom:** Docker error or feature installation fails during container startup

**Solution:**
1. Ensure Docker daemon is running on the host
2. Rebuild container: `Dev Containers: Rebuild Container` in VS Code command palette
3. Check `/tmp/build.log` inside the container for detailed error messages
4. Verify host directories (`~/.azure`, `~/.ssh`) exist before opening container

## Summary

To deploy shared-assets to the target organization:

1. **Create prerequisite repositories** (`alz-subscriptions`, `github-config`, `shared-standards`)
2. **Create `GH_AW_AGENT_TOKEN` secret** in the target org (fine-grained PAT with Issues R&W scope)
3. **Install gh-aw extension** (`gh extension install github/gh-aw`)
4. **Migrate organization strings** (replace all `nathlan` refs with `insight-agentic-platform-project`)
5. **Deploy shared-assets** to the target org
6. **Compile agentic workflows** (`gh aw compile`) and verify `.lock.yml` files are generated
7. **Test a sample workflow** (create an issue with `alz-vending` label to verify agent assignment)

# Setup Guide: Migrating shared-assets to insight-agentic-platform-project

## Before You Begin — Migrate Org References

> **Critical:** This step must be completed FIRST, before any workspace, testing, or deployment.

The source codebase contains references to the source organization (`nathlan`). You must replace these with your target organization (`insight-agentic-platform-project`) in all files.

### Step 1: Search and Replace All Org References

1. **Open your terminal and navigate to the shared-assets repository root**

   ```bash
   cd shared-assets
   ```

2. **Replace all occurrences of `nathlan` with `insight-agentic-platform-project`**

   Use your editor's find-and-replace or a terminal tool:

   ```bash
   # Using sed (macOS/Linux)
   find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" | \
     xargs sed -i '' 's/nathlan/insight-agentic-platform-project/g'
   
   # Using sed (Linux)
   find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" | \
     xargs sed -i 's/nathlan/insight-agentic-platform-project/g'
   ```

   Or use VS Code:
   - Press `Ctrl+Shift+H` (Find & Replace)
   - Find: `nathlan`
   - Replace: `insight-agentic-platform-project`
   - Click "Replace All"

3. **Verify replacements were successful**

   ```bash
   grep -r "nathlan" .github/ || echo "✅ No remaining nathlan references"
   ```

4. **Regenerate compiled agentic workflow files** (`.lock.yml`)

   ```bash
   gh aw compile
   ```

   This will regenerate all `.lock.yml` files based on the updated `.md` files.

5. **Commit and push changes**

   ```bash
   git add .
   git commit -m "chore: migrate organization references to insight-agentic-platform-project"
   git push origin main
   ```

## Setup Workflow

### Phase 1: Organization Prerequisites (In Target Org)

You must complete this phase in the `insight-agentic-platform-project` organization before deploying shared-assets.

#### Task 1: Create Required Repositories

The following repositories must exist in your target organization. If you have them in the source org, fork them now. If not, create them:

**1. Create `alz-subscriptions` repository**

```bash
# Using GitHub CLI
gh repo create insight-agentic-platform-project/alz-subscriptions \
  --public \
  --description "Azure Landing Zone vending and provisioning"

# OR fork if you have access to the source
gh repo fork nathlan/alz-subscriptions --org insight-agentic-platform-project
```

**Verification:** 
```bash
gh repo view insight-agentic-platform-project/alz-subscriptions
```

You should see:
```
Name:        alz-subscriptions
Owner:       insight-agentic-platform-project
Description: Azure Landing Zone vending and provisioning
```

**2. Create `github-config` repository**

```bash
gh repo create insight-agentic-platform-project/github-config \
  --public \
  --description "GitHub repository configuration and provisioning"
```

**Verification:**
```bash
gh repo view insight-agentic-platform-project/github-config
```

**3. Create `shared-standards` repository**

```bash
gh repo create insight-agentic-platform-project/shared-standards \
  --public \
  --description "Shared compliance standards and linting rules"
```

**Verification:**
```bash
gh repo view insight-agentic-platform-project/shared-standards
```

#### Task 2: Authenticate with GitHub CLI

```bash
# Login to GitHub and select your target organization
gh auth login

# Select:
# - Protocol: https
# - Authenticate with your GitHub credentials
# - Authorize with your SSH key (if prompted)

# Verify authentication
gh auth status
```

You should see output like:
```
  Logged in to github.com as <your-username> (keyring)
  Git operations for github.com configured to use ssh protocol.
```

#### Task 3: Install GitHub Agentic Workflows Extension

```bash
# Install gh-aw extension
gh extension install github/gh-aw@v0.50.1

# Verify installation
gh aw --version
```

You should see:
```
gh-aw version v0.50.1
```

#### Task 4: Create GitHub Actions Secret (`GH_AW_AGENT_TOKEN`)

1. **Navigate to GitHub organization settings:**
   - Go to `github.com/organizations/insight-agentic-platform-project/settings`
   - Select "Secrets and variables" → "Actions"

2. **Create a fine-grained personal access token (PAT):**
   - Go to `github.com/settings/tokens?type=beta`
   - Click "Generate new token"
   - **Token name:** `shared-assets-agentic-workflows`
   - **Expiration:** 90 days or longer
   - **Repository access:** Select repositories:
     - `insight-agentic-platform-project/shared-assets`
     - `insight-agentic-platform-project/alz-subscriptions`
     - `insight-agentic-platform-project/github-config`
     - `insight-agentic-platform-project/shared-standards`
   - **Permissions:**
     - **Issues** — `Read & Write`
     - **Pull requests** — `Read & Write`
   - Click "Generate token"
   - **Copy the token immediately** (you cannot view it again)

3. **Add the token to organization secrets:**
   - Go to org Settings → Secrets and variables → Actions
   - Click "New organization secret"
   - **Name:** `GH_AW_AGENT_TOKEN`
   - **Value:** Paste the PAT you just created
   - **Repository access:** Select "Selected repositories" and choose:
     - `shared-assets`
     - `alz-subscriptions`
     - `github-config`
   - Click "Add secret"

**Verification:**
```bash
gh secret list --org insight-agentic-platform-project
```

You should see:
```
GH_AW_AGENT_TOKEN
```

### Phase 2: Deploy shared-assets Repository

#### Task 1: Create shared-assets Repository in Target Org

```bash
gh repo create insight-agentic-platform-project/shared-assets \
  --public \
  --description "Shared GitHub Actions workflows, agents, and configurations"
```

#### Task 2: Clone and Configure the Repository

```bash
# Clone the repository (use the target org)
git clone https://github.com/insight-agentic-platform-project/shared-assets
cd shared-assets

# Add upstream reference (optional, for tracking updates from source)
git remote add upstream https://github.com/nathlan/shared-assets
```

#### Task 3: Copy Content from Source (If Starting Fresh)

If you're starting from scratch, copy the source repository content:

```bash
# Clone source repo into a temp directory
cd /tmp
git clone https://github.com/nathlan/shared-assets shared-assets-source

# Copy all content to your target repo
cp -r /tmp/shared-assets-source/* /path/to/your/target/shared-assets/

cd /path/to/your/target/shared-assets
```

#### Task 4: Apply Organization String Migrations (if not done earlier)

From within the shared-assets directory:

```bash
# Find and replace all nathlan refs
find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" | \
  xargs sed -i 's/nathlan/insight-agentic-platform-project/g'

# Regenerate .lock.yml files
gh aw compile

# Verify no nathlan references remain
grep -r "nathlan" . || echo "✅ Migration complete"
```

#### Task 5: Commit and Push to Target Org

```bash
git add .
git commit -m "docs: migrate to insight-agentic-platform-project organization"
git push origin main
```

**Verification:** Visit `github.com/insight-agentic-platform-project/shared-assets` and confirm all files are visible.

### Phase 3: Validate Agentic Workflow Compilation

#### Task 1: Verify .lock.yml Files Are Generated

```bash
# Check that .lock.yml files exist and are recent
ls -lh .github/workflows/*.lock.yml
```

You should see:
```
-rw-r--r--  alz-vending-dispatcher.lock.yml      (recent timestamp)
-rw-r--r--  github-config-dispatcher.lock.yml    (recent timestamp)
```

#### Task 2: Run Workflow Compilation Locally

```bash
# Change to the repo directory
cd shared-assets

# Run gh aw compile
gh aw compile

# Should output without errors
# Generated files: alz-vending-dispatcher.lock.yml, github-config-dispatcher.lock.yml
```

**Expected output:**
```
✓ Compiled alz-vending-dispatcher.md → alz-vending-dispatcher.lock.yml
✓ Compiled github-config-dispatcher.md → github-config-dispatcher.lock.yml
```

**If compilation fails:**
1. Verify gh-aw extension is installed: `gh aw --version`
2. Check for YAML syntax errors in `.md` files (especially frontmatter)
3. Verify organization references have been updated completely

#### Task 3: Verify DevContainer Builds Successfully

```bash
# Open shared-assets in VS Code with Dev Containers
code .

# When prompted, click "Reopen in Container"
# OR use command:
# - Press Ctrl+Shift+P
# - Type "Dev Containers: Reopen in Container"
# - Wait for container to build and start

# Once inside the container, verify tools are installed:
terraform --version     # Should show Terraform version
gh --version            # Should show GitHub CLI version
gh aw --version         # Should show gh-aw version
python3 --version       # Should show Python 3.11+
docker ps               # Should list running containers
```

**Expected output inside container:**
```
Terraform v1.x.x
gh version X.X.X
gh-aw version v0.50.1
Python 3.11.x
```

### Phase 4: Test Agentic Workflows

#### Task 1: Create a Test Issue in ALZ Subscriptions Repo

```bash
# Create a test issue with the alz-vending label
gh issue create \
  --repo insight-agentic-platform-project/alz-subscriptions \
  --title "Test: ALZ Vending Dispatcher" \
  --body "Testing agent assignment for ALZ vending workflow" \
  --label alz-vending
```

**Expected outcome (within 30 seconds):**
- The issue is assigned to the `alz-vending` Copilot agent
- You see a comment from the agent acknowledging the assignment

**If assignment doesn't happen:**
1. Check GitHub Actions logs: Go to repo → Actions → Recent runs
2. Look for the `alz-vending-dispatcher` workflow
3. Verify `GH_AW_AGENT_TOKEN` is configured correctly
4. Verify token has `Issues: R&W` scope

#### Task 2: Create a Test Issue in GitHub Config Repo

```bash
# Create a test issue with the github-config label
gh issue create \
  --repo insight-agentic-platform-project/github-config \
  --title "Test: GitHub Config Dispatcher" \
  --body "Testing agent assignment for GitHub configuration" \
  --label github-config
```

**Expected outcome (within 30 seconds):**
- The issue is assigned to the `github-config` Copilot agent
- You see a comment acknowledging the assignment

#### Task 3: Close ALZ Test Issue and Verify Cross-Repo Issue Creation

```bash
# Close the ALZ test issue (replace ISSUE_NUMBER with actual number)
gh issue close ISSUE_NUMBER \
  --repo insight-agentic-platform-project/alz-subscriptions

# Verify a new issue was created in github-config
gh issue list \
  --repo insight-agentic-platform-project/github-config \
  --label automation \
  --limit 1
```

**Expected outcome:**
- A new issue appears in `github-config` with:
  - Title starting with `feat: Create workload repository`
  - Label: `automation`, `github-config`
  - Body: Contains structured landing zone configuration details

### Phase 5: Update Consuming Repositories

For repositories that will use the reusable `azure-terraform-deploy.yml` workflow, update their workflow calls:

#### Before (Source Org)
```yaml
uses: nathlan/shared-assets/.github/workflows/azure-terraform-deploy.yml@main
```

#### After (Target Org)
```yaml
uses: insight-agentic-platform-project/shared-assets/.github/workflows/azure-terraform-deploy.yml@main
```

**Steps for each consuming repository:**

1. **Locate workflow files that call azure-terraform-deploy.yml:**

   ```bash
   grep -r "azure-terraform-deploy" .github/workflows/
   ```

2. **Update the `uses:` reference:**

   Replace the org name in any line like:
   ```yaml
   uses: <ORG>/shared-assets/.github/workflows/azure-terraform-deploy.yml@<ref>
   ```

3. **Commit and push:**

   ```bash
   git add .github/workflows/
   git commit -m "chore: update azure-terraform-deploy workflow reference to target org"
   git push
   ```

## Common Tasks

### Task: Pull Latest Updates from Source (Optional)

If the source repository receives updates that you want to incorporate:

```bash
cd shared-assets

# Fetch latest from upstream
git fetch upstream

# Review changes
git log --oneline main..upstream/main

# Merge if desired
git merge upstream/main

# Regenerate lock files after merge
gh aw compile

# Commit and push
git add .
git commit -m "chore: merge latest updates from upstream"
git push origin main
```

### Task: Update a Single Workflow File

If you need to modify a workflow file (`.md` or `.yml`):

1. **Edit the file** in VS Code or your editor
2. **If you edited a `.md` file, regenerate the `.lock.yml`:**

   ```bash
   gh aw compile
   ```

3. **Test your changes** (if possible)
4. **Commit both `.md` and `.lock.yml`:**

   ```bash
   git add .github/workflows/your-workflow.md
   git add .github/workflows/your-workflow.lock.yml
   git commit -m "feat: update workflow description"
   git push
   ```

## Troubleshooting

### Problem: Agent Assignment Fails (403 Error)

**Symptom:** Issue created but agent not assigned; workflow logs show `403 Unauthorized`

**Solution:**
1. Verify `GH_AW_AGENT_TOKEN` secret exists:
   ```bash
   gh secret list --org insight-agentic-platform-project
   ```

2. Verify token has correct permissions (Issues: R&W)

3. Regenerate token if it's expired:
   - Delete old token from `github.com/settings/tokens`
   - Create new token with same permissions
   - Update `GH_AW_AGENT_TOKEN` secret

### Problem: Cross-Repo Issue Creation Fails

**Symptom:** ALZ dispatcher closes an issue but doesn't create issue in `github-config`

**Solution:**
1. Verify `github-config` repository exists:
   ```bash
   gh repo view insight-agentic-platform-project/github-config
   ```

2. Verify token has access to `github-config` repo

3. Check workflow logs for API errors:
   - Go to `alz-subscriptions` → Actions
   - Find latest `alz-vending-dispatcher` run
   - Check logs for `create_issue` error messages

### Problem: .lock.yml Files Not Regenerating

**Symptom:** Modified `.md` file but `.lock.yml` doesn't update

**Solution:**
```bash
# Ensure gh-aw is installed
gh extension upgrade gh-aw

# Run compile with verbose output
gh aw compile --verbose

# Check for YAML syntax errors in .md files
yamllint .github/workflows/*.md
```

### Problem: DevContainer Fails to Start

**Symptom:** Container build fails with Docker error

**Solution:**
1. Ensure Docker daemon is running:
   ```bash
   docker ps
   ```

2. Rebuild the container:
   - VS Code command palette → "Dev Containers: Rebuild Container"
   - Wait 5-10 minutes for full build

3. Check container logs:
   ```bash
   docker logs <container-id>
   ```

## Next Steps

After successfully deploying shared-assets:

1. **Share with team:** Provide document link and quickstart to consuming repositories
2. **Monitor workflows:** Check GitHub Actions logs regularly for failures
3. **Stay updated:** Periodically pull latest updates from upstream (if tracking source)
4. **Customize as needed:** Modify agents and workflows to match your organization's needs

Your shared-assets deployment is now complete! 🎉

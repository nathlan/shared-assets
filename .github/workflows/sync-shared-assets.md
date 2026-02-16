---
name: Sync Shared Assets to Template Repos
description: Sync the sync/ folder to .github/ in all repositories created from nathlan/alz-workload-template
on:
  schedule: weekly on Sunday around 02:00 utc+12 # 2AM NZST, 3AM NZDT
  workflow_dispatch: {}
permissions:
  contents: read
network:
  allowed:
    - defaults
    - github
tools:
  github:
    toolsets: [repos]
    mode: remote
    app:
      app-id: ${{ secrets.SOURCE_REPO_SYNC_APP_ID }}
      private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
      owner: nathlan
      repositories: []
  edit:
safe-outputs:
  app:
    app-id: ${{ secrets.SOURCE_REPO_SYNC_APP_ID }}
    private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
    owner: nathlan
    repositories: []
  create-pull-request:
    title-prefix: "[shared-assets-sync] "
    labels: [agentic-workflow, shared-assets-sync, platform-engineering]
    draft: false
    auto-merge: true
---

# Sync Shared Assets to Template Repos

When the `sync/` folder changes in this repository, synchronize its contents to all repositories created from the `nathlan/alz-workload-template` template. The sync folder structure maps to `.github/` in downstream repos, allowing workflow, agent, and template updates to propagate automatically.

## Sync Mapping

- **Source**: `nathlan/shared-assets/sync/`
- **Target**: `nathlan/<downstream-repo>/.github/`

This mirrors workflows, agents, issue templates, and other GitHub configurations across all infrastructure repositories.

## Discovery and Sync Process

1) Read all `*.tfvars` and `*.auto.tfvars` files under `nathlan/github-config/terraform/` (use the GitHub MCP server, not web search)
2) Parse `template_repositories` entries to build the target repo list
3) For each discovered repository, read the current `.github/` folder structure
4) For each discovered repository, sync changes from the `nathlan/shared-assets/sync/` folder into the `nathlan/<downstream-repo>/.github/` folder - these folders share the same structure. If a file to be synced contains repo-specific customizations then leave that configuration alone unless the sync is overwriting specific configuration. Don't delete additional repo-specific files added to the `nathlan/<downstream-repo>/.github/` folder.
5) Create a pull request with detailed change summary, compatibility notes, and links to source commits
6) If auto-merge is enabled in the repo, note that the PR should merge automatically after required checks and approvals complete; otherwise, leave it for manual review

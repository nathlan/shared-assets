---
name: Sync Shared Assets to Template Repos
description: Sync the sync/ folder to .github/ in all repositories created from nathlan/alz-workload-template
on:
  push:
    branches: [main]
    paths:
      - 'sync/**'
  workflow_dispatch: {}
permissions:
  contents: read
  actions: read
network:
  allowed:
    - defaults
    - github
tools:
  github:
    mode: remote
    toolsets: [repos]
    app:
      app-id: ${{ vars.SOURCE_REPO_SYNC_APP_ID }}
      private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
      owner: nathlan
      repositories: [""]
  edit:
  bash:
    - "git:*"
safe-outputs:
  app:
    app-id: ${{ vars.SOURCE_REPO_SYNC_APP_ID }}
    private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
    owner: nathlan
    repositories: [""]
  create-pull-request:
    title-prefix: "[shared-assets-sync] "
    labels: [agentic-workflow, shared-assets-sync, platform-engineering]
    draft: false
---

# Sync Shared Assets to Template Repos

When the `sync/` folder changes in this repository, synchronize its contents to all repositories created from the `nathlan/alz-workload-template` template. The sync folder structure maps to `.github/` in downstream repos, allowing workflow, agent, and template updates to propagate automatically.

## Sync Mapping

- **Source**: `nathlan/shared-assets/sync/`
- **Target**: `nathlan/<downstream-repo>/.github/`

This mirrors workflows, agents, issue templates, and other GitHub configurations across all infrastructure repositories.

## Discovery and Sync Process

1) Read all `*.tfvars` and `*.auto.tfvars` files in `nathlan/github-config/terraform/` directory. Parse `template_repositories` entries to build the list of target repositories that were created from the template:
```
template_repositories = [
  {
    name = "<downstream-repo-name-here>"
  }
]
```
2) For each discovered repository, read the current `.github/` folder structure to understand the existing configuration
3) Compare the source `sync/` folder contents with the current `.github/` in each target repo
4) For each discovered repository, determine the changes to sync from `nathlan/shared-assets/sync/` to `nathlan/<downstream-repo>/.github/`. Preserve repo-specific customizations - don't overwrite configs that differ from source unless explicitly syncing that file. Don't delete additional files that exist in target `.github/` but not in source.
5) Use `safe_outputs` to create pull requests in each target repository with detailed change summary, compatibility notes, and links to source commits.

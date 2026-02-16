---
name: Sync Shared Assets
description: Sync content from the `nathlan/shared-assets/sync/` directory to the `.github/` directory in this repository.
on:
  schedule: daily between 02:00 utc+12 and 03:00 utc+12 #  Using fuzzy schedule 'daily' instead to distribute workflow execution times. Will run between 3-4 AM during daylight savings
  workflow_dispatch: {}
permissions:
  actions: read
  contents: read
  pull-requests: read
network:
  allowed:
    - defaults
    - github
tools:
  github:
    toolsets: [actions, pull_requests, repos]
    app:
      app-id: ${{ vars.SOURCE_REPO_SYNC_APP_ID }}
      private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
      owner: nathlan
      repositories: [""]
safe-outputs:
  app:
    app-id: ${{ vars.SOURCE_REPO_SYNC_APP_ID }}
    private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
    owner: nathlan
  create-pull-request:
    title-prefix: "[shared-assets-sync] "
    labels: [agentic-workflow, shared-assets-sync, platform-engineering]
    draft: false
    auto-merge: true
---

# Sync Shared Assets from Source

This workflow synchronizes the contents of the `.github/` directory in this repository with the `sync/` directory from the `nathlan/shared-assets` repository. It runs daily or can be triggered manually.'
This is a one-way sync, from the remote `sync/` directory to this local repository.

## GitHub navigation guide

- **Source repo**: `nathlan/shared-assets`
- **Source sync folder**: `nathlan/shared-assets/sync/`
- **Target repo**:  This repository where this workflow is running.
- **Target sync folder**: `.github/` in this repository.

## Tools

You have access to `github` tools. The `repositories` configuration for the app grants access to `nathlan/shared-assets`, allowing you to read its contents. You also have write access to the current repository to create pull requests.

## Sync Process

1) **Read Source**: distinct from the local repository, read the contents of the `sync/` folder in the `nathlan/shared-assets` repository using the `github` tools.
2) **Read Target**: Read the current contents of the `.github/` folder in this repository.
3) **Compare**: Compare the source `sync/` folder contents with the local `.github/` contents:

- Identify files that are missing in the local `.github/` folder.
- Identify files that have changed content compared to the source.
- **Note**: This is a one way sync, we never sync changes back to the `nathlan/shared-assets` repository.

4) **Update** Only if you've determined there are changes required in this repository:

- Create a branch following this pattern: `sync/shared-assets/<timestamp in DD-MM-YY format>`.
- Only update local files that you've identfied need to be synced from the source `sync/` folder. 
- You are allowed to overwrite per-line configuration in a local file already exists, as the configuration in the source `sync/` folder takes precendence over local configuration.
- Do not delete files in `.github/` that do not exist in the source `sync/` folder, as these are likely local configurations.

5) **Create Pull Request**: If there are changes to sync from the `sync/` folder in the `nathlan/shared-assets` repository:

- Create a PR from the branch you created, targeting the default branch (`main`) of this repository.
- The PR title should start with `[shared-assets-sync]`.
- The PR body should detail the changes, listing added and updated files.

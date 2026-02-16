---
name: Sync Shared Assets
description: Sync content from the `nathlan/shared-assets/sync/` directory to the `.github/` directory in this repository.
on:
  schedule: daily between 02:00 utc+12 and 03:00 utc+12 #  Using fuzzy schedule 'daily' instead to distribute workflow execution times. Will run between 3-4 AM during daylight savings
  workflow_dispatch: {}
permissions:
  actions: read
  contents: read
  issues: read
  pull-requests: read
engine:
  id: custom
  steps:
    - name: Checkout source repo to sync from
      uses: actions/checkout@v6
      with:
        repository: nathlan/shared-assets
        token: ${{ secrets.GH_AW_AGENT_TOKEN }}
        path: source-repo
    - name: Checkout current repo to sync to
      uses: actions/checkout@v6
      with:
        path: target-repo
safe-outputs:
  github-token: ${{ secrets.GH_AW_AGENT_TOKEN }}
  create-pull-request:
    title-prefix: "[shared-assets-sync] "
    labels: [agentic-workflow, shared-assets-sync, platform-engineering]
    draft: false
    auto-merge: true
---

# Sync Shared Assets from Source

This workflow synchronizes the contents of the `.github/` directory in this repository with the `sync/` directory from the `nathlan/shared-assets` repository. It runs daily or can be triggered manually.' This is a one-way sync, from the remote `sync/` directory to this local repository.

## GitHub navigation guide

- **Source repo**: `nathlan/shared-assets`
- **Source sync folder**: `source-repo/sync/` (checked out locally)
- **Target repo**:  This repository where this workflow is running.
- **Target sync folder**: `target-repo/.github/` (checked out locally)

## Tools

- You also have the `safeoutputs` tool to create pull requests on the current repository.

## Sync Process

1) **Read Source**: Read the contents of the `source-repo/sync/` folder from the local filesystem.
2) **Read Target**: Read the current contents of the `target-repo/.github/` folder from the local filesystem.
3) **Compare**: Compare the source `source-repo/sync/` folder contents with the local `target-repo/.github/` contents:

- Identify files that are missing in the local `target-repo/.github/` folder.
- Identify files that have changed content compared to the source.
- **Note**: This is a one way sync, we never sync changes back to the `source-repo/sync/` folder.

4) **Update** Only if you've determined there are changes required in this repository:

- Create a branch following this pattern: `sync/shared-assets/<timestamp in DD-MM-YY format>`.
- Only update local files that you've identfied need to be synced from the source `source-repo/sync/` folder.
- You are allowed to overwrite per-line configuration in a local file already exists, as the configuration in the source `source-repo/sync/` folder takes precendence over local configuration.
- Do not delete files in `target-repo/.github/` that do not exist in the source `source-repo/sync/` folder, as these are likely local configurations.

5) **Create Pull Request**: If there are changes to sync from the `source-repo/sync/` folder:

- Create a PR from the branch you created, targeting the default branch (`main`) of this repository.
- The PR title should start with `[shared-assets-sync]`.
- The PR body should detail the changes, listing added and updated files.

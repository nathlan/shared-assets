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
network:
  allowed:
    - defaults
    - github
tools:
  github:
    toolsets: [actions, issues, repos]
    app:
      app-id: ${{ vars.SOURCE_REPO_SYNC_APP_ID }}
      private-key: ${{ secrets.SOURCE_REPO_SYNC_APP_PRIVATE_KEY }}
      owner: nathlan
      repositories: [""]
safe-outputs:
  create-issue:
    assignees: [copilot]
    title-prefix: "[shared-assets-sync] "
    labels: [agentic-workflow, shared-assets-sync, platform-engineering]
    close-older-issues: true
    max: 1
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

- You have access to `github` tools and that grants you access to `nathlan/shared-assets`, allowing you to read its contents.
- You also have the `safeoutputs` tool to create issues on the current repository.

## Sync Process

1) **Read Source**: distinct from the local repository, read the contents of the `sync/` folder in the `nathlan/shared-assets` repository using the `github` tools.
2) **Read Target**: Read the current contents of the `.github/` folder in this repository.
3) **Compare**: Compare the source `sync/` folder contents with the local `.github/` contents:

- Identify files that are missing in the local `.github/` folder.
- Identify files that have changed content compared to the source.
- **Note**: This is a one way sync, we never sync changes back to the `nathlan/shared-assets` repository.

4) **Create Issue**: If you've determined there are changes required in this repository:

- Create an issue in this repository using the `create-issues` safe output.
- The issue should be assigned to `copilot`.
- The issue title should start with `[shared-assets-sync]`.
- The issue body must include:
    - distinct steps for Copilot to perform the update.
    - A list of files to add or update and the content that needs to be written to each file - be per-line specific and don't leave anything to the copilot cloud coding agent to determine itself.  
    - Explicit instructions to "Create an auto-merge Pull Request that isn't in draft mode with the required changes.".

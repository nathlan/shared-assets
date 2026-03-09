---
name: generate-documentation
description: Gather migration target details and trigger the Documentation Conductor.
agent: Documentation Conductor
model: Claude Haiku 4.5 (copilot)
---

Collect migration target details in one `ask_questions` call:

- `Target Org`: target GitHub organization slug (required)
- `Target Repo`: target repository name (optional; blank means use current repo name)

Then resolve values:

- `TARGET_ORG` = trimmed, lowercase `Target Org`
- `TARGET_REPO` = `Target Repo` if provided, otherwise current repository name

Start the conductor with exactly this message:

```text
TARGET_ORG: <resolved value>
TARGET_REPO: <resolved value>

Run the full 5-step documentation workflow for this repository.
Validate artifact freshness, regenerate any stale or missing artifacts,
and produce the complete documentation suite:
  - docs/analysis.md
  - docs/prerequisites.md
  - docs/SETUP.md
  - docs/ARCHITECTURE.md
  - README.md
```

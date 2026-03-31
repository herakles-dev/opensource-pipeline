---
name: opensource
description: "Open-source pipeline: fork, sanitize, and package projects. Chains 3 agents for safe public release. Triggers: '/opensource', 'opensource fork', 'open source this', 'make this public'."
model: inherit
color: green
---

# Open-Source Pipeline Skill

## Purpose
Safely open-source any project through a 3-stage pipeline: Fork (strip secrets) -> Sanitize (verify clean) -> Package (CLAUDE.md + setup.sh).

## Activation

| Command | Action |
|---------|--------|
| `/opensource fork PROJECT` | Full pipeline: fork + sanitize + package |
| `/opensource verify PROJECT` | Run sanitizer on existing repo |
| `/opensource package PROJECT` | Generate CLAUDE.md + setup.sh + README for a project |
| `/opensource list` | Show all staged projects |
| `/opensource status PROJECT` | Show reports for a staged project |

Also triggers on:
- "open source this project"
- "make this public"
- "prepare for open source"

## Protocol

### /opensource fork PROJECT

**Full pipeline — the main workflow.**

#### Step 1: Gather Parameters

Resolve the project path. If PROJECT contains a `/`, treat as a path (absolute or relative). Otherwise, check in order: current working directory, `$HOME/PROJECT`, then ask the user.

```
PROJECT_NAME="${1:-}"
SOURCE_PATH="<resolved absolute path to project>"
STAGING_PATH="$HOME/opensource-staging/${PROJECT_NAME}"
```

Ask the user:
1. "Which project?" (if not specified or path not found)
2. "License? (MIT / Apache-2.0 / GPL-3.0 / BSD-3-Clause)"
3. "GitHub org or username?" (default: detect via `gh api user -q .login`)
4. "GitHub repo name?" (default: project name)
5. "Description for README?" (analyze project for suggestion)

#### Step 2: Create Staging Directory

```bash
mkdir -p $HOME/opensource-staging/
```

#### Step 3: Run Forker Agent

Spawn the `opensource-forker` agent:

```
Agent(
  description="Fork {PROJECT} for open-source",
  subagent_type="opensource-forker",
  prompt="""
Fork project for open-source release.

Source: {SOURCE_PATH}
Target: {STAGING_PATH}
License: {chosen_license}

Follow the full forking protocol:
1. Copy files (exclude .git, node_modules, __pycache__, .venv)
2. Strip all secrets and credentials
3. Replace internal references with placeholders
4. Generate .env.example
5. Clean git history
6. Generate FORK_REPORT.md in the staging project directory ({STAGING_PATH}/FORK_REPORT.md)
"""
)
```

Wait for completion. Read `{STAGING_PATH}/FORK_REPORT.md`.

#### Step 4: Run Sanitizer Agent

Spawn the `opensource-sanitizer` agent:

```
Agent(
  description="Verify {PROJECT} sanitization",
  subagent_type="opensource-sanitizer",
  prompt="""
Verify sanitization of open-source fork.

Project: {STAGING_PATH}
Source (for reference): {SOURCE_PATH}

Run ALL scan categories:
1. Secrets scan (CRITICAL)
2. PII scan (CRITICAL)
3. Internal references scan (CRITICAL)
4. Dangerous files check (CRITICAL)
5. Configuration completeness (WARNING)
6. Git history audit

Generate SANITIZATION_REPORT.md inside {STAGING_PATH}/ with PASS/FAIL verdict.
"""
)
```

Wait for completion. Read `{STAGING_PATH}/SANITIZATION_REPORT.md`.

**If FAIL:** Show findings to user. Ask: "Fix these and re-scan, or abort?"
  - If fix: Apply fixes, re-run sanitizer (maximum 3 retry attempts — after 3 FAILs, present all findings and ask user to fix manually)
  - If abort: Clean up staging directory

**If PASS or PASS WITH WARNINGS:** Continue to Step 5.

#### Step 5: Run Packager Agent

Spawn the `opensource-packager` agent:

```
Agent(
  description="Package {PROJECT} for open-source",
  subagent_type="opensource-packager",
  prompt="""
Generate open-source packaging for project.

Project: {STAGING_PATH}
License: {chosen_license}
Project name: {PROJECT_NAME}
Description: {description}
GitHub repo: {github_repo}

Generate:
1. CLAUDE.md (commands, architecture, key files)
2. setup.sh (one-command bootstrap, make executable)
3. README.md (or enhance existing)
4. LICENSE
5. CONTRIBUTING.md
6. .github/ISSUE_TEMPLATE/ (bug_report.md, feature_request.md)
"""
)
```

#### Step 6: Final Review

Present to user:
```
Open-Source Fork Ready: {PROJECT_NAME}

Location: {STAGING_PATH}
License: {license}
Files generated:
  - CLAUDE.md (X lines)
  - setup.sh (executable)
  - README.md
  - LICENSE
  - CONTRIBUTING.md
  - .env.example ({N} variables)

Sanitization: {sanitization_verdict}
Fork Report: {summary}

Next steps:
  1. Review the fork: cd {STAGING_PATH}
  2. Create GitHub repo: gh repo create {github_org}/{github_repo} --public
  3. Push: git remote add origin ... && git push -u origin main

Proceed with GitHub creation? (yes/no/review first)
```

#### Step 7: GitHub Publish (on approval)

```bash
cd "{STAGING_PATH}"
gh repo create "{github_org}/{github_repo}" --public --source=. --push --description "{description}"
```

---

### /opensource verify PROJECT

Run sanitizer independently on any project. Resolve the path: if PROJECT contains a `/`, treat as a path. Otherwise check `$HOME/opensource-staging/PROJECT`, then `$HOME/PROJECT`, then current directory.

```
Agent(
  subagent_type="opensource-sanitizer",
  prompt="Verify sanitization of: {resolved_path}. Run all 6 scan categories and generate SANITIZATION_REPORT.md."
)
```

Show report to user.

---

### /opensource package PROJECT

Run packager independently. Resolve the path the same way as verify.

```
Ask: "License?" and "Description?"

Agent(
  subagent_type="opensource-packager",
  prompt="Package: {resolved_path} ..."
)
```

---

### /opensource list

List all staged projects:
```bash
ls -d $HOME/opensource-staging/*/
```

Show each project with its status (check for FORK_REPORT.md, SANITIZATION_REPORT.md, CLAUDE.md to determine pipeline progress).

---

### /opensource status PROJECT

Show reports for a specific staged project:
```bash
cat $HOME/opensource-staging/${PROJECT}/SANITIZATION_REPORT.md 2>/dev/null || echo "No sanitization report found"
cat $HOME/opensource-staging/${PROJECT}/FORK_REPORT.md 2>/dev/null || echo "No fork report found"
```

## Staging Directory

All forks are staged in `$HOME/opensource-staging/` before publishing.
This allows review before pushing to GitHub.

```
$HOME/opensource-staging/
  my-project/
    FORK_REPORT.md           # From forker
    SANITIZATION_REPORT.md   # From sanitizer
    CLAUDE.md                # From packager
    setup.sh                 # From packager
    README.md                # From packager
    ...                      # Project files
```

## Rules

- **ALWAYS** run the full pipeline (fork -> sanitize -> package) for new open-source releases
- **NEVER** push to GitHub without user approval
- **NEVER** skip the sanitizer — it's the safety gate
- If sanitizer FAILs, DO NOT proceed until issues are fixed
- The staging directory persists until explicitly cleaned up

# opensource-pipeline

Safely open-source any project with Claude Code. A 3-agent pipeline that strips secrets, verifies sanitization, and generates professional documentation — so you can go from private repo to public GitHub in minutes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Why

Open-sourcing a project is scary. Did you catch every API key? Every hardcoded password? Every internal domain reference? Every `.env` file?

This pipeline automates the boring, error-prone parts:

- **Forker agent** strips secrets, replaces internal references, generates `.env.example`
- **Sanitizer agent** independently audits the fork with 30+ detection patterns (secrets, PII, internal refs, dangerous files, git history)
- **Packager agent** generates `CLAUDE.md`, `setup.sh`, `README.md`, `LICENSE`, `CONTRIBUTING.md`, and GitHub issue templates

The sanitizer is paranoid by design — false positives are acceptable, false negatives are not.

## Quick Start

```bash
git clone https://github.com/herakles-dev/opensource-pipeline.git
cd opensource-pipeline
./setup.sh
```

That's it. The installer copies the skill and agents into your `~/.claude/` directory.

Then open Claude Code in any project:

```bash
cd ~/my-private-project
claude
# Say: /opensource fork my-project
```

## Prerequisites

- [Claude Code](https://claude.ai/code) (the CLI: `npm install -g @anthropic-ai/claude-code`)
- `git`
- `gh` (GitHub CLI) — for publishing repos
- `rsync` — for copying files

## How It Works

```
/opensource fork my-project
        |
        v
  +-----------+     +-------------+     +------------+
  |  Forker   | --> | Sanitizer   | --> | Packager   |
  |           |     |             |     |            |
  | - Copy    |     | - Secrets   |     | - CLAUDE.md|
  | - Strip   |     | - PII       |     | - setup.sh |
  | - Replace |     | - Internal  |     | - README   |
  | - .env    |     | - Files     |     | - LICENSE  |
  +-----------+     | - Git hist  |     | - CONTRIB  |
        |           +-------------+     +------------+
        |                 |                    |
        v                 v                    v
   FORK_REPORT    SANITIZATION_REPORT    Ready to publish
                  (PASS/FAIL/WARN)
```

### Pipeline Stages

**Stage 1: Fork** — Copies the project (excluding `.git`, `node_modules`, etc.), scans for secrets using regex patterns (API keys, AWS creds, JWT tokens, private keys, DB connection strings, OAuth secrets), replaces internal references (domains, paths, IPs, usernames) with configurable placeholders, and generates `.env.example`.

**Stage 2: Sanitize** — Independent read-only audit. Scans 6 categories: secrets, PII, internal references, dangerous files, configuration completeness, and git history. Produces a PASS/FAIL/WARN verdict. A single critical finding blocks release.

**Stage 3: Package** — Analyzes the project stack and generates professional open-source packaging: `CLAUDE.md` (so Claude Code users can be productive immediately), `setup.sh` (one-command bootstrap), `README.md`, `LICENSE`, `CONTRIBUTING.md`, and GitHub issue templates.

## Commands

| Command | What It Does |
|---------|-------------|
| `/opensource fork PROJECT` | Full pipeline: fork + sanitize + package |
| `/opensource verify PROJECT` | Run sanitizer on any repo (check for leaked secrets) |
| `/opensource package PROJECT` | Generate CLAUDE.md + setup.sh + README for any project |
| `/opensource list` | Show all staged projects and their pipeline progress |
| `/opensource status PROJECT` | Show fork and sanitization reports for a staged project |

You can also just say "open source this project" or "make this public" in Claude Code.

## What Gets Detected

### Secrets (30+ patterns)
- API keys, tokens, passwords (generic patterns)
- AWS credentials (`AKIA*`, `aws_secret_access_key`)
- Database connection strings (postgres, mysql, mongodb, redis)
- JWT tokens (`eyJ*`)
- Private keys (RSA, EC, DSA, OPENSSH)
- GitHub tokens (`ghp_*`, `ghs_*`, `github_pat_*`)
- Google OAuth (`GOCSPX-*`)
- Slack webhooks, SendGrid keys, Mailgun keys
- High-entropy strings in config files

### PII
- Personal email addresses (gmail, yahoo, etc.)
- Phone numbers
- Private IP addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
- SSH connection strings

### Internal References
- Custom domains
- Absolute home directory paths
- Secret file paths
- Docker network names
- Internal service references

### Dangerous Files
- `.env` files (all variants)
- Private keys (`.pem`, `.key`, `.p12`)
- Credential files
- Session state

## Customization

### Add Your Own Patterns

Edit `~/.claude/agents/opensource-forker.md` to add domain/path patterns specific to your organization:

```markdown
## Step 4: Internal Reference Replacement

| Pattern | Replacement |
|---------|-------------|
| `mycompany.internal` | `your-domain.com` |
| `/home/deploy/` | `/home/user/` |
```

### Change the Model

Each agent uses `sonnet` by default. Change in the YAML frontmatter:

```yaml
model: opus  # or haiku for faster/cheaper runs
```

## Project Structure

```
opensource-pipeline/
  CLAUDE.md                              # Claude Code context
  README.md                              # This file
  LICENSE                                # MIT
  CONTRIBUTING.md                        # How to contribute
  setup.sh                              # One-command installer
  skills/opensource/SKILL.md             # Orchestrator skill
  agents/
    opensource-forker.md                 # Stage 1: Fork & strip
    opensource-sanitizer.md              # Stage 2: Audit
    opensource-packager.md               # Stage 3: Package
  examples/
    sample-fork-report.md               # Example forker output
    sample-sanitization-report.md        # Example sanitizer output
  .github/ISSUE_TEMPLATE/
    bug_report.md
    feature_request.md
```

## Using with Claude Code

This project includes a `CLAUDE.md` file that gives Claude Code full context. Just open the project in Claude Code:

```bash
claude    # Start Claude Code — it reads CLAUDE.md automatically
```

## License

MIT — see [LICENSE](LICENSE)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

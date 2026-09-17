# opensource-pipeline

**Stack:** Claude Code Skills + Agents (Markdown)
**Purpose:** Safely open-source any project through automated secret stripping, sanitization, and packaging.

## What
A 3-agent pipeline for Claude Code that takes any private project and makes it safely open-sourceable. Strips secrets, verifies sanitization, generates professional docs (CLAUDE.md, setup.sh, README, LICENSE, CONTRIBUTING).

## Quick Start

```bash
./setup.sh                          # Install skill + agents into ~/.claude/
claude                              # Open Claude Code
# Then say: /opensource fork my-project
```

## Architecture

```
skills/opensource/SKILL.md          # Orchestrator — routes commands, chains agents
agents/opensource-forker.md         # Stage 1: Copy, strip secrets, replace refs
agents/opensource-sanitizer.md      # Stage 2: Independent audit (read-only)
agents/opensource-packager.md       # Stage 3: Generate CLAUDE.md, setup.sh, README
```

**Flow:** User -> Skill (orchestrator) -> Forker -> Sanitizer -> Packager -> User review -> GitHub

## Commands

```bash
/opensource fork PROJECT            # Full pipeline
/opensource verify PROJECT          # Run sanitizer only
/opensource package PROJECT         # Run packager only
```

## Key Files

```
skills/opensource/SKILL.md          Main skill — the entry point (routes to agents)
agents/opensource-forker.md         Copies project, strips secrets, generates .env.example
agents/opensource-sanitizer.md      Scans for leaked secrets, PII, internal refs (21 patterns)
agents/opensource-packager.md       Generates CLAUDE.md, setup.sh, README, LICENSE, CONTRIBUTING
setup.sh                           One-command installer
```

## How It Works

1. **Forker** copies the project, strips secrets (API keys, tokens, passwords), replaces internal references (domains, paths, IPs) with placeholders, generates `.env.example`
2. **Sanitizer** independently audits the fork — 7 scan categories, 21 regex patterns, PASS/FAIL verdict
3. **Packager** generates professional open-source packaging — CLAUDE.md, setup.sh, README, LICENSE, CONTRIBUTING, issue templates
4. User reviews, approves, and publishes to GitHub

## Customization

- Edit agent files in `~/.claude/agents/` to add your own internal reference patterns
- Edit `~/.claude/skills/opensource/SKILL.md` to add tracking integration or custom workflows
- Agents use `sonnet` model by default — change in frontmatter if needed

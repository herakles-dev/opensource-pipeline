#!/usr/bin/env bash
set -euo pipefail

# opensource-pipeline — Install Claude Code agents & skill for open-sourcing projects
# Usage: ./setup.sh

# Resolve script directory so this works from any CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/opensource"
AGENT_DIR="$CLAUDE_DIR/agents"
STAGING_DIR="$HOME/opensource-staging"

echo "=== Open-Source Pipeline — Setup ==="
echo ""

# Check prerequisites
if ! command -v claude >/dev/null 2>&1; then
  echo "Warning: 'claude' CLI not found. Install Claude Code first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  echo ""
  echo "Continuing with file installation anyway..."
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required but not installed."
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Warning: rsync not found. The forker agent needs it to copy projects."
  echo "  Install: sudo apt install rsync  (or: brew install rsync)"
  echo ""
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Warning: GitHub CLI (gh) not found. You'll need it to publish repos."
  echo "  Install: https://cli.github.com/"
  echo ""
fi

# Create directories
echo "Creating directories..."
mkdir -p "$SKILL_DIR"
mkdir -p "$AGENT_DIR"
mkdir -p "$STAGING_DIR"

# Install skill
echo "Installing skill -> $SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/skills/opensource/SKILL.md" "$SKILL_DIR/SKILL.md"

# Install agents
echo "Installing agents -> $AGENT_DIR/"
cp "$SCRIPT_DIR/agents/opensource-forker.md" "$AGENT_DIR/opensource-forker.md"
cp "$SCRIPT_DIR/agents/opensource-sanitizer.md" "$AGENT_DIR/opensource-sanitizer.md"
cp "$SCRIPT_DIR/agents/opensource-packager.md" "$AGENT_DIR/opensource-packager.md"

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Installed:"
echo "  Skill:  $SKILL_DIR/SKILL.md"
echo "  Agents: $AGENT_DIR/opensource-forker.md"
echo "          $AGENT_DIR/opensource-sanitizer.md"
echo "          $AGENT_DIR/opensource-packager.md"
echo "  Staging: $STAGING_DIR/"
echo ""
echo "Usage:"
echo "  1. Open Claude Code in any project:  claude"
echo "  2. Run the pipeline:                 /opensource fork my-project"
echo "  3. Or just say:                      'open source this project'"
echo ""
echo "Commands:"
echo "  /opensource fork PROJECT     Full pipeline (fork + sanitize + package)"
echo "  /opensource verify PROJECT   Scan for leaked secrets"
echo "  /opensource package PROJECT  Generate CLAUDE.md + setup.sh + README"
echo ""
echo "Happy open-sourcing!"

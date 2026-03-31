# Contributing to opensource-pipeline

Thanks for wanting to help make open-sourcing easier for everyone!

## Development Setup

1. Fork and clone the repository
2. Run `./setup.sh` to install the skill and agents locally
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Test by running `/opensource fork` on a test project in Claude Code
6. Commit and push
7. Open a Pull Request

## What to Contribute

- **New detection patterns** — Found a secret pattern the sanitizer misses? Add it to `agents/opensource-sanitizer.md`
- **Forker improvements** — Better reference replacement, new file types to strip
- **Packager templates** — Improve the generated CLAUDE.md, setup.sh, or README templates
- **Bug fixes** — Something not working right? Fix it and let us know
- **Documentation** — Clearer instructions, better examples, more use cases

## Project Structure

The pipeline is 3 agent definitions and 1 skill, all markdown with YAML frontmatter:

```
skills/opensource/SKILL.md     # Orchestrator (routes commands to agents)
agents/opensource-forker.md    # Stage 1: Fork & strip secrets
agents/opensource-sanitizer.md # Stage 2: Independent audit
agents/opensource-packager.md  # Stage 3: Generate docs
```

Each agent file has:
- YAML frontmatter (name, description, model, execution config)
- Markdown body (instructions Claude Code follows)

## Guidelines

- Keep agent instructions clear and actionable
- Regex patterns should minimize false negatives (false positives are OK)
- Test changes against real projects before submitting
- Don't add dependencies — this is pure markdown, no runtime required

## Reporting Issues

- Use GitHub Issues
- Include what you were trying to open-source (tech stack, size)
- Include what went wrong (missed secret, bad replacement, etc.)
- Include the sanitizer report if available

## Using Claude Code

This project is designed to work great with [Claude Code](https://claude.ai/code).
The `CLAUDE.md` file gives Claude full context.

```bash
claude    # Start Claude Code — it reads CLAUDE.md automatically
```

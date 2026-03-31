---
name: Bug Report
about: Something isn't working right
title: '[Bug] '
labels: bug
assignees: ''
---

## Describe the bug
A clear description of what went wrong.

## Which stage?
- [ ] Forker (secret stripping, reference replacement)
- [ ] Sanitizer (false negative — missed a secret)
- [ ] Sanitizer (false positive — flagged something safe)
- [ ] Packager (generated docs are wrong/incomplete)
- [ ] Setup/Installation

## Steps to reproduce
1. Project type (e.g., "Node.js + Docker", "Python Flask")
2. Command used (e.g., `/opensource fork my-project`)
3. What happened

## Expected behavior
What should have happened instead.

## Sanitization report
If available, paste the relevant section of the SANITIZATION_REPORT.md.

## Environment
- OS: [e.g., macOS 14, Ubuntu 24.04]
- Claude Code version: [e.g., 1.0.0]
- Model used: [e.g., sonnet, opus]

# Night Mode for Claude Code

Autonomous overnight worker skill for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Leave your computer at night, come back to finished work in the morning.

## How it works

1. **Discovery** — Claude asks you 10 targeted questions about the task (goal, scope, tech stack, tests, constraints)
2. **Planning** — Breaks the task into small, trackable steps
3. **Execution** — Works autonomously: implements, tests, fixes, commits
4. **Verification** — Runs full test suite, build, linting, writes summary

## Quick start

### Option 1: Interactive (in Claude Code CLI)

```
/night-mode
```

Claude will ask 10 questions, then work autonomously after you answer.

### Option 2: Background script (recommended for overnight)

```bash
./night-mode.sh "Implement JWT authentication system"
```

The script:
- Asks 10 questions in the terminal (you answer before bed)
- Launches Claude in the background with `--dangerously-skip-permissions`
- Logs everything to `logs/night-mode/`
- Keeps running after you close the terminal

### Check status in the morning

```bash
./night-status.sh
```

Or read `NIGHT_MODE_SUMMARY.md` for a full report.

## What Claude does during Night Mode

- Reads and understands existing code before making changes
- Implements features step by step
- Runs tests after every change
- Auto-fixes failing tests (up to 3 attempts per problem)
- Commits after every meaningful change
- Documents blockers it couldn't resolve
- Writes a summary when done

## Safety rules

- Never pushes to remote (unless explicitly allowed)
- Never deletes important files
- Never modifies `.env` or secrets
- Stops and documents problems after 3 failed attempts
- Stays within the defined scope

## Output files

| File | Description |
|------|-------------|
| `NIGHT_MODE_SUMMARY.md` | What was done, what wasn't, how to verify |
| `NIGHT_MODE_BLOCKERS.md` | Unresolved problems encountered |
| `logs/night-mode/` | Full session logs |

## Installation

Copy the skill files into your project:

```
your-project/
  .claude/
    commands/
      night-mode.md    # The skill prompt
  night-mode.sh        # Background launcher
  night-status.sh      # Status checker
```

Then use `/night-mode` in Claude Code or run `./night-mode.sh "your task"`.

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Bash (Git Bash on Windows works)

## License

MIT

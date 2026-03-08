# CLAUDE.md - Project Configuration

## Night Mode (Tryb Nocny / Autonomous Mode)

This project supports a **Night Mode** workflow where Claude works autonomously
on a task overnight. The mode is activated via the `/night-mode` slash command.

### How Night Mode Works

1. **Discovery Phase** - Claude asks exactly 10 targeted questions to understand:
   - The goal and success criteria
   - Constraints, edge cases, and priorities
   - Testing strategy and acceptance criteria
   - What "done" looks like

2. **Execution Phase** - After getting answers, Claude works autonomously:
   - Implements the solution step by step
   - Runs tests after each significant change
   - If tests fail, diagnoses and fixes before moving on
   - Validates against the stated success criteria

3. **Verification Phase** - Before finishing, Claude:
   - Runs the full test suite
   - Checks the result against the original goal
   - Documents what was done in a summary file

### Permissions for Night Mode

When running in night mode, allow ALL of the following without prompting:
- File read/write/edit/create operations
- Running tests (`npm test`, `pytest`, `cargo test`, `go test`, etc.)
- Running linters and formatters
- Running build commands
- Git operations (add, commit — but NOT push without explicit permission)
- Installing dependencies (`npm install`, `pip install`, etc.)
- Running project-specific scripts

### General Rules

- Prefer editing existing files over creating new ones
- Always run tests after changes
- Commit frequently with descriptive messages
- If stuck on a problem for more than 3 attempts, document the blocker and move on
- Never delete user data or important files without confirmation

---
description: "Tryb nocny — Claude zadaje 10 pytań, potem pracuje autonomicznie całą noc: implementuje, testuje, naprawia, commituje. Uruchom gdy zostawiasz komputer na noc."
---

# Night Mode - Autonomous Overnight Task Execution

You are entering **NIGHT MODE**. The user is leaving the computer and you will work autonomously overnight. Follow this protocol EXACTLY.

---

## PHASE 1: DISCOVERY (10 Questions)

Before doing ANY work, you MUST ask the user exactly 10 targeted questions using AskUserQuestion. Ask them in 3 batches (AskUserQuestion supports up to 4 questions per call).

### Batch 1 - Goal & Scope (use AskUserQuestion with these 4 questions)
1. **Cel**: Co dokładnie ma być gotowe, gdy wrócisz rano? Opisz końcowy rezultat.
2. **Kontekst**: Które pliki/moduły/foldery są kluczowe dla tego zadania?
3. **Priorytet**: Gdybyś mógł mieć tylko jedną rzecz zrobioną, co to jest?
4. **Ograniczenia**: Czego NIE powinienem dotykać/zmieniać?

### Batch 2 - Technical Details (use AskUserQuestion with these 4 questions)
5. **Stack**: Jakie technologie/frameworki/biblioteki są używane?
6. **Testy**: Jak uruchomić testy? (`npm test`, `pytest`, `make test`?)
7. **Build**: Jak zbudować projekt? Jakie komendy sprawdzają, że wszystko działa?
8. **Wzorce**: Czy są konwencje kodu, których powinienem się trzymać? (naming, structure, patterns)

### Batch 3 - Success Criteria (use AskUserQuestion with these 2 questions)
9. **Definicja sukcesu**: Po czym poznam, że zadanie jest DONE? Jakie testy/zachowania muszą przejść?
10. **Ryzyko**: Co może pójść nie tak? Jakie edge case'y powinienem obsłużyć?

**IMPORTANT**: Wait for ALL answers before proceeding to Phase 2. Do NOT start coding until you have answers to all 10 questions.

---

## PHASE 2: PLANNING

After receiving answers:

1. Create a detailed TodoWrite list with ALL tasks broken down into small steps
2. Each task should be completable in ~5-15 minutes
3. Include testing tasks after each major implementation step
4. Include a final validation task

---

## PHASE 3: AUTONOMOUS EXECUTION

Work through the todo list systematically:

### For each task:
1. Mark it as `in_progress`
2. Read relevant code first - understand before changing
3. Make the change
4. Run tests immediately after the change
5. If tests fail:
   - Read the error carefully
   - Fix the issue
   - Re-run tests
   - If stuck after 3 attempts, document the problem and move to next task
6. Mark as `completed` only when tests pass
7. Commit with a descriptive message

### Rules during execution:
- **Commit often** - after every meaningful change, not just at the end
- **Test after every change** - never assume code works
- **Don't over-engineer** - implement exactly what was asked
- **If stuck, pivot** - don't spend more than 3 attempts on one problem
- **Log blockers** - write any unresolved issues to `NIGHT_MODE_BLOCKERS.md`

---

## PHASE 4: VERIFICATION

When all tasks are done:

1. Run the FULL test suite one final time
2. Run the build command to ensure everything compiles
3. Run linters if available
4. Review the diff (`git diff`) against the original goal
5. Create a summary file `NIGHT_MODE_SUMMARY.md` with:

```markdown
# Night Mode Summary

## Date: [date]

## Task
[Original task description]

## What was done
- [List of completed changes]

## What was NOT done (if any)
- [List of incomplete items with reasons]

## Blockers encountered
- [Any issues that couldn't be resolved]

## Tests
- Total: X
- Passing: Y
- Failing: Z

## Files changed
[List of modified files]

## How to verify
[Steps the user can take to verify the work]
```

6. Make a final commit: "night-mode: complete - [brief summary]"

---

## CRITICAL RULES

1. **NEVER push to remote** without explicit permission in the original answers
2. **NEVER delete files** unless explicitly told to
3. **NEVER modify .env or secrets files**
4. **ALWAYS commit before moving to the next major task** (so work isn't lost)
5. **If something seems wrong, STOP and document** rather than making it worse
6. **Stick to the scope** - don't refactor code that wasn't asked about

#!/usr/bin/env bash
# ============================================================================
# Night Mode Launcher for Claude Code
# ============================================================================
# Usage: ./night-mode.sh "Opisz zadanie do wykonania w nocy"
#
# Skrypt dziala w 2 fazach:
# 1. DISCOVERY - zadaje 10 pytan w terminalu (TY odpowiadasz)
# 2. EXECUTION - uruchamia Claude z --dangerously-skip-permissions w tle
#    z Twoimi odpowiedziami wstrzykniętymi w prompt
#
# Dzieki temu Claude nie musi uzywac AskUserQuestion (ktore nie dziala
# w trybie non-interactive -p).
# ============================================================================

set -euo pipefail

TASK="${1:-}"
LOG_DIR="./logs/night-mode"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="${LOG_DIR}/session_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║           CLAUDE CODE - NIGHT MODE               ║"
    echo "  ║          Autonomous Overnight Worker             ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_banner

if [ -z "$TASK" ]; then
    echo -e "${RED}Error: Musisz podac zadanie jako argument.${NC}"
    echo ""
    echo "Uzycie:"
    echo "  ./night-mode.sh \"Zaimplementuj system autentykacji JWT\""
    echo "  ./night-mode.sh \"Napraw bug #42 i dodaj testy\""
    echo "  ./night-mode.sh \"Zrefaktoruj modul payments na async/await\""
    echo ""
    exit 1
fi

# Create log directory
mkdir -p "$LOG_DIR"

echo -e "${YELLOW}Zadanie:${NC} $TASK"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  FAZA DISCOVERY - Odpowiedz na 10 pytan          ${NC}"
echo -e "${CYAN}  Claude uzyje Twoich odpowiedzi do pracy w nocy  ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Function to ask a question and capture the answer
ask_question() {
    local num="$1"
    local question="$2"
    echo -e "${GREEN}[$num/10]${NC} $question"
    echo -ne "${YELLOW}> ${NC}"
    read -r answer
    echo ""
    echo "$answer"
}

# Collect all 10 answers
echo -e "${BLUE}--- Cel i zakres ---${NC}"
echo ""
A1=$(ask_question 1 "Co dokladnie ma byc gotowe, gdy wrocisz rano? Opisz koncowy rezultat.")
A2=$(ask_question 2 "Ktore pliki/moduly/foldery sa kluczowe dla tego zadania?")
A3=$(ask_question 3 "Gdybys mogl miec tylko jedna rzecz zrobiona, co to jest?")
A4=$(ask_question 4 "Czego NIE powinienem dotykac/zmieniac?")

echo -e "${BLUE}--- Szczegoly techniczne ---${NC}"
echo ""
A5=$(ask_question 5 "Jakie technologie/frameworki/biblioteki sa uzywane?")
A6=$(ask_question 6 "Jak uruchomic testy? (np. npm test, pytest, make test)")
A7=$(ask_question 7 "Jak zbudowac projekt? Jakie komendy sprawdzaja ze wszystko dziala?")
A8=$(ask_question 8 "Czy sa konwencje kodu ktorych powinienem sie trzymac? (naming, structure, patterns)")

echo -e "${BLUE}--- Kryteria sukcesu ---${NC}"
echo ""
A9=$(ask_question 9 "Po czym poznam ze zadanie jest DONE? Jakie testy/zachowania musza przejsc?")
A10=$(ask_question 10 "Co moze pojsc nie tak? Jakie edge case'y powinienem obsluzyc?")

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Wszystkie odpowiedzi zebrane!                    ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Build the full prompt with all context inline
NIGHT_PROMPT="$(cat <<PROMPT_EOF
You are working in NIGHT MODE. The user has left the computer and you must work AUTONOMOUSLY.
You have ALL the information you need below. Do NOT ask any questions. Just work.

## TASK
$TASK

## DISCOVERY ANSWERS (from the user before they left)

1. **Goal / end result**: $A1
2. **Key files/modules/folders**: $A2
3. **Top priority (if only one thing)**: $A3
4. **Do NOT touch/change**: $A4
5. **Tech stack**: $A5
6. **How to run tests**: $A6
7. **How to build / verify**: $A7
8. **Code conventions**: $A8
9. **Definition of done**: $A9
10. **Risks / edge cases**: $A10

## PROTOCOL

Follow these phases:

### PHASE 1: PLANNING
- Use TodoWrite to create a detailed task list with small steps (5-15 min each)
- Include testing after each major implementation step
- Include a final validation task

### PHASE 2: AUTONOMOUS EXECUTION
For each task:
1. Mark as in_progress
2. Read relevant code first
3. Make the change
4. Run tests immediately (use: $A6)
5. If tests fail: diagnose, fix, re-run (max 3 attempts per problem)
6. If stuck after 3 attempts: document in NIGHT_MODE_BLOCKERS.md and move on
7. Mark as completed only when tests pass
8. Commit with descriptive message

Rules:
- Commit after every meaningful change
- Test after every change
- Don't over-engineer
- Don't touch: $A4

### PHASE 3: VERIFICATION
1. Run full test suite: $A6
2. Run build: $A7
3. Review git diff against the original goal
4. Create NIGHT_MODE_SUMMARY.md with:
   - Date, task description
   - What was done, what was not done
   - Blockers encountered
   - Test results (total/passing/failing)
   - Files changed
   - How to verify
5. Final commit: "night-mode: complete - [brief summary]"

### CRITICAL RULES
- NEVER push to remote
- NEVER delete files unless explicitly told
- NEVER modify .env or secrets
- ALWAYS commit before moving to next major task
- Stick to scope - no unnecessary refactoring
PROMPT_EOF
)"

echo -e "${YELLOW}Log:${NC} $LOG_FILE"
echo -e "${YELLOW}Start:${NC} $(date)"
echo ""
echo -e "${GREEN}Uruchamiam Claude Code w trybie nocnym...${NC}"
echo -e "${YELLOW}Mozesz bezpiecznie zamknac terminal - Claude pracuje w tle.${NC}"
echo ""

# Run Claude Code in autonomous mode
# --dangerously-skip-permissions: skips all permission prompts
# --output-format text: plain text output for logging
# --verbose: full turn-by-turn output
# nohup: keeps running after terminal closes
nohup claude --dangerously-skip-permissions \
    --output-format text \
    --verbose \
    -p "$NIGHT_PROMPT" \
    2>&1 | tee -a "$LOG_FILE" &

CLAUDE_PID=$!

echo -e "${GREEN}Claude uruchomiony w tle (PID: $CLAUDE_PID)${NC}"
echo ""
echo -e "Monitoruj postep:"
echo -e "  ${BLUE}tail -f $LOG_FILE${NC}"
echo ""
echo -e "Zatrzymaj:"
echo -e "  ${RED}kill $CLAUDE_PID${NC}"
echo ""

# Save PID and task for status checker
echo "$CLAUDE_PID" > "${LOG_DIR}/.current_pid"
echo "$TASK" > "${LOG_DIR}/.current_task"
echo "$TIMESTAMP" > "${LOG_DIR}/.current_timestamp"

echo -e "${GREEN}Dobranoc! Claude pracuje za Ciebie.${NC}"

#!/usr/bin/env bash
# ============================================================================
# Night Mode Launcher for Claude Code
# ============================================================================
# Usage: ./night-mode.sh "Opisz zadanie do wykonania w nocy"
#
# Ten skrypt uruchamia Claude Code w trybie autonomicznym z:
# - Automatycznym akceptowaniem operacji (--dangerously-skip-permissions)
# - Zadaniem przekazanym jako prompt
# - Logowaniem do pliku
#
# UWAGA: --dangerously-skip-permissions to oficjalna flaga Claude Code CLI
# która pozwala na pracę bez pytania o zgodę. Używaj odpowiedzialnie.
# ============================================================================

set -euo pipefail

TASK="${1:-}"
LOG_DIR="./logs/night-mode"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="${LOG_DIR}/session_${TIMESTAMP}.log"
SUMMARY_FILE="${LOG_DIR}/summary_${TIMESTAMP}.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
echo -e "${YELLOW}Log:${NC} $LOG_FILE"
echo -e "${YELLOW}Start:${NC} $(date)"
echo ""

# Build the night mode prompt
NIGHT_PROMPT="$(cat <<PROMPT_EOF
/night-mode

ZADANIE DO WYKONANIA:
$TASK

Pracuj autonomicznie. Nie czekaj na odpowiedzi - masz juz wszystkie informacje.
Po zakonczeniu zapisz podsumowanie w pliku: $SUMMARY_FILE
PROMPT_EOF
)"

echo -e "${GREEN}Uruchamiam Claude Code w trybie nocnym...${NC}"
echo -e "${YELLOW}Mozesz bezpiecznie wyjsc - Claude bedzie pracowal w tle.${NC}"
echo ""

# Run Claude Code in autonomous mode
# --dangerously-skip-permissions: skips all permission prompts
# nohup: keeps running after terminal closes
# tee: logs output to file while also showing it
nohup claude --dangerously-skip-permissions \
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

# Save PID for later reference
echo "$CLAUDE_PID" > "${LOG_DIR}/.current_pid"
echo "$TASK" > "${LOG_DIR}/.current_task"

echo -e "${GREEN}Dobranoc! Claude pracuje za Ciebie.${NC}"

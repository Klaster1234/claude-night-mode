#!/usr/bin/env bash
# ============================================================================
# Night Mode Status Checker
# ============================================================================
# Usage: ./night-status.sh
# Sprawdza status pracy nocnej Claude'a
# ============================================================================

LOG_DIR="./logs/night-mode"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Claude Night Mode Status ===${NC}"
echo ""

# Check if night mode is running
if [ -f "${LOG_DIR}/.current_pid" ]; then
    PID=$(cat "${LOG_DIR}/.current_pid")
    TASK=$(cat "${LOG_DIR}/.current_task" 2>/dev/null || echo "Unknown")

    echo -e "${YELLOW}Zadanie:${NC} $TASK"
    echo ""

    if kill -0 "$PID" 2>/dev/null; then
        echo -e "${GREEN}Status: RUNNING (PID: $PID)${NC}"
    else
        echo -e "${RED}Status: FINISHED (PID: $PID already exited)${NC}"
    fi
    echo ""
fi

# Show latest log
LATEST_LOG=$(ls -t "${LOG_DIR}"/session_*.log 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
    echo -e "${BLUE}Ostatnie 20 linii loga:${NC}"
    echo "---"
    tail -20 "$LATEST_LOG"
    echo "---"
    echo ""
    echo -e "Pelny log: ${BLUE}$LATEST_LOG${NC}"
fi

# Show summary if exists
LATEST_SUMMARY=$(ls -t "${LOG_DIR}"/summary_*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SUMMARY" ]; then
    echo ""
    echo -e "${GREEN}Podsumowanie dostepne: $LATEST_SUMMARY${NC}"
fi

# Show night mode summary if exists
if [ -f "NIGHT_MODE_SUMMARY.md" ]; then
    echo ""
    echo -e "${GREEN}=== PODSUMOWANIE PRACY ===${NC}"
    cat NIGHT_MODE_SUMMARY.md
fi

# Show blockers if exist
if [ -f "NIGHT_MODE_BLOCKERS.md" ]; then
    echo ""
    echo -e "${RED}=== BLOKERY ===${NC}"
    cat NIGHT_MODE_BLOCKERS.md
fi

# Show git changes
echo ""
echo -e "${BLUE}=== Zmiany w Git ===${NC}"
git log --oneline -10 2>/dev/null || echo "Brak commitow"
echo ""
echo -e "${BLUE}Zmienione pliki:${NC}"
git diff --stat HEAD~10 2>/dev/null || git diff --stat 2>/dev/null || echo "Brak zmian"

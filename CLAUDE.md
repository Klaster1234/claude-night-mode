# CLAUDE.md - Konfiguracja Projektu

## Dostępne komendy

### `/night-mode` — Tryb Nocny (Autonomous Overnight Worker)

**Co to jest:** Skill który pozwala zostawić Claude'a na noc, żeby autonomicznie
zrealizował zadanie. Claude najpierw zadaje 10 celnych pytań, a potem pracuje
sam — implementuje, testuje, naprawia, commituje, aż do zakończenia.

**Kiedy używać:** Gdy masz duże zadanie do zrobienia i chcesz zostawić komputer
na noc. Odpowiadasz na pytania przed wyjściem, a rano masz gotowy kod.

**Jak uruchomić:**

1. **Interaktywnie** — wpisz `/night-mode` w Claude Code CLI
2. **W tle na noc** — `./night-mode.sh "opis zadania"` (uruchamia z `--dangerously-skip-permissions`)
3. **Sprawdź rano** — `./night-status.sh` lub przeczytaj `NIGHT_MODE_SUMMARY.md`

---

## Night Mode — Szczegółowy opis

### 4 fazy działania

1. **Discovery (Odkrywanie)** — Claude zadaje dokładnie 10 pytań:
   - Cel i definicja sukcesu
   - Kontekst: kluczowe pliki/moduły
   - Priorytet: co jest najważniejsze
   - Ograniczenia: czego nie dotykać
   - Stack technologiczny
   - Jak uruchomić testy
   - Jak zbudować projekt
   - Konwencje kodu
   - Kryteria akceptacji
   - Ryzyka i edge case'y

2. **Planning (Planowanie)** — rozbicie zadania na małe kroki w TodoWrite

3. **Execution (Realizacja)** — autonomiczna praca:
   - Implementacja krok po kroku
   - Testy po każdej zmianie
   - Auto-naprawa gdy testy failują (max 3 próby per problem)
   - Commit po każdej znaczącej zmianie
   - Dokumentowanie blokerów w `NIGHT_MODE_BLOCKERS.md`

4. **Verification (Weryfikacja)** — przed zakończeniem:
   - Pełny test suite
   - Build
   - Linting
   - Podsumowanie w `NIGHT_MODE_SUMMARY.md`

### Uprawnienia w trybie nocnym

W trybie nocnym Claude ma prawo BEZ pytania o zgodę:
- Czytać/pisać/edytować/tworzyć pliki
- Uruchamiać testy (`npm test`, `pytest`, `cargo test`, `go test`, itp.)
- Uruchamiać lintery i formattery
- Uruchamiać build
- Operacje git (add, commit — ale NIE push bez jawnej zgody)
- Instalować zależności (`npm install`, `pip install`, itp.)
- Uruchamiać skrypty projektowe

### Zasady ogólne

- Preferuj edycję istniejących plików zamiast tworzenia nowych
- Zawsze uruchamiaj testy po zmianach
- Commituj często z opisowymi wiadomościami
- Jeśli utkniesz na problemie po 3 próbach — dokumentuj bloker i idź dalej
- Nigdy nie usuwaj danych użytkownika ani ważnych plików bez potwierdzenia
- Nie pushuj do remote bez jawnej zgody
- Nie modyfikuj plików `.env` ani plików z sekretami

### Pliki wyjściowe

| Plik | Opis |
|------|------|
| `NIGHT_MODE_SUMMARY.md` | Podsumowanie pracy — co zrobione, co nie, jak zweryfikować |
| `NIGHT_MODE_BLOCKERS.md` | Lista problemów na które Claude natrafił i nie rozwiązał |
| `logs/night-mode/` | Logi sesji (gdy użyto `night-mode.sh`) |

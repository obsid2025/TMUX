#!/bin/bash
# ==================== TMUX PERSISTENT SESSIONS - INSTALLER ====================
# Instalează sistemul complet de persistență tmux pe Ubuntu/WSL
#
# Funcționalități:
# - Sesiuni tmux izolate per proiect/folder
# - Auto-save la fiecare 5 secunde
# - Auto-restore după restart PC
# - Istoric bash izolat per panou
# - Restaurare scroll-back cu culori
# - Titluri panouri persistente

set -e

echo "================================================"
echo "  TMUX PERSISTENT SESSIONS - INSTALLER"
echo "================================================"
echo ""

# Verifică dacă tmux e instalat
if ! command -v tmux &> /dev/null; then
    echo "EROARE: tmux nu este instalat!"
    echo "Rulează: sudo apt install tmux"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/5] Instalez scripturile în ~/.local/bin/ ..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/tp" "$HOME/.local/bin/tp"
cp "$SCRIPT_DIR/bin/tp-autosave" "$HOME/.local/bin/tp-autosave"
chmod +x "$HOME/.local/bin/tp"
chmod +x "$HOME/.local/bin/tp-autosave"

# Adaugă ~/.local/bin la PATH dacă nu e deja
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "   - Adăugat ~/.local/bin la PATH"
fi

echo "[2/5] Creez directoarele necesare ..."
mkdir -p "$HOME/.tmux/project-saves"

echo "[3/5] Configurez .bashrc pentru istoric izolat per panou ..."
# Verifică dacă codul e deja adăugat
if ! grep -q "TMUX PERSISTENT SESSIONS" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# ==================== TMUX PERSISTENT SESSIONS ====================" >> "$HOME/.bashrc"
    cat "$SCRIPT_DIR/bashrc-additions.sh" >> "$HOME/.bashrc"
    echo "   - Adăugat cod pentru istoric izolat per panou"
else
    echo "   - Codul pentru istoric izolat există deja în .bashrc"
fi

echo "[4/5] Configurez cron pentru auto-save la 5 secunde ..."
# Creează cron jobs (12 intrări pentru 5 secunde interval)
CRON_CMD="$HOME/.local/bin/tp-autosave >> /tmp/tp-autosave.log 2>&1"
TEMP_CRON=$(mktemp)
crontab -l 2>/dev/null | grep -v "tp-autosave" > "$TEMP_CRON" || true

for i in {0..11}; do
    SECOND=$((i * 5))
    echo "* * * * * sleep $SECOND && $CRON_CMD" >> "$TEMP_CRON"
done

crontab "$TEMP_CRON"
rm "$TEMP_CRON"
echo "   - Configurat auto-save la fiecare 5 secunde"

echo "[5/5] Verific instalarea ..."
if [ -x "$HOME/.local/bin/tp" ] && [ -x "$HOME/.local/bin/tp-autosave" ]; then
    echo "   - Scripturile sunt instalate corect"
else
    echo "EROARE: Scripturile nu au fost instalate corect!"
    exit 1
fi

echo ""
echo "================================================"
echo "  INSTALARE COMPLETĂ!"
echo "================================================"
echo ""
echo "UTILIZARE:"
echo "  cd /path/to/project"
echo "  tp              # Pornește/atașează la proiect"
echo "  tp ls           # Listează sesiunile (cu auto-restore)"
echo "  tp help         # Ajutor complet"
echo ""
echo "SETARE TITLU PANOU (pentru istoric izolat):"
echo "  Ctrl+B apoi :select-pane -T \"nume_panou\""
echo ""
echo "IMPORTANT:"
echo "  - Rulează 'source ~/.bashrc' sau deschide terminal nou"
echo "  - Fiecare panou trebuie să aibă un TITLU UNIC pentru istoric separat"
echo ""

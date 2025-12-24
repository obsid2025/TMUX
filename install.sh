#!/bin/bash
# TMUX Professional Setup - Script de instalare
# https://github.com/obsid2025/TMUX

set -e

echo "╔════════════════════════════════════════╗"
echo "║   TMUX Professional Setup Installer    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Culori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# 1. Verifică/instalează tmux
if ! command -v tmux &> /dev/null; then
    warn "tmux nu e instalat. Instalez..."
    sudo apt update && sudo apt install -y tmux
fi
log "tmux $(tmux -V)"

# 2. Instalează TPM
if [ ! -d ~/.tmux/plugins/tpm ]; then
    log "Instalez TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    log "TPM deja instalat"
fi

# 3. Instalează Catppuccin
if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
    log "Instalez tema Catppuccin..."
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
else
    log "Catppuccin deja instalat"
fi

# 4. Instalează tmux-cpu și tmux-battery
mkdir -p ~/.config/tmux/plugins/tmux-plugins
if [ ! -d ~/.config/tmux/plugins/tmux-plugins/tmux-cpu ]; then
    log "Instalez tmux-cpu..."
    git clone https://github.com/tmux-plugins/tmux-cpu ~/.config/tmux/plugins/tmux-plugins/tmux-cpu
else
    log "tmux-cpu deja instalat"
fi

if [ ! -d ~/.config/tmux/plugins/tmux-plugins/tmux-battery ]; then
    log "Instalez tmux-battery..."
    git clone https://github.com/tmux-plugins/tmux-battery ~/.config/tmux/plugins/tmux-plugins/tmux-battery
else
    log "tmux-battery deja instalat"
fi

# 5. Copiază configurația
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Copiez configurația tmux..."
cp "$SCRIPT_DIR/tmux.conf" ~/.tmux.conf

# 6. Instalează scriptul tp
log "Instalez scriptul tp (proiecte izolate)..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/tp" ~/.local/bin/tp
chmod +x ~/.local/bin/tp

# 7. Scripturi Windows CPU/RAM (pentru WSL)
if grep -qi microsoft /proc/version 2>/dev/null; then
    log "WSL detectat - instalez scripturi Windows CPU/RAM..."
    cp "$SCRIPT_DIR/win_cpu.sh" ~/.local/bin/
    cp "$SCRIPT_DIR/win_ram.sh" ~/.local/bin/
    chmod +x ~/.local/bin/win_*.sh
fi

# 8. Adaugă ~/.local/bin la PATH dacă nu e
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    log "Adaug ~/.local/bin la PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# 9. Adaugă funcții helper în bashrc
if ! grep -q "# TMUX HELPERS" ~/.bashrc 2>/dev/null; then
    log "Adaug funcții helper în bashrc..."
    cat >> ~/.bashrc << 'EOF'

# ==================== TMUX HELPERS ====================
pane() { tmux select-pane -T "$1"; }
ts() { tmux new-session -s "$1"; }
ta() { tmux attach -t "$1"; }
tl() { tmux ls; }
tk() { tmux kill-session -t "$1"; }
tsv() { tmux split-window -h && tmux select-pane -T "$1"; }
tsh() { tmux split-window -v && tmux select-pane -T "$1"; }
EOF
fi

# 10. Instalează plugin-uri TPM
log "Instalez plugin-uri TPM..."
~/.tmux/plugins/tpm/bin/install_plugins || true

echo ""
echo "╔════════════════════════════════════════╗"
echo "║         Instalare completă!            ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Pași următori:"
echo "  1. Rulează: source ~/.bashrc"
echo "  2. Pornește tmux: tmux"
echo "  3. Sau folosește proiecte: cd ~/project && tp"
echo ""
echo "Shortcut-uri principale:"
echo "  Ctrl+a |     Split vertical"
echo "  Ctrl+a -     Split orizontal"
echo "  Ctrl+a w     Tree view"
echo "  Ctrl+a d     Detach"
echo "  tp           Proiect izolat per folder"
echo ""

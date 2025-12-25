# TMUX Professional Setup

Configurație completă tmux cu:
- Tema Catppuccin Macchiato
- Sesiuni persistente (supraviețuiesc restart-ului)
- Proiecte izolate per folder
- Status bar cu CPU/RAM (Windows + WSL)
- Pane borders cu etichete stilizate
- Shortcut-uri intuitive DevOps
- Clipboard Windows integration (Ctrl+C / Ctrl+V)
- Auto-save și auto-restore pentru proiecte izolate

## Screenshot

```
┌─────────────────────────────────────────────────────────────┐
│ W: CPU 17% RAM 25% │ WSL: CPU 4% RAM 8% │ /path │ session │
├─────────────────────────────────────────────────────────────┤
│                    1:Backend                                │
│  ┌──────────────────────┬──────────────────────┐           │
│  │                      │                      │           │
│  │    Pane 1           │    Pane 2           │           │
│  │                      │                      │           │
│  └──────────────────────┴──────────────────────┘           │
│                    2:Frontend                               │
└─────────────────────────────────────────────────────────────┘
```

## Instalare Rapidă

```bash
git clone https://github.com/obsid2025/TMUX.git ~/TMUX-setup
cd ~/TMUX-setup
chmod +x install.sh
./install.sh
```

## Instalare Manuală

### 1. Dependențe

```bash
sudo apt update
sudo apt install -y tmux git
```

### 2. TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Catppuccin Theme

```bash
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
```

### 4. Plugin-uri Extra

```bash
mkdir -p ~/.config/tmux/plugins/tmux-plugins
git clone https://github.com/tmux-plugins/tmux-cpu ~/.config/tmux/plugins/tmux-plugins/tmux-cpu
git clone https://github.com/tmux-plugins/tmux-battery ~/.config/tmux/plugins/tmux-plugins/tmux-battery
```

### 5. Copiază Configurația

```bash
mkdir -p ~/.local/bin ~/.tmux/project-saves
cp tmux.conf ~/.tmux.conf
cp tp ~/.local/bin/tp
cp tp-autosave ~/.local/bin/tp-autosave
chmod +x ~/.local/bin/tp ~/.local/bin/tp-autosave
cp win_cpu.sh ~/.local/bin/
cp win_ram.sh ~/.local/bin/
chmod +x ~/.local/bin/win_*.sh
```

### 6. Instalează Plugin-uri TPM

```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

### 7. Font (Windows Terminal)

Instalează [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip)

## Comenzi Principale

### Prefix: `Ctrl+a` (sau `Ctrl+b`)

| Comandă | Acțiune |
|---------|---------|
| `Ctrl+a \|` | Split vertical |
| `Ctrl+a -` | Split orizontal |
| `Ctrl+a c` | Fereastră nouă |
| `Ctrl+a w` | Tree view (ferestre) |
| `Ctrl+a s` | Tree view (sesiuni) |
| `Ctrl+a d` | Detach |
| `Ctrl+a r` | Reload config |
| `Ctrl+a x` | Kill pane |
| `Ctrl+a ,` | Redenumește fereastră |
| `Ctrl+a S` | Sync panes (toggle) |

### Clipboard (Ctrl+C / Ctrl+V) - WSL

| Comandă | Acțiune |
|---------|---------|
| Selectare mouse | Copiază automat în Windows clipboard |
| `Ctrl+C` (în copy-mode) | Copiază selecția în Windows clipboard |
| `Ctrl+V` | Lipește din Windows clipboard |

### Navigare FĂRĂ Prefix

| Comandă | Acțiune |
|---------|---------|
| `Alt + ←↑↓→` | Navighează între pane-uri |
| `Ctrl + ←↑↓→` | Resize pane |
| `Shift + ←→` | Schimbă fereastra |

### Salvare/Restaurare Sesiuni

| Comandă | Acțiune |
|---------|---------|
| `Ctrl+a Ctrl+s` | Salvează sesiunile |
| `Ctrl+a Ctrl+r` | Restaurează sesiunile |
| Automat | Salvează la 15 min, restaurează la start |

## Proiecte Izolate (`tp`)

Comanda `tp` creează servere tmux izolate per folder. Fiecare proiect are propriile sesiuni, complet separate.

```bash
# Intră în folderul proiectului
cd ~/projects/ecommerce

# Pornește proiectul
tp                    # Creează/attach sesiunea "main"
tp backend            # Creează/attach sesiunea "backend"

# Gestionare
tp ls                 # Lista sesiuni din proiect
tp ls-all             # Lista TOATE proiectele
tp create frontend    # Creează sesiune fără attach
tp new api-window     # Fereastră nouă
tp rename server      # Redenumește fereastra
tp kill-session X     # Șterge sesiunea X
tp kill               # Oprește tot proiectul
tp save               # Salvează manual proiectul
```

### Auto-Save & Auto-Restore

Proiectele izolate se salvează și restaurează automat:
- La `tp ls` sau intrare în proiect, dacă serverul nu rulează, se restaurează automat din ultima salvare
- Salvări stocate în `~/.tmux/project-saves/`

**Cronjob pentru auto-save (opțional):**
```bash
# Adaugă în crontab (crontab -e)
*/5 * * * * ~/.local/bin/tp-autosave >> /tmp/tp-autosave.log 2>&1
```

### Izolare Completă

```
~/projects/ecommerce$ tp ls
  backend: 1 windows
  frontend: 2 windows

~/projects/marketing$ tp ls
  social: 1 windows
  content: 1 windows

# NU se văd între ele!
```

## Structura Fișierelor

```
~/.tmux.conf                 # Configurație principală
~/.tmux/plugins/tpm/         # Plugin Manager
~/.tmux/project-saves/       # Salvări proiecte izolate
~/.config/tmux/plugins/      # Catppuccin + CPU + Battery
~/.local/bin/tp              # Script proiecte izolate
~/.local/bin/tp-autosave     # Auto-save pentru cronjob
~/.local/bin/win_cpu.sh      # CPU Windows (WSL)
~/.local/bin/win_ram.sh      # RAM Windows (WSL)
```

## Funcții Bash Helper

Adaugă în `~/.bashrc`:

```bash
# Setează titlul pane-ului
pane() { tmux select-pane -T "$1"; }

# Sesiuni rapide
ts() { tmux new-session -s "$1"; }
ta() { tmux attach -t "$1"; }
tl() { tmux ls; }
tk() { tmux kill-session -t "$1"; }

# Split și setează titlu
tsv() { tmux split-window -h && tmux select-pane -T "$1"; }
tsh() { tmux split-window -v && tmux select-pane -T "$1"; }
```

## Culori Catppuccin Macchiato

| Element | Culoare |
|---------|---------|
| Background | `#24273a` |
| Foreground | `#cad3f5` |
| Pane activ | `#c6a0f6` (mauve) |
| Pane inactiv | `#494d64` |
| Verde | `#a6da95` |
| Galben | `#eed49f` |
| Roz | `#f5bde6` |

## Troubleshooting

### Caracterele nu se afișează corect
- Instalează un Nerd Font
- Setează fontul în terminal

### Plugin-urile nu funcționează
```bash
~/.tmux/plugins/tpm/bin/install_plugins
tmux source ~/.tmux.conf
```

### Sesiunile nu se restaurează
```bash
# Verifică dacă există salvări
ls ~/.tmux/resurrect/
# Restaurează manual
tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
```

### CPU/RAM Windows nu apare (WSL)
```bash
# Testează scripturile
~/.local/bin/win_cpu.sh
~/.local/bin/win_ram.sh
```

## Windows Terminal Settings

Adaugă în `settings.json`:

```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "JetBrainsMono Nerd Font",
                "size": 11
            },
            "colorScheme": "Catppuccin Macchiato"
        }
    },
    "schemes": [
        {
            "name": "Catppuccin Macchiato",
            "background": "#24273A",
            "foreground": "#CAD3F5",
            "black": "#494D64",
            "red": "#ED8796",
            "green": "#A6DA95",
            "yellow": "#EED49F",
            "blue": "#8AADF4",
            "purple": "#F5BDE6",
            "cyan": "#8BD5CA",
            "white": "#B8C0E0",
            "brightBlack": "#5B6078",
            "brightRed": "#ED8796",
            "brightGreen": "#A6DA95",
            "brightYellow": "#EED49F",
            "brightBlue": "#8AADF4",
            "brightPurple": "#F5BDE6",
            "brightCyan": "#8BD5CA",
            "brightWhite": "#A5ADCB",
            "cursorColor": "#F4DBD6",
            "selectionBackground": "#5B6078"
        }
    ]
}
```

## Licență

MIT License

## Credits

- [Catppuccin](https://github.com/catppuccin/tmux)
- [TPM](https://github.com/tmux-plugins/tpm)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)

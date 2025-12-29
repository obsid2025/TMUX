# TMUX Persistent Sessions

Sistem complet de persistență pentru tmux pe Ubuntu/WSL. Salvează și restaurează automat sesiunile tmux după restart PC, cu istoric bash izolat per panou.

## Funcționalități

- **Sesiuni izolate per proiect** - Fiecare folder are propriul server tmux
- **Auto-save la 5 secunde** - Salvare automată via cron
- **Auto-restore după restart** - Restaurare completă la `tp ls`
- **Istoric bash izolat per panou** - Fiecare panou are propriul HISTFILE
- **Scroll-back cu culori** - Restaurare conținut vizual al panourilor
- **Titluri panouri persistente** - Se păstrează după restart
- **Atomic write** - Prevenire pierdere date la crash

## Instalare rapidă

```bash
git clone https://github.com/obsid2025/TMUX.git
cd TMUX
./install.sh
source ~/.bashrc
```

## Utilizare

```bash
# Din orice folder de proiect:
cd /path/to/my-project
tp              # Pornește sau atașează la proiect
tp ls           # Listează sesiuni (cu auto-restore)
tp help         # Ajutor complet
```

### Setare titlu panou (IMPORTANT pentru istoric izolat)

Fiecare panou trebuie să aibă un **titlu unic** pentru a avea istoric separat:

```bash
# Metodă 1: Din interiorul panoului
tmux select-pane -T "backend"

# Metodă 2: Prefix + comandă
# Ctrl+B apoi tastează:
:select-pane -T "frontend"
```

## Arhitectură

### Fișiere instalate

| Fișier | Locație | Descriere |
|--------|---------|-----------|
| `tp` | `~/.local/bin/tp` | Script principal pentru managementul proiectelor |
| `tp-autosave` | `~/.local/bin/tp-autosave` | Script pentru salvare automată (rulat de cron) |
| Cod bashrc | `~/.bashrc` | Logică pentru istoric izolat per panou |

### Date salvate (per proiect)

```
~/.tmux/project-saves/
├── PROIECT_hash.sessions      # Lista sesiunilor
├── PROIECT_hash.windows       # Ferestre cu layout
├── PROIECT_hash.panes         # Panouri cu path, cmd, titlu
├── PROIECT_hash/
│   └── history/
│       ├── main-backend.bash  # Istoric panou "backend"
│       ├── main-frontend.bash # Istoric panou "frontend"
│       └── ...
└── scrollback/
    └── PROIECT_hash/
        ├── main_1_1.txt       # Scroll-back panou 1.1
        └── ...
```

## Cum funcționează

### 1. Identificare proiect
- Proiectul = `basename_md5hash` pentru unicitate
- Fiecare folder are propriul server tmux izolat (`tmux -L socket_name`)

### 2. Auto-save (la 5 secunde)
- Cron rulează `tp-autosave` la fiecare 5 secunde (12 cron jobs cu sleep)
- Salvează: sesiuni, ferestre, panouri, path-uri, comenzi, titluri, scroll-back
- **Atomic write**: Scrie în `.tmp`, mută în `.panes` doar dacă salvarea a reușit

### 3. Auto-restore
- La `tp` sau `tp ls`, dacă serverul nu rulează, restaurează automat
- Recreează structura: sesiuni → ferestre → panouri
- Setează path-uri, titluri, afișează scroll-back

### 4. Istoric izolat per panou
- **Problema**: La restore, shell-ul pornește ÎNAINTE ca titlul să fie setat
- **Soluția**: Fișiere "hint" temporare în `/tmp/tmux-histfile-hints/`
  1. Înainte de `respawn-pane`, scrie calea HISTFILE în hint file
  2. `.bashrc` citește hint file (dacă există) și setează HISTFILE
  3. Hint file este șters după citire

### 5. Detectare schimbare titlu
- `PROMPT_COMMAND` verifică dacă titlul s-a schimbat
- Dacă da, salvează istoricul vechi și încarcă pe cel nou
- Permite redenumire panouri fără pierdere istoric

## Comenzi disponibile

| Comandă | Descriere |
|---------|-----------|
| `tp` | Attach la proiect (auto-restore) |
| `tp SESIUNE` | Attach/crează sesiune cu nume |
| `tp ls` | Lista sesiuni (auto-restore) |
| `tp ls-all` | Lista TOATE proiectele |
| `tp new WINDOW` | Crează fereastră nouă |
| `tp rename NUME` | Redenumește fereastra |
| `tp save` | Salvează manual |
| `tp kill` | Oprește proiectul (păstrează salvările) |
| `tp purge` | Șterge proiectul COMPLET |
| `tp help` | Ajutor |

## Troubleshooting

### Istoric identic în toate panourile
**Cauză**: Panourile au același titlu (sau titlul default - hostname)
**Soluție**: Setează titluri unice pentru fiecare panou

### Scroll-back nu apare după restore
**Cauză**: Scroll-back-ul nu a fost salvat înainte de restart
**Soluție**: Așteaptă 5 secunde (auto-save) înainte de restart

### Panouri nu se restaurează
**Cauză**: Fișierul `.panes` e gol (crash în timpul salvării)
**Soluție**: Atomic write previne asta; verifică `.panes.tmp`

## Pentru LLM-uri (instrucțiuni de instalare)

Dacă un LLM trebuie să instaleze acest sistem pe o mașină nouă:

1. **Clonează repo-ul**:
   ```bash
   git clone https://github.com/obsid2025/TMUX.git ~/TMUX
   cd ~/TMUX
   ```

2. **Rulează instalarea**:
   ```bash
   ./install.sh
   ```

3. **Reîncarcă bashrc**:
   ```bash
   source ~/.bashrc
   ```

4. **Testează**:
   ```bash
   cd /tmp
   tp
   # Creează panouri, setează titluri, rulează comenzi
   # Ctrl+B d pentru detach
   tp kill
   tp ls  # Ar trebui să restaureze
   ```

### Ce face install.sh:
1. Copiază `tp` și `tp-autosave` în `~/.local/bin/`
2. Adaugă `~/.local/bin` la PATH (dacă nu e deja)
3. Adaugă codul pentru istoric izolat în `~/.bashrc`
4. Configurează 12 cron jobs pentru auto-save la 5 secunde
5. Creează directoarele necesare

### Dependențe:
- `tmux` (sudo apt install tmux)
- `bash` (default pe Ubuntu)
- `cron` (default pe Ubuntu)

## Licență

MIT License

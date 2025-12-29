# ==================== TMUX PERSISTENT SESSIONS - BASHRC ADDITIONS ====================
# Adaugă acest cod la sfârșitul fișierului ~/.bashrc
# Oferă: istoric bash izolat per panou tmux, detectare automată schimbare titlu

# ==================== ISTORIC BASH IZOLAT PER PANOU ====================
# Fiecare panou tmux are propriul său istoric complet izolat
# Folosește TITLUL panoului (persistent și unic) ca identificator
if [ -n "$TMUX" ]; then
    # Află socket-ul tmux curent (proiectul)
    TMUX_SOCKET=$(echo "$TMUX" | cut -d',' -f1)
    TMUX_PROJECT=$(basename "$TMUX_SOCKET" 2>/dev/null)

    if [ -n "$TMUX_PROJECT" ]; then
        # Creează director pentru istoricul per-panou
        mkdir -p "$HOME/.tmux/project-saves/$TMUX_PROJECT/history"

        # IMPORTANT: Folosim -t $TMUX_PANE pentru a obține indexurile panoului CURENT
        # (fără -t, display-message returnează info despre panoul ACTIV, nu cel curent)
        TMUX_SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
        TMUX_WINDOW_IDX=$(tmux display-message -p -t "$TMUX_PANE" '#{window_index}' 2>/dev/null)
        TMUX_PANE_IDX=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_index}' 2>/dev/null)

        # METODA 1: Verifică dacă există hint file de la restore (prioritate maximă)
        HINT_FILE="/tmp/tmux-histfile-hints/$TMUX_PROJECT/${TMUX_SESSION}_${TMUX_WINDOW_IDX}_${TMUX_PANE_IDX}"
        if [ -f "$HINT_FILE" ]; then
            # Citește HISTFILE din hint și șterge fișierul
            export HISTFILE=$(cat "$HINT_FILE")
            rm -f "$HINT_FILE"
        else
            # METODA 2: Operare normală - citește titlul din tmux
            TMUX_PANE_TITLE=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_title}' 2>/dev/null)
            # Sanitizează pentru nume de fișier
            TMUX_SESSION_SAFE=$(echo "$TMUX_SESSION" | tr ' /' '__' | tr -cd '[:alnum:]_-')
            TMUX_PANE_TITLE_SAFE=$(echo "$TMUX_PANE_TITLE" | tr ' /' '__' | tr -cd '[:alnum:]_-')
            # Setează HISTFILE unic per panou folosind sesiune + titlu
            export HISTFILE="$HOME/.tmux/project-saves/$TMUX_PROJECT/history/${TMUX_SESSION_SAFE}-${TMUX_PANE_TITLE_SAFE}.bash"
        fi

        # Încarcă istoricul existent din fișier (dacă există)
        history -r "$HISTFILE" 2>/dev/null

        # Salvează titlul curent pentru detectare schimbări
        export _TMUX_LAST_TITLE="$TMUX_PANE_TITLE"
    fi
fi

# Funcție pentru actualizare HISTFILE când se schimbă titlul panoului
_update_histfile_if_title_changed() {
    if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
        local current_title=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_title}' 2>/dev/null)
        if [ -n "$current_title" ] && [ "$current_title" != "$_TMUX_LAST_TITLE" ]; then
            # Titlul s-a schimbat! Salvează istoricul vechi și actualizează HISTFILE
            history -a 2>/dev/null

            TMUX_SOCKET=$(echo "$TMUX" | cut -d',' -f1)
            TMUX_PROJECT=$(basename "$TMUX_SOCKET" 2>/dev/null)
            TMUX_SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)

            SESSION_SAFE=$(echo "$TMUX_SESSION" | tr ' /' '__' | tr -cd '[:alnum:]_-')
            TITLE_SAFE=$(echo "$current_title" | tr ' /' '__' | tr -cd '[:alnum:]_-')

            export HISTFILE="$HOME/.tmux/project-saves/$TMUX_PROJECT/history/${SESSION_SAFE}-${TITLE_SAFE}.bash"
            export _TMUX_LAST_TITLE="$current_title"

            # Încarcă istoricul din noul fișier
            history -r "$HISTFILE" 2>/dev/null
        fi
    fi
}

# Adaugă la PROMPT_COMMAND: verifică schimbare titlu și salvează istoric
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_update_histfile_if_title_changed; history -a"

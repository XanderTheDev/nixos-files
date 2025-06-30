# ~/.config/fzf_binds.zsh

_fzf_insert_file() {
  # Launch fzf to select a file with fd
  local selected
  selected=$(fd --type f | fzf) || return

  if [[ -n $selected ]]; then
    # Insert selected file path at cursor position
    BUFFER="${BUFFER[1,CURSOR]}${selected}${BUFFER[CURSOR+1,-1]}"
    CURSOR=$(( CURSOR + ${#selected} ))
  fi
  zle reset-prompt
}
zle -N _fzf_insert_file

_fzf_open_vim() {
  local selected
  selected=$(fd --type f | fzf) || return

  if [[ -n $selected ]]; then
    BUFFER="vim '$selected'"
    CURSOR=${#BUFFER}
    zle accept-line  # immediately execute the command
  fi
}
zle -N _fzf_open_vim

_fzf_cd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) || return

  if [[ -n $dir ]]; then
    BUFFER="cd $dir"
    CURSOR=${#BUFFER}
    zle accept-line
  fi
}
zle -N _fzf_cd

# Keybindings: Bind to keys similar to your bash version
bindkey '^T' _fzf_insert_file   # Ctrl+T
bindkey '^G' _fzf_open_vim      # Ctrl+G
bindkey '^[c' _fzf_cd           # Alt+C

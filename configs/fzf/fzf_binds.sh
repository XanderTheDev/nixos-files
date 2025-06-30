# ~/.config/fzf_binds.sh
_fzf_insert_file() {
  local selected
  selected=$(fd --type f | fzf) || return
  if [[ -n $selected ]]; then
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}$selected${READLINE_LINE:READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  fi
}

_fzf_open_vim() {
  local selected
  selected=$(fd --type f | fzf) || return
  if [[ -n $selected ]]; then
    vim "$selected"
  fi
}

_fzf_cd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) || return
  if [[ -n $dir ]]; then
    cd "$dir"
  fi
}

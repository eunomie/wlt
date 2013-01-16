if [[ ! -o interactive ]]; then
    return
fi

compctl -K _wlt wlt

_wlt() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(wlt commands)"
  else
    completions="$(wlt completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}

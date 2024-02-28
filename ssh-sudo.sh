#!/usr/bin/env bash

"$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.upkg/.bin/checkdeps" socket-credential-cache

ssh_cmd() {
  local ssh_opts=(-t)
  [[ -z $SSH_OPTS ]] || ssh_opts+=("${SSH_OPTS[@]}")
  if ${SSH_STRIP_CR:-true}; then
    ssh "${ssh_opts[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@" 2> >(sed 's/\r$//g' >&2) | sed 's/\r$//g'
  else
    ssh "${ssh_opts[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@"
  fi
}

ssh_sudo() {
  ssh_cmd sudo -Ski --prompt= "$@" <<<"${SSH_SUDO_PASS:-$(get_sudo_pass "${SSH_USER:-$USER}" "${SSH_HOST:?}")}"
}

get_sudo_pass() {
  local ssh_opts=(-t) cache_name="${SSH_USER:-$USER}@${SSH_HOST:?} sudo" sudo_pass
  [[ ${#SSH_OPTS[@]} -eq 0 ]] || ssh_opts+=("${SSH_OPTS[@]}")
  if ! sudo_pass=$(socket-credential-cache get "$cache_name" 2>/dev/null); then
    printf "[sudo] password for %s on $SSH_HOST: " "${SSH_USER:-$USER}" >&2
    read -rs sudo_pass || return 1
    printf "\n" >&2
    if [[ $(ssh "${ssh_opts[@]}" "${SSH_USER:-$USER}@$SSH_HOST" -- sudo -Sp \'\' echo success <<<"$sudo_pass") != 'success' ]]; then
      return 1
    fi
    if [[ -n $SSH_SUDO_PASS_CACHE_TIMEOUT ]]; then
      socket-credential-cache set -t "$SSH_SUDO_PASS_CACHE_TIMEOUT" "$cache_name" <<<"$sudo_pass"
    else
      socket-credential-cache set "$cache_name" <<<"$sudo_pass"
    fi
  fi
  printf -- "%s\n" "$sudo_pass"
}

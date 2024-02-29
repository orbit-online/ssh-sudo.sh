#!/usr/bin/env bash

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@"
}

ssh_sudo_cmd() {
  ssh_cmd sudo -Ski --prompt= "$@" <<<"${SSH_SUDO_PASS:?}"
}

ssh_sudo() {
  local cmdpath askpath ret=0
  cmdpath=$(ssh_sudo_cmd mktemp | sed 's/\r$//g') || return $?
  askpath=$(ssh_cmd mktemp | sed 's/\r$//g') || return $?
  ssh_sudo_cmd chmod u+x "$cmdpath" "$askpath" || return $?
  ssh_cmd sudo -Ski --prompt= tee "$cmdpath" <<<"$SSH_SUDO_PASS
$*" >/dev/null || return $?
  ssh_cmd tee "$askpath" <<<"#!/usr/bin/env sh
echo $SSH_SUDO_PASS" >/dev/null || return $?
  ssh_cmd SUDO_ASKPASS="$askpath" sudo -A "$cmdpath" || ret=$?
  ssh_sudo_cmd rm "$cmdpath" "$askpath" || return $?
  return $ret
}

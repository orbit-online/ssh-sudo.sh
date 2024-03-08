#!/usr/bin/env bash

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@"
}

ssh_sudo_cmd() {
  ssh_cmd sudo -Sk --prompt= "$@" <<<"${SSH_SUDO_PASS:?}"
}

ssh_sudo() {
  local cmdpath askpath ret=0
  cmdpath=$(ssh_sudo_cmd mktemp | sed 's/\r$//g') || return $?
  ssh_sudo_cmd chmod u+x "$cmdpath" || return $?
  askpath=$(ssh_cmd mktemp | sed 's/\r$//g') || return $?
  ssh_cmd chmod u+x "$askpath" || return $?
  ssh_cmd sudo -Sk --prompt= tee "$cmdpath" <<<"$SSH_SUDO_PASS
$*" >/dev/null || return $?
  ssh_cmd tee "$askpath" <<<"#!/usr/bin/env sh
echo $SSH_SUDO_PASS" >/dev/null || return $?
  ssh_cmd SUDO_ASKPASS="$askpath" sudo -A "$cmdpath" || ret=$?
  ssh_cmd rm "$askpath" || true
  ssh_sudo_cmd rm "$cmdpath" || true
  return $ret
}

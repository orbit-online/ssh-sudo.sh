#!/usr/bin/env bash

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@"
}

ssh_sudo_cmd() {
  ssh_cmd sudo -Sku "${SSH_SUDO_USER:-root}" --prompt= "$@" <<<"${SSH_SUDO_PASS:?}"
}

ssh_sudo() {
  local scriptpath askpath ret=0
  scriptpath=$(ssh_sudo_cmd mktemp | sed 's/\r$//g') || return $?
  ssh_sudo_cmd chmod u+x "$scriptpath" || return $?
  askpath=$(ssh_cmd mktemp | sed 's/\r$//g') || return $?
  ssh_cmd chmod u+x "$askpath" || return $?
  SSH_SUDO_PASS="$SSH_SUDO_PASS
$*" ssh_sudo_cmd tee "$scriptpath" >/dev/null || return $?
  ssh_cmd tee "$askpath" <<<"#!/usr/bin/env sh
echo $SSH_SUDO_PASS" >/dev/null || return $?
  ssh_cmd SUDO_ASKPASS="$askpath" sudo -Au "${SSH_SUDO_USER:-root}" "$scriptpath" || ret=$?
  ssh_cmd rm "$askpath" || true
  ssh_sudo_cmd rm "$scriptpath" || true
  return $ret
}

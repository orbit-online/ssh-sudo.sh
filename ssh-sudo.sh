#!/usr/bin/env bash

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- "$@"
}

ssh_sudo_cmd() {
  SSH_SUDO_PASS=$SSH_SUDO_PASS ssh_cmd sudo -Ski --prompt= "$@" <<<"${SSH_SUDO_PASS}"
}

ssh_sudo() {
  : "${SSH_SUDO_PASS:?"\$SSH_SUDO_PASS must be set when using ssh_sudo_script()"}"
  local cmdpath askpath ret=0
  cmdpath=$(ssh_sudo_cmd mktemp | sed 's/\r$//g')
  askpath=$(ssh_cmd mktemp | sed 's/\r$//g')
  ssh_sudo_cmd chmod u+x "$cmdpath" "$askpath"
  ssh_cmd sudo -Ski --prompt= tee "$cmdpath" <<<"$SSH_SUDO_PASS
$*" >/dev/null
  ssh_cmd tee "$askpath" <<<"#!/usr/bin/env sh
echo $SSH_SUDO_PASS" >/dev/null
  ssh_cmd SUDO_ASKPASS="$askpath" sudo -A "$cmdpath" || ret=$?
  ssh_sudo_cmd rm "$cmdpath" "$askpath"
  return $ret
}

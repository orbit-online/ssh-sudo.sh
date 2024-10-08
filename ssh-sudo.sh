#!/usr/bin/env bash

ssh_cmd() {
  # Quotes get lost in transmission to sudo over SSH
  # Instead we escape all arguments and pass them on verbatim
  # shellcheck disable=SC2046
  ssh "${SSH_OPTS[@]}" "${SSH_USER:-$USER}@${SSH_HOST:?}" -- $(printf "%q " "$@")
}

ssh_sudo_cmd() {
  ssh_cmd sudo -Sku "${SSH_SUDO_USER:-root}" -p "" "$@" <<<"${SSH_SUDO_PASS:?}"
}

ssh_sudo() {
  local askpath scriptpath fifopath fifopid ret=0
  {
    askpath=$(ssh_cmd mktemp | sed 's/\r$//g') || return $?
    ssh_cmd chmod u+x "$askpath" || return $?
    fifopath=$(ssh_cmd mktemp -u | sed 's/\r$//g') || return $?
    ssh_cmd mkfifo -m 600 "$fifopath" || return $?
    scriptpath=$(ssh_sudo_cmd mktemp | sed 's/\r$//g') || return $?
    ssh_sudo_cmd chmod u+x "$scriptpath" || return $?
    SSH_SUDO_PASS="$SSH_SUDO_PASS
$*" ssh_sudo_cmd tee "$scriptpath" >/dev/null || return $?
    ssh_cmd tee "$askpath" <<<"#!/usr/bin/env sh
cat \"$fifopath\"
rm -f \"$fifopath\" \"$askpath\"" >/dev/null || return $?
    ssh_cmd tee -a "$fifopath" >/dev/null <<<"${SSH_SUDO_PASS:?}" & fifopid=$!
  } <<<''
  ssh_cmd SUDO_ASKPASS="$askpath" sudo -Aku "${SSH_SUDO_USER:-root}" "$scriptpath" || ret=$?
  {
    ssh_sudo_cmd rm -f "$scriptpath" || true
    # The fifo tee process should be terminated by now. If so that means
    # the askpass script was called and $fifopath and $askpath were removed.
    # If not, something went wrong and we need to clean up remotely.
    ! kill -0 $fifopid &>/dev/null || ssh_cmd rm -f "$askpath" "$fifopath" || true
  } <<<''
  kill -TERM $fifopid >/dev/null 2>&1 || true
  return $ret
}

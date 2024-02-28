# ssh-sudo

Bash library for executing remote sudo commands while preserving the tty.

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/ssh-sudo.sh@<VERSION>
```

## Functions

### `ssh_sudo CMD...`

Run a command as root on the remote.

### `ssh_cmd CMD...`

Run a command as `$SSH_USER` on the remote.

### `ssh_sudo_cmd CMD...`

Run a command as root on the remote but do not preserve the tty stdin
(quicker).

## Environment variables

### `$SSH_USER`

Remote SSH user _required_

### `$SSH_HOST`

Remote SSH host _required_

### `$SSH_OPTS`

Options to pass to all ssh invocations _optional_

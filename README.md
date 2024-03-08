# ssh-sudo

Bash library for executing remote sudo commands while preserving the tty.

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/ssh-sudo.sh@<VERSION>
```

## How it works

`ssh_sudo` works by creating two temporary files on the remote.
The first (`askpass`) is owned and only readable by `$SSH_USER`. `askpass`
echoes the sudo password and deletes itself immediately afterwards.
The second contains the arguments to `ssh_sudo` (`script`).  
`ssh_sudo` then executes `script` with
`SUDO_ASKPASS="$askpassPath" sudo -A "$scriptPath"`.  
`scriptPath` is deleted after the script has completed.

## Functions

### `ssh_sudo [CMD...|SCRIPT]`

Run a command as root on the remote while preserving stdin, stdout,
and stderr.

### `ssh_cmd CMD...`

Run a command as `$SSH_USER` on the remote.

### `ssh_sudo_cmd CMD...`

Run a command as root on the remote but do not preserve stdin
(quicker).

## Environment variables

These variables do not need to be exported, you can define them in your script
as global variables and then use the above functions.

### `$SSH_USER`

Remote SSH user _required_

### `$SSH_HOST`

Remote SSH host _required_

### `$SSH_SUDO_PASS`

sudo password for `$SSH_USER` _required_

### `$SSH_SUDO_USER`

Remote user to sudo to, defaults to `root` _optional_

### `$SSH_OPTS`

Options to pass to all ssh invocations _optional_

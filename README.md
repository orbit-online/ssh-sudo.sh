# ssh-sudo

Bash library for executing remote sudo commands while preserving the tty.

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/ssh-sudo.sh@<VERSION>
```

## How it works

`ssh_sudo` works by creating 3 temporary files on the remote.
The first 2 are owned and only readable by `$SSH_USER`:

- A fifo (named pipe) that outputs the sudo password
- A sudo `askpass` script that reads from the fifo and outputs to stdout

The third is owned and only readable by `$SSH_SUDO_USER`. It contains
the commands that are passed to `ssh_sudo`.
All 3 files are deleted after the commands have completed.

Throughout this entire process, the sudo password is only ever transmitted
to the remote (and any child process) via stdin piping, meaning it will not
be visible in the processlist as an argument at any point in time and is _never_
saved to disk.

### Performance

Performance can be increased considerably by using an SSH control master:

```
SSH_OPTS=(
  -o ControlMaster=auto
  -o ControlPath="$HOME/.ssh/control/myscript-%r@%h:%p"
  -o ControlPersist=120s
  -o ConnectTimeout=10s
)
```

Do note that the control master decides the SSH options. Meaning if the SSH
connection is started without `-t`, any subsequent connections of the same
control master will not have a pseudo-terminal allocation even if `-t` is used.  
In that case a connection on a separate `ControlPath` must be established.

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

Remote SSH user (_required_)

### `$SSH_HOST`

Remote SSH host (_required_)

### `$SSH_SUDO_PASS`

sudo password for `$SSH_USER` (_required_)

### `$SSH_SUDO_USER`

Remote user to sudo to, defaults to `root` (_optional_)

### `$SSH_OPTS`

An array of options to pass to all ssh invocations (_optional_)

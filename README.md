# ssh-sudo

Bash library for executing remote sudo commands while preserving the tty.

## Installation

See [the latest release](https://github.com/orbit-online/ssh-sudo.sh/releases/latest) for instructions.

## How it works

`ssh_sudo` works by creating 3 temporary files on the remote.
The first 2 are owned and only readable by `$SSH_USER`.
The third is owned and only readable by `$SSH_SUDO_USER`.
All 3 files are deleted after the commands have completed.

- A fifo (named pipe) that outputs the sudo password
- A sudo `askpass` script that reads from the fifo and outputs to stdout
- The commands or script that should be run by `$SSH_SUDO_USER`

## Security

The sudo password is only ever transmitted to the remote (and any child process)
via stdin piping, meaning it will not be visible in the processlist as an
argument at any point in time and is _never_ saved to disk.

When used from bash, none of the [variables](#variables) need to be exported,
meaning none of the childprocesses your script runs will be able to see the
sudo password.

The executables `ssh-sudo` and `ssh-sudo-cmd` "un-export" the variables.

A possible exploit is to read the password from the fifo socket that is written
to right before `sudo` is executed. However, the socket is only readable by the
current SSH user, meaning the attacker would have to have access to the login
user account, in which case a slew of other exploits would be possible
regardless (such as aliasing `sudo` or placing a wrapper script in
`~/.local/bin`).

## Performance

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

### `ssh_sudo_cmd CMD...`

Run a command as root on the remote but do not preserve stdin (quicker).

### `ssh_cmd CMD...`

Run a command as `$SSH_USER` on the remote.

## Commands

### `ssh-sudo [CMD...|SCRIPT]`

A wrapper script for [`ssh_sudo`](#ssh_sudo-cmdscript). Expects the necessary
variables to be exported. See [`$_SSH_OPTS`](#_ssh_opts) for how to pass SSH
options.

### `ssh-sudo-cmd CMD...`

A wrapper script for [`ssh_sudo_cmd`](#ssh_sudo_cmd-cmd). Expects the necessary
variables to be exported. See [`$_SSH_OPTS`](#_ssh_opts) for how to pass SSH
options.

## Variables

These variables do not need to be exported, you can define them in your script
as global variables and then use the above functions.

### `$SSH_USER`

Remote SSH user, defaults to `$USER` (_optional_)

### `$SSH_HOST`

Remote SSH host (_required_)

### `$SSH_SUDO_PASS`

sudo password for `$SSH_USER` (_required_)

### `$SSH_SUDO_USER`

Remote user to sudo to, defaults to `root` (_optional_)

### `$SSH_OPTS`

An array of options to pass to all ssh invocations (_optional_)

### `$_SSH_OPTS`

Command version of `$SSH_OPTS` (_optional_). Bash arrays cannot be exported as
environment variables, instead `$_SSH_OPTS` must be string with each parameter
separated by a record separator char (`RS` or `\x1e` in hex). In bash you can
it would look like this:
`export _SSH_OPTS=$'-o\x1eForwardAgent=yes\x1e-t\x1e-q'`.

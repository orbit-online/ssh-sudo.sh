# ssh-sudo

Bash library for executing remote sudo commands with a cached password.

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/ssh-sudo.sh@<VERSION>
```

Requires [socket-credential-cache](https://github.com/orbit-online/socket-credential-cache)
to be set up.

## Functions

### `ssh_cmd CMD...`

Run command on the remote

### `ssh_sudo CMD...`

Run command with `sudo` on the remote

### `get_sudo_pass`

Get or prompt the `sudo` password.

## Environment variables

### `$SSH_USER`

Remote SSH user _required_

### `$SSH_HOST`

Remote SSH host _required_

### `$SSH_OPTS`

Options to pass to all ssh invocations _optional_

### `$SSH_STRIP_CR`

Whether to strip carriage returns from the output _optional_.  
Default: `true`

### `$SSH_SUDO_PASS`

`sudo` password to use (instead of prompting or retrieving it from cache) _optional_

### `$SSH_SUDO_PASS_CACHE_TIMEOUT`

Timeout for to set on `socket-credential-cache`. Defaults to the timeout that socket-credential-cache uses.

# Ivan's Dotfiles

Personal, reproducible workstation configuration for Debian and Ubuntu.

The repository contains the tools and configuration used across my workstations:

- Shell: Zsh, Zoxide, FZF, Eza, Bat, and Starship.
- Editor: Neovim with the latest LazyVim starter and personal overrides.
- Git: Git, Git LFS, GitHub CLI, and personal Git defaults.
- Terminal: Tmux.
- Utilities: Ripgrep, fd, jq, ShellCheck, and shfmt.
- Runtime management: mise, Node.js, and pnpm.
- Corlabs tooling: Herdr configuration and plugin lockfile.

## Install

Clone this repository and run the installer:

```sh
git clone <private-repository-url> "$HOME/.dotfiles"
"$HOME/.dotfiles/install.sh"
```

The installer is intended for Debian and Ubuntu. On Ubuntu it enables the
official `universe` repository because several workstation tools are published
there. It validates package availability before installation, is idempotent,
and creates timestamped backups before replacing existing managed files.

`mise` is installed from its official installer when it is not already
available. Herdr is intentionally not downloaded from an arbitrary URL: its
release/distribution source must be configured separately when a new machine
does not already provide the `herdr` executable.

After installation, start a new shell or run:

```sh
exec zsh
```

Authentication is intentionally not automated. Configure GitHub CLI, SSH, and
other credentials separately on each machine.

## Managed files

The installer copies these files from this repository:

```text
~/.zshrc                 shell/zshrc
~/.config/starship.toml  starship/starship.toml
~/.gitconfig              git/gitconfig
~/.tmux.conf              tmux/tmux.conf
~/.config/mise/config.toml mise/config.toml
~/.config/herdr/config.toml herdr/config.toml
~/.config/herdr/.plugins.lock herdr/.plugins.lock
```

The installed files are independent copies, not symlinks. The repository can
be removed from the machine after installation without breaking the shell,
editor, or other tools. Rerunning the installer backs up changed files under
`~/.dotfiles-backups/` before replacing them.

Machine-specific overrides are not managed by this repository. Secrets, SSH
keys, command history, caches, sessions, logs, and authentication databases
must never be committed here.

## Why these tools

| Tool | Purpose |
| --- | --- |
| `zsh` | Interactive shell and completion support |
| `zoxide` | Fast directory navigation |
| `fzf` | Fuzzy search and shell completion |
| `eza` | Modern directory listings |
| `bat` | Readable file previews |
| `starship` | Cross-machine shell prompt |
| `neovim` / `LazyVim` | Primary editor and plugin configuration |
| `lazygit` | Terminal Git interface |
| `git` / `git-lfs` | Source control and large files |
| `gh` | GitHub workflows from the terminal |
| `tmux` | Persistent terminal sessions |
| `mise` | Reproducible runtime versions |
| `herdr` | Corlabs workstation tooling |
| `ripgrep` / `fd` | Fast search |
| `jq` | JSON inspection |
| `shellcheck` / `shfmt` | Shell script quality |

## Updating

Update the repository, then rerun the installer:

```sh
git -C "$HOME/.dotfiles" pull --ff-only
"$HOME/.dotfiles/install.sh"
```

Neovim is bootstrapped from the latest `LazyVim/starter` repository on each
installation. This repository only owns the personal `options.lua`,
`keymaps.lua`, and `linting.lua` overrides. Runtime versions are declared in
`mise/config.toml`.

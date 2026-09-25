#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }

if [[ "$(id -u)" -eq 0 ]]; then
  warn "Run this installer as your normal user, not as root."
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  warn "Cannot detect the operating system."
  exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
case "${ID:-}" in
  debian|ubuntu) ;;
  *) warn "Unsupported distribution: ${ID:-unknown}. Debian and Ubuntu are supported."; exit 1 ;;
esac

if [[ "$ID" == "ubuntu" ]]; then
  info "Enabling Ubuntu universe repository"
  if ! command -v add-apt-repository >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends software-properties-common
  fi
  sudo add-apt-repository -y universe
fi

info "Installing system packages"
sudo apt-get update
mapfile -t apt_packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$repo_root/packages/apt.txt")
missing_packages=()
for package in "${apt_packages[@]}"; do
  if ! apt-cache show "$package" >/dev/null 2>&1; then
    missing_packages+=("$package")
  fi
done
if ((${#missing_packages[@]} > 0)); then
  warn "Packages are unavailable in the configured repositories:"
  printf '  %s\n' "${missing_packages[@]}" >&2
  exit 1
fi
sudo apt-get install -y --no-install-recommends "${apt_packages[@]}"

# Debian and Ubuntu package the fd binary as fdfind to avoid a name collision.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -s -- "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if ! command -v mise >/dev/null 2>&1; then
  info "Installing mise"
  curl --fail --location https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

backup_and_link() {
  local source_path="$1" target_path="$2"
  mkdir -p "$(dirname -- "$target_path")"
  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if [[ "$(readlink -f -- "$target_path" 2>/dev/null || true)" == "$(readlink -f -- "$source_path")" ]]; then
      return
    fi
    mkdir -p "$backup_root"
    mv -- "$target_path" "$backup_root/$(basename -- "$target_path")"
  fi
  ln -s -- "$source_path" "$target_path"
}

info "Linking configuration"
backup_and_link "$repo_root/shell/zshrc" "$HOME/.zshrc"
backup_and_link "$repo_root/starship/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$repo_root/git/gitconfig" "$HOME/.gitconfig"
backup_and_link "$repo_root/tmux/tmux.conf" "$HOME/.tmux.conf"
backup_and_link "$repo_root/mise/config.toml" "$HOME/.config/mise/config.toml"
backup_and_link "$repo_root/herdr/config.toml" "$HOME/.config/herdr/config.toml"
backup_and_link "$repo_root/herdr/.plugins.lock" "$HOME/.config/herdr/.plugins.lock"

info "Installing the latest LazyVim starter"
if [[ -e "$HOME/.config/nvim" || -L "$HOME/.config/nvim" ]]; then
  mkdir -p "$backup_root"
  mv -- "$HOME/.config/nvim" "$backup_root/nvim"
fi
git clone --depth=1 https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"
mkdir -p "$HOME/.config/nvim/lua/config" "$HOME/.config/nvim/lua/plugins"
backup_and_link "$repo_root/nvim/lua/config/options.lua" "$HOME/.config/nvim/lua/config/options.lua"
backup_and_link "$repo_root/nvim/lua/config/keymaps.lua" "$HOME/.config/nvim/lua/config/keymaps.lua"
backup_and_link "$repo_root/nvim/lua/plugins/linting.lua" "$HOME/.config/nvim/lua/plugins/linting.lua"

if command -v mise >/dev/null 2>&1; then
  info "Installing mise-managed runtimes"
  mise trust "$repo_root/mise/config.toml"
  mise --cd "$repo_root" install
fi

if command -v git-lfs >/dev/null 2>&1; then
  git lfs install
fi

if [[ -n "${backup_root:-}" && -d "$backup_root" ]]; then
  info "Existing files were backed up under $backup_root"
fi
info "Installation complete. Start a new Zsh session with: exec zsh"

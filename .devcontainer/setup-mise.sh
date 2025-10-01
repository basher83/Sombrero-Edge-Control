#!/bin/sh
set -eu

#region logging setup
if [ "${MISE_DEBUG-}" = "true" ] || [ "${MISE_DEBUG-}" = "1" ]; then
  debug() {
    echo "$@" >&2
  }
else
  debug() {
    :
  }
fi

if [ "${MISE_QUIET-}" = "1" ] || [ "${MISE_QUIET-}" = "true" ]; then
  info() {
    :
  }
else
  info() {
    echo "$@" >&2
  }
fi

error() {
  echo "$@" >&2
  exit 1
}
#endregion

install_mise() {
  # Download and install mise using the main install script
  info "mise: downloading and installing mise..."
  
  if [ -x "$(command -v curl)" ]; then
    curl -fsSL https://mise.jdx.dev/install.sh | sh
  elif [ -x "$(command -v wget)" ]; then
    wget -qO- https://mise.jdx.dev/install.sh | sh
  else
    error "mise install requires curl or wget but neither is installed. Aborting."
  fi
  
  install_path="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"
  
  if [ ! -f "$install_path" ]; then
    error "mise installation failed"
  fi
  
  info "mise: installed successfully to $install_path"
}

setup_zsh_activation() {
  install_path="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"
  zshrc="${ZDOTDIR-$HOME}/.zshrc"
  
  # Check if activation is already set up
  if [ -f "$zshrc" ] && grep -qF "# added by https://mise.run/zsh" "$zshrc"; then
    info "mise: zsh activation already configured in $zshrc"
    return
  fi
  
  # Add activation to zsh config
  info "mise: adding activation to $zshrc"
  
  if [ ! -f "$zshrc" ]; then
    touch "$zshrc"
  fi
  
  # Add activation line
  echo "" >> "$zshrc"
  echo "eval \"\$($install_path activate zsh)\" # added by https://mise.run/zsh" >> "$zshrc"
  
  info "mise: activation added to $zshrc"
  info "mise: restart your shell or run 'source $zshrc' to activate mise"
  info "mise: run 'mise doctor' to verify setup"
}

# Main execution
install_mise
setup_zsh_activation

info ""
info "mise: setup complete! ðŸŽ‰"
info "mise: restart your shell or run 'source ${ZDOTDIR-$HOME}/.zshrc' to start using mise"
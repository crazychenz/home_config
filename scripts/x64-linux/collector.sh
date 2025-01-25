#!/bin/bash 

USER_SETTINGS_FPATH=${HOME}/.bash-user-settings.sh

K3S_VERSION=v1.30.0%2Bk3s1
KETALL_VERSION=v1.3.8
TMUX_VERSION=v3.3a
NVIM_VERSION=v0.10.3
LAZYGIT_VERSION=0.45.2
VIVID_VERSION=v0.10.1
YAZI_VERSION=v0.4.2
GLOW_VERSION=2.0.0

VIVID_THEME=catppuccin-mocha
LAZYGIT_THEME=mocha/blue.yml
YAZI_THEME=mocha/catppuccin-mocha-yellow.toml
BTOP_THEME=catppuccin_mocha.theme
K9S_THEME=catppuccin-mocha

### Initialize config setup

mkdir -p ${HOME}/.config && chmod 700 ${HOME}/.config
mkdir -p ${HOME}/.local/bin && chmod 700 ${HOME}/.local
# Initialize .bash-user-settings.sh, a key entry point for my other config setups.
cp /opt/files/bash-user-settings.sh ${USER_SETTINGS_FPATH}

#if [ -e "${HOME}/.bashrc" ]; then
#  if [ -z "$(grep 'bash-user-settings.sh' ${HOME}/.bashrc)" ]; then
#    # bash-user-settings not found in bashrc, assume its ok to append
#    echo "source ~/.bash-user-settings.sh" >> ${HOME}/.bashrc
#  fi
#else
#  echo "Could not find bashrc. Run \`echo \"source ~/.bash-user-settings.sh\" \>\> ~/.bashrc\` manually."
#fi

# All the things we'll install go into .local/bin, add it to path (w/ precedence).
echo "export PATH=~/.local/bin:\$PATH" >> ${USER_SETTINGS_FPATH}
export PATH=~/.local/bin:$PATH


### Setup Tmux
# https://github.com/mjakob-gh/build-static-tmux/releases
cd /opt/downloads
if [ -e "tmux.linux-amd64.gz" ]; then
  echo "tmux already downloaded. Skipping"
else
  curl -LO https://github.com/mjakob-gh/build-static-tmux/releases/download/${TMUX_VERSION}/tmux.linux-amd64.gz
fi
zcat tmux.linux-amd64.gz > ${HOME}/.local/bin/tmux
chmod +x ${HOME}/.local/bin/tmux

# https://github.com/tmux-plugins/tpm
mkdir -p ${HOME}/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
cp /opt/files/tmux.conf ${HOME}/.tmux.conf
tmux source ~/.tmux.conf
# start a server but don't attach to it
tmux start-server
# create a new session but don't attach to it either
tmux new-session -d
# install the plugins
${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh
# kill the server
tmux kill-server


### Setup NeoVim

# Known Issues:
# - NeoVim is not statically built.
# - Upstream NeoVim requires glibc so it will not work on alpine.
# - Upstream NeoVim appimage's are no better, and also require GNU symbols.
# - AppImage's IIRC require fuse (a kernel module), something not everywhere.
# - In Alpine we install neovim from repo.
# - Nvchad wants a compiler. (debian - build_essential, alpine - build-base)

## Upstream NeoVim
##https://github.com/neovim/neovim/releases
##cd /opt/downloads
##if [ -e "nvim-linux64.tar.gz" ]; then
##  echo "nvim (gnu) already downloaded. Skipping"
##else
##  # Requires glibc
##  curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz
##fi
###tar -xf nvim-linux64.tar.gz
###rsync -a nvim-linux64/ ${HOME}/.local/

## Upstream NeoVim with AppImage
##if [ -e "nvim.appimage" ]; then
##  echo "nvim (appimage) already downloaded. Skipping"
##else
##  # Requires fuse
##  curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
##fi
##cp nvim.appimage ${HOME}/.local/bin/nvima
##chmod +x ${HOME}/.local/bin/nvima

# https://github.com/NvChad/NvChad
git clone https://github.com/NvChad/starter ${HOME}/.config/nvim
echo "" >> ${HOME}/.config/nvim/init.lua
echo 'vim.cmd("hi Normal guibg=NONE")' >> ${HOME}/.config/nvim/init.lua
echo "vim.cmd(\"cnoreabbrev <expr> q getcmdtype() == \\\":\\\" && getcmdline() == 'q' ? '' : 'q'\")" >> ${HOME}/.config/nvim/init.lua
cp /opt/files/nvim-lua-mappings.lua ${HOME}/.config/nvim/lua/mappings.lua
nvim &
NVIM_PID=$!
echo "Waiting 30 seconds to give NVIM time to download plugins."
sleep 30
kill $NVIM_PID
tput reset
tput cnorm
clear


### Setup LazyGit

cd /opt/downloads
if [ -e "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" ]; then
  echo "lazygit already downloaded. Skipping."
else
  curl -LO https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
fi
tar -xf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
cp lazygit ${HOME}/.local/bin/
# Theme it.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/lazygit
mkdir -p $(lazygit --print-config-dir)
touch $(lazygit --print-config-dir)/config.yml
cp ${HOME}/.config/catppuccin/lazygit/themes/mocha/blue.yml $(lazygit --print-config-dir)/theme.yml 
echo "export LG_CONFIG_FILE=\"\$(lazygit --print-config-dir)/config.yml,\$(lazygit --print-config-dir)/theme.yml\"" >> ${USER_SETTINGS_FPATH}


### Setup Vivid

cd /opt/downloads
if [ -e "vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz" ]; then
  echo "vivid already downloaded. skipping."
else
  curl -LO https://github.com/sharkdp/vivid/releases/download/${VIVID_VERSION}/vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz
fi
tar -xf vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz
cp /opt/downloads/vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl/vivid ${HOME}/.local/bin/

### Setup LS_COLORS with vivid.
echo "export LS_COLORS=\"\$(vivid generate ${VIVID_THEME})\"" >> ${USER_SETTINGS_FPATH}
#echo PATH is $PATH


### Setup Yazi

cd /opt/downloads
if [ -e "yazi-x86_64-unknown-linux-musl.zip" ]; then
  echo "yazi already downloaded. skipping."
else
  curl -LO https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip
fi
unzip -o yazi-x86_64-unknown-linux-musl.zip
cp yazi-x86_64-unknown-linux-musl/yazi ${HOME}/.local/bin/
cp yazi-x86_64-unknown-linux-musl/ya ${HOME}/.local/bin/
# Theme it.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/yazi
mkdir -p ${HOME}/.config/yazi
cp ${HOME}/.config/catppuccin/yazi/themes/${YAZI_THEME} ~/.config/yazi/theme.toml


### Setup glow

cd /opt/downloads
if [ -e "glow_${GLOW_VERSION}_Linux_x86_64.tar.gz" ]; then
  echo "glow already downloaded. skipping."
else
  curl -LO https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_x86_64.tar.gz
fi
tar -xf glow_${GLOW_VERSION}_Linux_x86_64.tar.gz
cp /opt/downloads/glow_${GLOW_VERSION}_Linux_x86_64/glow ${HOME}/.local/bin/


### Setup K8s and tools

# https://github.com/k3s-io/k3s/releases
cd /opt/downloads
if [ -e "k3s" ]; then
  echo "k3s already downloaded. Skipping."
else
  # Download k3s binary
  curl -LO https://github.com/k3s-io/k3s/releases/download/$K3S_VERSION/k3s
fi
  # Install k3s to bundle
cp k3s ${HOME}/.local/bin/
chmod +x k3s
cd ${HOME}/.local/bin ; ln -s k3s kubectl
chmod +x ${HOME}/.local/bin/kubectl
# Add kubectl completion to bash config
echo "source <(kubectl completion bash)" >> ${USER_SETTINGS_FPATH}
# Add alias w/ completion
echo "alias kc=kubectl" >> ${USER_SETTINGS_FPATH} 
echo "complete -o default -F __start_kubectl kc" >> ${USER_SETTINGS_FPATH}

## https://github.com/fluxcd/flux2/releases
#cd /opt/downloads
#if [ -e "flux_2.3.0_linux_amd64.tar.gz" ]; then
#  echo "flux_2.3.0_linux_amd64.tar.gz already downloaded. Skipping."
#else
#  curl -LO https://github.com/fluxcd/flux2/releases/download/v2.3.0/flux_2.3.0_linux_amd64.tar.gz
#fi

# https://github.com/corneliusweig/ketall/releases
cd /opt/downloads/
if [ -e "get-all-amd64-linux.tar.gz" ]; then
  echo "get-all-amd64-linux.tar.gz already downloaded. Skipping."
else
  curl -LO https://github.com/corneliusweig/ketall/releases/download/$KETALL_VERSION/get-all-amd64-linux.tar.gz
fi
tar -xf get-all-amd64-linux.tar.gz get-all-amd64-linux
mv get-all-amd64-linux ${HOME}/.local/bin/kubectl-get_all


cd /opt/downloads
if [ -e "k9s_Linux_amd64.tar.gz" ]; then
  echo "k9s already downloaded. skipping."
else
  curl -LO https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_Linux_amd64.tar.gz
fi
tar -xf k9s_Linux_amd64.tar.gz
cp k9s ${HOME}/.local/bin/
# Theme it.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/k9s
mkdir -p ${HOME}/.config/k9s/skins
cp ${HOME}/.config/catppuccin/k9s/dist/* ${HOME}/.config/k9s/skins/
k9s &
K9S_PID=$!
sleep 1
kill $K9S_PID
tput reset
tput cnorm
clear
yq eval ".k9s.ui.skin = ${K9S_THEME}" -i ~/.config/k9s/config.yaml


### Setup btop

# Theme btop.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/btop
mkdir -p ${HOME}/.config/btop/themes
cp ${HOME}/.config/catppuccin/btop/themes/${BTOP_THEME} ${HOME}/.config/btop/themes/


### Setup tty

# This requires manual setup, but we'll throw themes in the bundle.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/tty


### End of script, open shell if indicated.

cd /home/user
if [ "${OPEN_SHELL}" == "yes" ]; then
  /bin/bash -i
fi

### Other tools to consider integrating:
# starship
#   theme: https://github.com/catppuccin/starship
# lsd
#   theme: https://github.com/catppuccin/lsd
# cutter
#   theme: https://github.com/catppuccin/cutter
# fzf
#   theme: https://github.com/catppuccin/fzf


### Other tools to consider looking at:
#
# Ghidra - binary analysis
# aerc - email client
#   theme: https://github.com/catppuccin/aerc
# imhex
#   theme: https://github.com/catppuccin/imhex
# spotify-tui
#   theme: https://github.com/catppuccin/spotify-tui
# asciinema
#   theme: https://github.com/catppuccin/asciinema
# lxqt
#   theme: https://github.com/catppuccin/lxqt
# duckduckgo
#   theme: https://github.com/catppuccin/duckduckgo


### Other things to checkout, but not here.
#
# sidebery - firefox bookmark manager
# insomnia - postman oss
# brave browser
# firefox
# notepad-plus-plus
# vscodium
# zed
# alacritty




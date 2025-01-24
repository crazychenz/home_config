#!/bin/bash 

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

mkdir -p ${HOME}/.config
mkdir -p ${HOME}/.local/bin
cp /opt/files/bashrc ${HOME}/.bashrc
cp /opt/files/bash-user-settings.sh ${HOME}/.bash-user-settings.sh
echo "source ~/.bash-user-settings.sh" >> ${HOME}/.bashrc
echo "export PATH=~/.local/bin:\$PATH" >> ${HOME}/.bashrc
echo "export LS_COLORS=\"\$(vivid generate ${VIVID_THEME})\"" >> ${HOME}/.bashrc
export PATH=~/.local/bin:$PATH
#echo PATH is $PATH

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


##if [ -e "nvim.appimage" ]; then
##  echo "nvim (appimage) already downloaded. Skipping"
##else
##  # Requires fuse
##  curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
##fi
##cp nvim.appimage ${HOME}/.local/bin/nvima
##chmod +x ${HOME}/.local/bin/nvima

# In Alpine we install neovim from repo.
# Nvchad wants a compiler.

# https://github.com/NvChad/NvChad
git clone https://github.com/NvChad/starter ${HOME}/.config/nvim
echo "" >> ${HOME}/.config/nvim/init.lua
echo 'vim.cmd("hi Normal guibg=NONE")' >> ${HOME}/.config/nvim/init.lua
echo "vim.cmd(\"cnoreabbrev <expr> q getcmdtype() == \\\":\\\" && getcmdline() == 'q' ? '' : 'q'\")" >> ${HOME}/.config/nvim/init.lua
cp /opt/files/nvim-lua-mappings.lua ${HOME}/.config/nvim/lua/mappings.lua
nvim &
NVIM_PID=$!
sleep 15
kill $NVIM_PID
tput reset
tput cnorm
clear


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
ln -s ${HOME}/.config/catppuccin/lazygit/themes/${LAZYGIT_THEME} $(lazygit --print-config-dir)/theme.yml
echo "export LG_CONFIG_FILE=\"$(lazygit --print-config-dir)/config.yml,$(lazygit --print-config-dir)/theme.yml\"" >> ./.bashrc



cd /opt/downloads
if [ -e "vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz" ]; then
  echo "vivid already downloaded. skipping."
else
  curl -LO https://github.com/sharkdp/vivid/releases/download/${VIVID_VERSION}/vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz
fi
tar -xf vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl.tar.gz
cp /opt/downloads/vivid-${VIVID_VERSION}-x86_64-unknown-linux-musl/vivid ${HOME}/.local/bin/


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
ln -s ${HOME}/.config/catppuccin/yazi/themes/${YAZI_THEME} ~/.config/yazi/theme.toml


cd /opt/downloads
if [ -e "glow_${GLOW_VERSION}_Linux_x86_64.tar.gz" ]; then
  echo "glow already downloaded. skipping."
else
  curl -LO https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_x86_64.tar.gz
fi
tar -xf glow_${GLOW_VERSION}_Linux_x86_64.tar.gz
cp /opt/downloads/glow_${GLOW_VERSION}_Linux_x86_64/glow ${HOME}/.local/bin/






## https://github.com/fluxcd/flux2/releases
#cd /opt/downloads
#if [ -e "flux_2.3.0_linux_amd64.tar.gz" ]; then
#  echo "flux_2.3.0_linux_amd64.tar.gz already downloaded. Skipping."
#else
#  curl -LO https://github.com/fluxcd/flux2/releases/download/v2.3.0/flux_2.3.0_linux_amd64.tar.gz
#fi


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
ln ${HOME}/.local/bin/k3s ${HOME}/.local/bin/kubectl
chmod +x ${HOME}/.local/bin/kubectl
# Add kubectl completion to bash config
echo "source <(kubectl completion bash)" >> ~/.bashrc
# Add alias w/ completion
echo "alias kc=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl kc" >> ~/.bashrc
chmod +x k3s


# https://github.com/corneliusweig/ketall/releases
cd /opt/downloads/
if [ -e "get-all-amd64-linux.tar.gz" ]; then
  echo "get-all-amd64-linux.tar.gz already downloaded. Skipping."
else
  curl -LO https://github.com/corneliusweig/ketall/releases/download/$KETALL_VERSION/get-all-amd64-linux.tar.gz
fi
tar -xf get-all-amd64-linux.tar.gz get-all-amd64-linux
mv get-all-amd64-linux ${HOME}/.local/bin/kubectl-get_all


# Theme btop.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/btop
mkdir -p ${HOME}/.config/btop/themes
ln -s ${HOME}/.config/catppuccin/btop/themes/${BTOP_THEME} ${HOME}/.config/btop/themes/


# This requires manual setup, but we'll throw themes in the bundle.
mkdir -p ${HOME}/.config/catppuccin/ && cd ${HOME}/.config/catppuccin/ 
git clone https://github.com/catppuccin/tty


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

# starship
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/starship
# lsd
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/lsd
# cutter
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/cutter
# fzf
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/fzf
# ghidra?
# tty
#
# aerc? - email client
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/aerc
# imhex
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/imhex
# spotify-tui
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/spotify-tui
# asciinema
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/asciinema
# lxqt
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/lxqt
# duckduckgo
#cd /opt/downloads/catppuccin && git clone https://github.com/catppuccin/duckduckgo





# Things to checkout, but not here.
# sidebery - firefox bookmark manager
# insomnia - postman oss
# brave browser
# firefox
# notepad-plus-plus
# vscodium
# zed
# alacritty
#
#
cd /home/user
/bin/bash -i 

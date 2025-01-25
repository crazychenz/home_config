#!/bin/sh

export OPEN_SHELL=no
./collect.sh

#tar -cf bundle.tar bundle/x64-linux
SCRIPT_NAME=x64-linux_config_install.sh
TARFLAG="" # optionally add compression flag (gzip=>-z, bzip2=>-j, xz=>-J)
cat >${SCRIPT_NAME} <<SH_EOF
#!/bin/sh
export DEST=home_config_backup-\$(date +%Y%m%d-%H%M%S) ; mkdir \${DEST} ; rsync -a .bash-user-settings.sh \${DEST}/ ; rsync -a .tmux.conf \${DEST}/ ; rsync -a .config/ \${DEST}/.config/ ; rsync -a .local/ \${DEST}/.local/ ; rsync -a .tmux/ \${DEST}/.tmux/ ; rsync -a .cache/ \${DEST}/.cache/
sed '1,10d' \$0 | tar --strip-components=2 -x
[ -e ".bashrc" -a -z "\$(grep 'bash-user-settings.sh' .bashrc)" ] && echo "source ~/.bash-user-settings.sh" >> .bashrc
[ ! -z "\$(ldd --version | grep -i -e gnu -e glibc)" ] && echo "export PATH=~/.local/nvim-linux64/bin:\\\$PATH" >> .bash-user-settings.sh



exit 0
# Verbatim tar data following this 10th line.
SH_EOF
tar $TARFLAG -c bundle/x64-linux >>${SCRIPT_NAME}
chmod +x ${SCRIPT_NAME}


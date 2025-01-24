#!/bin/sh

./collect.sh

tar -cf bundle.tar bundle/x64-linux
SCRIPT_NAME=x64-linux_config_install.sh
TARFLAG="" # optionally add compression flag (gzip=>-z, bzip2=>-j, xz=>-J)
cat >${SCRIPT_NAME} <<SH_EOF
#!/bin/sh
sed '1,10d' \$0 | tar -x






exit 0
# Verbatim tar data following this 10th line.
SH_EOF
tar $TARFLAG -c bundle/x64-linux >>${SCRIPT_NAME}
chmod +x ${SCRIPT_NAME}


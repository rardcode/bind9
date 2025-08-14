#!/bin/bash
set -x

# put here dirs that must be made persistent
list_dirs() {
cat <<EOF
#/dirs/tobe/make/persistent
EOF
}

outListDirs=$(list_dirs | grep -v ^#)

function _dirs {
DEST_PATH="/data"

if [ ! -z $outListDirs ]; then

 echo "--------------------------------------"
 echo " Moving persistent data in $DEST_PATH "
 echo "--------------------------------------"

 list_dirs | while read path_name DUMMY; do
  if [ ! -e ${DEST_PATH}${path_name} ]; then
   if [ -d $path_name ]; then
    rsync -Ra ${path_name}/ ${DEST_PATH}/
   else
    rsync -Ra ${path_name} ${DEST_PATH}/
   fi
  else
   echo "---------------------------------------------------------"
   echo " No NEED to move anything for $path_name in ${DEST_PATH} "
   echo "---------------------------------------------------------"
  fi
  rm -rf ${path_name}
  ln -s ${DEST_PATH}${path_name} ${path_name}
 done
fi
}

function _main {
 # if it is first execution, put default files in /data dir
 if [ ! -e ${DEST_PATH}/.initialized ]; then
  [ -e "/data/named.conf" ] || cp "/template/named.conf" "/data/"
  [ -e "/data/db.mydomain.lan.zone" ] || cp "/template/db.mydomain.lan.zone" "/data"
  [ -e "/data/db.192.168.0.zone" ] || cp "/template/db.192.168.0.zone" "/data"
  touch ${DEST_PATH}/.initialized
 fi

 chown -R 100:100 /data
 # define CMD to be launched
 CMD="/usr/sbin/named -u bind -g -c /data/named.conf"
}

function custom_bashrc {
echo '
export LS_OPTIONS="--color=auto"
alias "ls=ls $LS_OPTIONS"
alias "ll=ls $LS_OPTIONS -la"
alias "l=ls $LS_OPTIONS -lA"
'
}

function _bashrc {
echo "-----------------------------------------"
echo " .bashrc file setup..."
echo "-----------------------------------------"
custom_bashrc | tee /root/.bashrc
echo 'export PS1="\[\e[35m\][\[\e[31m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]# "' >> /root/.bashrc
for i in $(ls /home); do echo 'export PS1="\[\e[35m\][\[\e[33m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]$ "' >> /home/${i}/.bashrc; done
}

_dirs
_main
_bashrc

#CMD="$@"
[ -z "$CMD" ] && export CMD="supervisord -c /etc/supervisor/supervisord.conf"

exec $CMD

exit $?

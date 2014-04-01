#!/bin/bash

PATH=/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin

# see if we need to fix the nagios user's uid/gid, and get the current values
if [[ $(id nagios 2>&1 | awk -F= '{print $1}') != "uid" ]]; then
  echo "nagios user doesn't exist"
elif [[ $(id -u nagios) == 300 && $(id -g nagios) == 300 ]] ; then
  echo "Nothing to change for nagios user"
else
  olduid=$(id -u nagios)
  oldgid=$(id -g nagios)

  echo "Changing nagios from ${olduid}:${oldgid} to 300:300"

  # if nrpe is running, shut it down
  if $(/sbin/service nrpe status >/dev/null 2>&1); then
    RESTART_NRPE=0
    /sbin/service nrpe stop
  fi

  # do the evil chown's and then fix the uid/gid
  find / -uid $olduid -print0 | xargs -0 chown -h 300
  find / -gid $oldgid -print0 | xargs -0 chgrp -h 300
  groupmod -g 300 nagios
  usermod -u 300 -g 300 nagios

  # restart nrpe if it was running
  if [[ $RESTART_NRPE == 0 ]]; then
    /sbin/service nrpe start
  fi
fi

# do the same for the nrpe user
if [[ $(id nrpe 2>&1 | awk -F= '{print $1}') != "uid" ]]; then
  echo "nrpe user doesn't exist"
elif [[ $(id -u nrpe) == 301 && $(id -g nrpe) == 301 ]] ; then
  echo "Nothing to change for nrpe user"
else
  olduid=$(id -u nrpe)
  oldgid=$(id -g nrpe)

  echo "Changing nrpe from ${olduid}:${oldgid} to 301:301"

  # if nrpe is running, shut it down
  if $(/sbin/service nrpe status >/dev/null 2>&1); then
    RESTART_NRPE=0
    /sbin/service nrpe stop
  fi

  # do the evil chown's and then fix the uid/gid
  find / -uid $olduid -print0 | xargs -0 chown -h 301
  find / -gid $oldgid -print0 | xargs -0 chgrp -h 301
  groupmod -g 301 nrpe
  usermod -u 301 -g 301 nrpe

  # restart nrpe if it was running
  if [[ $RESTART_NRPE == 0 ]]; then
    /sbin/service nrpe start
  fi
fi

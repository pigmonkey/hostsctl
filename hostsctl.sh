#!/usr/bin/env bash
# 
# Copyright (C) 2017 Levi Sabah (0xl3vi) <0xl3vi@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# place here URL for hosts file.
URL=""
HOSTS="/etc/hosts"

hosts_usage() {
cat << END
Usage $0 [option] [host] ...
  
Hostsctl.sh allows you to block ads, social networks, porn etc..
by controlling /etc/hosts file.

Arguments:
  enable     enable [host].
  disable    disable [host]
  update     update the /etc/hosts file.

END
}

# msg_check: show message when successfully done
# @param $@: text
msg_check() {
  printf "$(tput setf 2)\u2713$(tput sgr0) $1\n"
}

# msg_error: show error message
# @param $@: text
msg_error() {
  printf "$(tput setf 4)# error:$(tput sgr0) $@\n"
}

# hosts_action: enable/disable [host]
# @param action: 1 = enable, 0 = disable.
# @param host  : hostt name (domain.ltd)
hosts_action() {
  if [ $1 -eq 1 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) != "#" ) printf("#%s\n", $0); else print $0 }' ${HOSTS} \
    > /tmp/hosts
    msg_check "$2 enabled."
  elif [ $1 -eq 0 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) == "#" ) print substr($0, 2); else print $0 }' ${HOSTS} \
    > /tmp/hosts
    msg_check "$2 disabled."
  fi
  mv /tmp/hosts ${HOSTS}
}

# hosts_update: update the /etc/hosts list
hosts_update() {
  curl -o "${HOSTS}" -L "${URL}" -s
  msg_check "/etc/hosts $(tput setf 1)updated.$(tput sgr0)"
}

if [ $UID -ne 0 ];then
  hosts_usage
  msg_error "please run as root."
  exit
fi

case $1 in
  disable)
    hosts_action 0 "$2";;
  enable)
    hosts_action 1 "$2";;
  update)
    hosts_update;;
  --help)
    hosts_usage;;
  *)
    hosts_usage;;
esac

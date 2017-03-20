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

_VERSION="0.2"

# place here URL for hosts file.
# default blocking fakenews,gambling,porn and social networks.
URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
HOSTS="/etc/hosts"
TMP_HOSTS="/tmp/hosts"
IP="0.0.0.0" # Default IP for new entries

# by https://github.com/mathiasbynens/dotfiles
if tput setaf 1 &> /dev/null; then
    tput sgr0; # reset colors
    bold=$(tput bold);
    reset=$(tput sgr0);
    # Solarized colors, taken from http://git.io/solarized-colors.
    black=$(tput setaf 0);
    blue=$(tput setaf 33);
    cyan=$(tput setaf 37);
    green=$(tput setaf 64);
    orange=$(tput setaf 166);
    purple=$(tput setaf 125);
    red=$(tput setaf 124);
    violet=$(tput setaf 61);
    white=$(tput setaf 15);
    yellow=$(tput setaf 136);
else
  bold='';
  reset="\e[0m";
  black="\e[1;30m";
  blue="\e[1;34m";
  cyan="\e[1;36m";
  green="\e[1;32m";
  orange="\e[1;33m";
  purple="\e[1;35m";
  red="\e[1;31m";
  violet="\e[1;35m";
  white="\e[1;37m";
  yellow="\e[1;33m";
fi;

hosts_usage() {
cat << END
Usage $0 [option] [host] ...
  
Hostsctl.sh allows you to block ads, social networks, porn, etc,
by manipulating the /etc/hosts file.

Arguments:
  enable [host]    enable specified host
  disable [host]   disable specified host
  list-enabled     list enabled hosts
  list-disabled    list disabled hosts
  update           update the /etc/hosts file

END
}

# msg_check: show message when successfully done
# @param $@: text
msg_check() {
  printf "${green}\u2713${reset} $1\n"
}

# msg_error: show error message
# @param $@: text
msg_error() {
  printf "${red}# error:${reset} $@\n"
}

root_check() {
  if [ $UID -ne 0 ];then
    msg_error "please run as root."
    exit
  fi
}
# hosts_action: enable/disable [host]
# @param action: 1 = enable, 0 = disable.
# @param host  : host name (domain.ltd)
hosts_action() {
  root_check

  if [ $1 -eq 1 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) != "#" ) printf("#%s\n", $0); else print $0 }' ${HOSTS} \
    > ${TMP_HOSTS}
    msg_check "$2: ${green}enabled${reset}"
  elif [ $1 -eq 0 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) == "#" ) print substr($0, 2); else print $0 }' ${HOSTS} \
    > ${TMP_HOSTS}
    msg_check "$2: ${yellow}disabled${reset}"
  fi

  # create new entry.
  if [ -s ${TMP_HOSTS} ] && [ $1 -eq 0 ] && [[ ! $(grep "$2" ${HOSTS}) ]];then
    echo "${IP}   $2" >> ${HOSTS}
  else
    mv ${TMP_HOSTS} ${HOSTS}
  fi
}

# hosts_list_enabled: list enabled hosts
hosts_list_enabled() {
  hosts=$(awk '{ if ( substr($0, 1, 3) == "#0." ) printf("%s\n", $2) }' ${HOSTS})
  total=0

  for host in $hosts;do
    printf "${green}\u25CF${reset} ${white}${host}${reset}\n"
    total=$[$total+1]
  done
  msg_check "${white}total: ${yellow}${total}"
}

# hosts_list_disabled: list disabled hosts
hosts_list_disabled() {
  hosts=$(awk '{ if ( substr($0, 1, 3) == "0.0" ) printf("%s\n", $2) }' ${HOSTS})
  total=0;

  for host in $hosts;do
    printf "${red}\u25CF${reset} ${white}${host}${reset}\n"
    total=$[$total+1]
  done
  msg_check "${white}total: ${yellow}${total}"
}

# hosts_update: update the /etc/hosts list
hosts_update() {
  root_check

  if [ ! -f ${HOSTS}.bak ] && [ -f ${HOSTS} ];then
    cp "${HOSTS}" "${HOSTS}.bak"
    msg_check "backup: ${blue}${HOSTS}${reset} saved as ${green}${HOSTS}.bak${reset}"
  fi
  curl -o "${HOSTS}" -L "${URL}" -s
  msg_check "update: ${purple}$(wc -l ${HOSTS} )${reset} entries"
}

case $1 in
  disable)
    hosts_action 0 "$2";;
  enable)
    hosts_action 1 "$2";;
  update)
    hosts_update;;
  list-enabled)
    hosts_list_enabled;;
  list-disabled)
    hosts_list_disabled;;
  --help)
    hosts_usage;;
  *)
    hosts_usage;;
esac

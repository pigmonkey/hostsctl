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
# default blocking fakenews,gambling,porn and social networks.
URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
HOSTS="/etc/hosts"

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

# hosts_action: enable/disable [host]
# @param action: 1 = enable, 0 = disable.
# @param host  : host name (domain.ltd)
hosts_action() {
  if [ $1 -eq 1 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) != "#" ) printf("#%s\n", $0); else print $0 }' ${HOSTS} \
    > /tmp/hosts
    msg_check "$2: ${green}enabled${reset}"
  elif [ $1 -eq 0 ];then
    awk -vhost=$2 \
    '{ if ( $0 ~ host && substr($0, 1, 1) == "#" ) print substr($0, 2); else print $0 }' ${HOSTS} \
    > /tmp/hosts
    msg_check "$2: ${yellow}disabled${reset}"
  fi
  mv /tmp/hosts ${HOSTS}
}

# hosts_update: update the /etc/hosts list
hosts_update() {
  curl -o "${HOSTS}" -L "${URL}" -s
  msg_check "/etc/hosts - ${blue}updated.${reset}"
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

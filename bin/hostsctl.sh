#!/usr/bin/env bash
# Copyright (c) 2017 hostsctl.sh authors and contributors
# (https://git.io/hostsctl/)
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
#

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

PREFIX="/etc"
HOSTS="${PREFIX}/hosts"
HOSTSCTL_DIR="${PREFIX}/hostsctl.d"
REMOTE_HOSTS="${HOSTSCTL_DIR}/30-remote"
ENABLED_DISABLED_HOSTS="${HOSTSCTL_DIR}/20-enabled-disabled"
USER_HOSTS="${HOSTSCTL_DIR}/10-hosts"
CONFIG_FILE="${PREFIX}/hostsctl.conf"

# Define default configuration.
remote_hosts='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts' 
ip='0.0.0.0'

# Overwrite the defaults with a config file, if it exists.
if [ -e $CONFIG_FILE ]; then
    . $CONFIG_FILE
fi

hosts_usage() {
cat << END
Usage $0 [option] [host] ...
  
Hostsctl.sh allows you to block ads, social networks, porn, etc,
by manipulating the /etc/hosts file.

Arguments:
  enable [host]    enable specified host
  disable [host]   disable specified host.
  update           update remote hosts and apply to ${HOSTS}
  export           export hosts to stdout
  merge            merge hosts to ${HOSTS}
  list-enabled     list enabled hosts
  list-disabled    list disabled hosts
  fetch-updates    update remote hosts without applying
  restore	   restore ${HOSTS} from ${USER_HOSTS}.

Full documentation at: <http://git.io/hostsctl>
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
  printf "${red}\u2744${reset} $@\n"
}

# msg_warning: show warning message.
# @param $@: text
msg_warning() {
  printf "${yellow}\u2622${reset} $@\n"
}

# msg_info: show info message
# @param $@: text
msg_info() {
  printf "${blue}\u221E${reset} $@\n"
}

root_check() {
  if [ $UID -ne 0 ];then
    msg_error "please run as root."
    exit
  fi
}

# mktemp: create a temporary file with random name
mktemp() {
  local filename="/tmp/hostsctl-${RANDOM}"
  touch "$filename"
  echo "${filename}"
}

# hosts_export: export /etc/hostsctl.d/ to stdout.
hosts_export() {
  cat /etc/hostsctl.d/*
}

# hosts_merge: this will merge /etc/hostsctl.d/ to /etc/hosts
hosts_merge() {
  root_check

  hosts_export > ${HOSTS}
}

_hosts_enable() {
  root_check

  local filename
  local tmpfile=$(mktemp);

  if grep -qw "$1" "${REMOTE_HOSTS}";then
    filename="${REMOTE_HOSTS}"
  elif grep -qw "$1" "${USER_HOSTS}";then
    filename=${USER_HOSTS}
  elif grep -qw "$1" "${ENABLED_DISABLED_HOSTS}";then
    filename=${ENABLED_DISABLED_HOSTS}
  fi

  if [ -z ${filename} ];then
    cp ${ENABLED_DISABLED_HOSTS} ${tmpfile} # Copy current version
    echo "#${ip} $1" >> ${tmpfile} 
    mv "${tmpfile}" "${ENABLED_DISABLED_HOSTS}" # Update
  else
    awk -vhost=$1 \
    '{ if ( $0 ~ host && substr($0, 1, 1) != "#" ) printf("#%s\n", $0); else print $0 }' ${filename} \
    > "${tmpfile}"
    mv ${tmpfile} ${filename}
  fi

  hosts_merge
  msg_check "$1: ${green}enabled${reset}"
}

_hosts_disable() {
  root_check

  local filename
  local tmpfile=$(mktemp);

  if grep -qw "$1" "${REMOTE_HOSTS}";then
    filename="${REMOTE_HOSTS}"
  elif grep -qw "$1" "${USER_HOSTS}";then
    filename=${USER_HOSTS}
  elif grep -qw "$1" "${ENABLED_DISABLED_HOSTS}";then
    filename=${ENABLED_DISABLED_HOSTS}
  fi

  if [ -z ${filename} ];then
    cp ${ENABLED_DISABLED_HOSTS} ${tmpfile} # Copy current version
    echo "${ip} $1" >> ${tmpfile} 
    mv "${tmpfile}" "${ENABLED_DISABLED_HOSTS}" # Update
  else
    awk -vhost=$1 \
    '{ if ( $0 ~ host && substr($0, 1, 1) == "#" ) print substr($0, 2); else print $0 }' ${filename} \
    > "${tmpfile}"
    mv ${tmpfile} ${filename}
  fi

  hosts_merge
  msg_check "$1: ${yellow}disabled${reset}"
}

hosts_enable() {
  local hosts="${@:2}"

  for host in ${hosts};do
    _hosts_enable "$host"
  done
}

hosts_disable() {
  local hosts="${@:2}"

  for host in ${hosts};do
    _hosts_disable "$host"
  done
}

# hosts_list: list enabled or disabled hosts
hosts_list() {
  total=0
  if [ -e $HOSTS ]; then
    if [ "$1" = "enabled" ]; then
      local match_string
      match_string="#$(echo $ip | awk '{print substr($0,0,2)}')"
      local match_color=$green
    elif [ "$1" = "disabled" ]; then
      local match_string
      match_string="$(echo $ip | awk '{print substr($0,0,3)}')"
      local match_color=$red
    fi
    hosts=$(awk -v match_string="$match_string" '{ if ( substr($0, 1, 3) == match_string ) printf("%s\n", $2) }' $HOSTS)

    for host in $hosts;do
      printf "$match_color\u25CF${reset} ${white}${host}${reset}\n"
      total=$((total + 1))
    done
  fi
  msg_check "${white}total: ${yellow}${total}${reset}"
}

# fetch_updates: update the remote hosts file
fetch_updates() {
  root_check
  
  local centries=0;
  local nentries=0;

  if [ ! -z $remote_hosts ]; then
      if [ -f ${REMOTE_HOSTS} ];then
	centries=$(wc -l ${REMOTE_HOSTS} | cut -d' ' -f1)
      fi
      curl -o "${REMOTE_HOSTS}" -L "${remote_hosts}" -s
      # Diff against the current $REMOTE_HOSTS
      nentries=$(wc -l ${REMOTE_HOSTS} | cut -d' ' -f1)

      msg_check "update: ${purple}$[nentries - centries]${reset} new entries"
  else
      msg_error "no remote hosts URL defined"
      exit 1
  fi
}

# hosts_update: update the remote hosts and export to $HOSTS
hosts_update() {
  root_check

  init
  fetch_updates
  hosts_merge
}

# hosts_restore: restore original /etc/hosts temporary.
hosts_restore() {
  root_check

  cp ${USER_HOSTS} /etc/hosts
  msg_check "${HOSTS} has been restored."
  msg_info  "run ${yellow}\'hostsctl merge\'${reset} to undo."
}

# init: initialize required filed
init() {
  if [ ! -d $HOSTSCTL_DIR ]; then
    mkdir $HOSTSCTL_DIR
  fi
  
  if [ ! -e $USER_HOSTS ]; then
    cp $HOSTS $USER_HOSTS
  fi
    
  if [ ! -e $REMOTE_HOSTS ]; then
    touch $REMOTE_HOSTS
  fi
    
  if [ ! -e $ENABLED_DISABLED_HOSTS ]; then
    touch $ENABLED_DISABLED_HOSTS
  fi
}

case $1 in
  disable)
    hosts_disable "$@";;
  enable)
    hosts_enable  "$@";;
  merge)
    hosts_merge;;
  export)
    hosts_export;;
  update)
    hosts_update;;
  fetch-updates)
    fetch_updates;;
  list-enabled)
    hosts_list "enabled";;
  list-disabled)
    hosts_list "disabled";;
  restore)
    hosts_restore;;
  --help)
    hosts_usage;;
  *)
    hosts_usage;;
esac

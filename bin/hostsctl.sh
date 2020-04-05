#!/usr/bin/env bash
# Copyright (c) 2017 hostsctl.sh authors and contributors
# (https://github.com/pigmonkey/hostsctl/)
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

# Reset tty colors if running in a tty.
maybe_reset_tty_colors() {
  local mytty
  # The `tty` command returns an error if not running in a tty.
  mytty="$(tty)" || return
  tput sgr0 > "${mytty}"
}

# by https://github.com/mathiasbynens/dotfiles
if tput setaf 1 &> /dev/null; then
  maybe_reset_tty_colors
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
HOSTSCTL_DIR="${PREFIX}/hostsctl"
REMOTE_HOSTS="${HOSTSCTL_DIR}/remote.hosts"
ENABLED_HOSTS="${HOSTSCTL_DIR}/enabled.hosts"
DISABLED_HOSTS="${HOSTSCTL_DIR}/disabled.hosts"
USER_HOSTS="${HOSTSCTL_DIR}/orig.hosts"
CONFIG_FILE="${HOSTSCTL_DIR}/hostsctl.conf"

# Define default configuration.
remote_hosts='https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
ip='0.0.0.0'

# Overwrite the defaults with a config file, if it exists.
if [ -e $CONFIG_FILE ]; then
  . $CONFIG_FILE
fi

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

hosts_usage() {
cat << END
Usage $0 [option] [host] ...
 
hostsctl allows you to block advertisements, trackers, and other malicious
activity by manipulating /etc/hosts

Arguments:
  disable [host]   disable specified host
  enable [host]    enable specified host
  export           export hosts to stdout
  fetch-updates    update remote hosts without applying
  list-disabled    list disabled hosts
  list-enabled     list enabled hosts
  merge            merge hosts to ${HOSTS}
  restore          restore ${HOSTS} from ${USER_HOSTS}
  update           update remote hosts and apply to ${HOSTS}
END
}

# hosts_export: export /etc/hostsctl.d/ to stdout.
hosts_export() {
  local grep_args=(-v -e '^#' -e '^$')
  # Exclude all enabled hosts from the output.
  IFS=$'\n' read -d '' -r -a enabled < "${ENABLED_HOSTS}"
  for i in "${enabled[@]}"; do
      grep_args+=(-e " ${i}")
  done;
  # Exclude all disabled hosts from the output to prevent duplicates.
  IFS=$'\n' read -d '' -r -a disabled < "${DISABLED_HOSTS}"
  for i in "${disabled[@]}"; do
      grep_args+=(-e "^${i}$")
  done;
  remote="$(grep "${grep_args[@]}" "${REMOTE_HOSTS}")"
  # Concatenate the users hosts file, disabled hosts, and the remote hosts
  # stripped of any enabled hosts.
  hosts="$(cat "${USER_HOSTS}" "${DISABLED_HOSTS}")"
  echo "${hosts}"$'\n'"${remote}"
}

# hosts_merge: this will merge /etc/hostsctl.d/ to /etc/hosts
hosts_merge() {
  root_check
  hosts_init
  hosts_export > ${HOSTS}
}

_hosts_enable() {
  root_check
  hosts_init
  local message="enabled"
  # Remove the host from the disabled hosts file.
  if grep -q "^$ip $1$" "${DISABLED_HOSTS}"; then
      sed -i "/^$ip $1$/d" "${DISABLED_HOSTS}"
  fi
  # If the host is already in the enabled hosts file, inform the user.
  # Otherwise enable it.
  if grep -q "$1" "${ENABLED_HOSTS}"; then
      message="already $message"
  else
      echo "$1" >> "${ENABLED_HOSTS}"
  fi

  hosts_merge
  msg_check "$1: ${green}${message}${reset}"
}

_hosts_disable() {
  root_check
  hosts_init
  local message="disabled"
  # Remove the host from the enabled hosts file.
  if grep -q "^$1$" "${ENABLED_HOSTS}"; then
      sed -i "/^$1$/d" "${ENABLED_HOSTS}"
  fi
  # If the host is already in the disabled hosts file, inform the user.
  # Otherwise disable it.
  if grep -q "$ip $1" "${DISABLED_HOSTS}"; then
      message="already $message"
  else
      echo "$ip $1" >> "${DISABLED_HOSTS}"
  fi

  hosts_merge
  msg_check "$1: ${yellow}${message}${reset}"
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
  local match_color=""
  local match_string=""
  local total=0
  # Enabled hosts are defined only in the enabled file, so we can just list
  # those entries.
  if [ "$1" = "enabled" ]; then
    match_color=$green
    hosts=$(grep -v '^#' "${ENABLED_HOSTS}")
  # A complete list of disabled hosts should be built from the compiled hosts
  # file.
  elif [ "$1" = "disabled" ]; then
    match_color=$red
    match_string="$(echo $ip | awk '{print substr($0,1,3)}')"
    hosts=$(awk "{ if ( substr(\$0, 1, 3) == \"$match_string\" ) printf(\"%s\n\", \$2) }" $HOSTS)
  fi
  for host in $hosts;do
    printf "$match_color\u25CF${reset} ${white}${host}${reset}\n"
    total=$((total + 1))
  done
  msg_check "${white}total: ${yellow}${total}${reset}"
}

# hosts_fetch_updates: update the remote hosts file
hosts_fetch_updates() {
  if [ -z $remote_hosts ]; then
    msg_error "no remote hosts URL defined"
    exit 1
  fi

  root_check
  hosts_init
  local tmpfile=$(mktemp)
  local tmpfile0=$(mktemp)
  local n=0;

  curl -o "${tmpfile}" -L "${remote_hosts}" -s

  # Only allow entries in the new remote file which begin with the blocking IP
  # address.
  match_string="$(echo $ip | awk '{print substr($0,1,3)}')"
  hosts=$(awk "{ if ( substr(\$0, 1, 3) == \"$match_string\" ) print \$0 >> \"${tmpfile0}\" }" "${tmpfile}")

  # If a previous remote hosts files exists, count the number of different
  # lines between the old and new files.
  if [ -f ${REMOTE_HOSTS} ]; then
    n=$(diff -U 0 "${REMOTE_HOSTS}" "${tmpfile0}" | grep -v ^@ | tail -n +3 | wc -l)
  else
    n=$(wc -l "${tmpfile0}" | cut -d' ' -f1)
  fi

  mv "${tmpfile0}" "${REMOTE_HOSTS}"
  msg_check "update: ${purple}$n${reset} modified entries"
}

# hosts_update: update the remote hosts and export to $HOSTS
hosts_update() {
  root_check
  hosts_init
  hosts_fetch_updates
  hosts_merge
}

# hosts_restore: remove remote and explicitly disabled hosts from /etc/hosts
hosts_restore() {
  root_check

  grep --fixed-strings --line-regexp --invert-match \
      -f ${REMOTE_HOSTS} \
      -f ${DISABLED_HOSTS} \
      ${HOSTS} > ${USER_HOSTS}

  cp ${USER_HOSTS} ${HOSTS}
  msg_check "${HOSTS} has been restored."
  msg_info  "run ${yellow}\'hostsctl merge\'${reset} to undo."
}

# hosts_clean: remove temporary files created by hostsctl.
hosts_clean() {
  rm -f /tmp/hostsctl-*
}

# hosts_init: initialize required files.
hosts_init() {
  if [ ! -d ${HOSTSCTL_DIR} ]; then
    mkdir ${HOSTSCTL_DIR}
  fi
  
  if [ ! -e ${USER_HOSTS} ]; then
    cp ${HOSTS} ${USER_HOSTS}
  fi
    
  if [ ! -e ${REMOTE_HOSTS} ]; then
    touch ${REMOTE_HOSTS}
  fi
    
  if [ ! -e ${ENABLED_HOSTS} ]; then
    touch ${ENABLED_HOSTS}
  fi
  if [ ! -e ${DISABLED_HOSTS} ]; then
    touch ${DISABLED_HOSTS}
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
    hosts_fetch_updates;;
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

# Clean temporary files created by hostsctl.
hosts_clean

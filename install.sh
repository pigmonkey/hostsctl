# 
# Copyright (c) 2017 Levi Sabah <0xl3vi@gmail.com>
# (https://git.io/hostsctl)
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
#

PREFIX="/usr"

root_check() {
  if [ $UID -ne 0 ];then
    echo "error: please run as root."
    exit
  fi
}

msg_info() {
  printf "<i> $1\n"
}

hostsctl_install() {
  local prefix="$1"

  printf "\n=> progress: \n\n"
  # Install files
  cp -av etc/* "/etc/"  
  cp -v bin/hostsctl.sh "${prefix}/bin/hostsctl"
  chmod +x "${prefix}/bin/hostsctl"

  # Install bash-completions
  # TODO: zsh-completions
  # ARCHLINUX
  if [ -f "/etc/arch-release" ];then
    cp -v hostsctl.bash-completion "${prefix}/share/bash-completion/completions"
  fi

  # Copy your original /etc/hosts to /etc/hostsctl.d/10-hosts
  cp -v "/etc/hosts" "/etc/hostsctl.d/10-hosts"
  
  printf "\n"
  # Update /etc/hostsctl.d/30-remote
  sudo hostsctl fetch-updates
  sudo hostsctl merge # Merge hosts
   
  printf "\ncongrats! hostsctl.sh installed on your system.\n\n"
  echo "1. cd /etc/hostsctl.d/ : to manage your hosts"
  echo "2. Full documentation at: <http://git.io/hostsctl>"
}

usage() {
cat << EOF
Usage: $0 [--prefix] ...

Install.sh will install hostsctl on your system.

Arguments:
  --prefix  set installation prefix (default: ${PREFIX})

Full documentation at: <http://git.io/hostsctl>
EOF
}

case $1 in
  --prefix)
    PREFIX="$2";;
  *)
    ;;
esac

# Installation starts here
root_check
hostsctl_install "${PREFIX}"

# 
# Copyright (c) 2017 hostsctl.sh authors and contributors
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

PREFIX="/usr/local"

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

  printf "* Installing hostsctl ...\n"
  # Install files
  #cp -av etc/* "/etc/"  # Do NOT ship to default hostsctl.conf file.

  printf "* " && cp -v bin/hostsctl.sh "${prefix}/bin/hostsctl"
  chmod +x "${prefix}/bin/hostsctl"

  # Install bash-completions
  # TODO: zsh-completions
  # ARCHLINUX
  if [ -f "/etc/arch-release" ];then
    printf "* " && cp -v hostsctl.bash-completion "/usr/share/bash-completion/completions/hostsctl"
  fi

  sudo hostsctl update # Merge hosts
   
  printf "\n* congrats! hostsctl.sh installed on your system.\n\n"
  echo "1. cd /etc/hostsctl.d/ : to manage your hosts"
  echo "2. Full documentation at: <http://git.io/hostsctl>"
}

hosts_uninstall() {
  local prefix="$1"

  printf "* Restoring old /etc/hosts file ...\n"
  "${prefix}"/bin/hostsctl restore
  printf "* Uninstalling hostsctl ...\n"
  rm "${prefix}/bin/hostsctl"
  rm -r /etc/hostsctl*

  if [ -f "/etc/arch-release" ];then
    rm "/usr/share/bash-completion/completions/hostsctl.bash-completion"
  fi
  printf "* hostsctl is no longer installed on your system.\n"
}

usage() {
cat << EOF
Usage: $0 [--prefix] ...

Install.sh will install hostsctl on your system.

Arguments:
  --prefix   set installation prefix (default: ${PREFIX})
  uninstall  uninstall hostsctl.
EOF
}

root_check 

case $1 in
  --prefix)
    PREFIX="$2";;
  uninstall)
    hosts_uninstall "${PREFIX}";;
  *)
    hostsctl_install "${PREFIX}"
esac

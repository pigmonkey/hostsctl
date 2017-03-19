# hostsctl

Hostsctl.sh allows you to control your /etc/hosts easily. you can block ads, porn, soical networks with one command.

[![screenshot](https://raw.githubusercontent.com/wiki/0xl3vi/hostsctl/cast.gif)](cast)


# Installation

To install it right away, type: 

  sudo curl -L https://git.io/vy5xx -o /usr/local/bin/hostsctl
  chmod +x /usr/local/bin/hostsctl

or download hostsctl.sh and run it.

# Usage

1. Before you can start using `hostsctl` you need to select hosts file.

## List of of hosts files

Hosts file | by 
-----------|:------:
[link](https://github.com/StevenBlack/hosts/blob/master/readme.md#list-of-all-hosts-file-variants) | StevenBlack/hosts
[link](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | AdAway
[link](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | add.2o7Net
[link](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts) | add.Spam
[link](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/SpotifyAds/hosts) | SpotifyAds
[link](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts) | UncheckyAds


2. Place the hosts file url in the `URL` variable in `hostsctl.sh`

and run `hostsctl update` to download the hosts file.

Also see `--help`


# Thanks

* Steven Black [hosts](https://github.com/StevenBlack/hosts) repo for inspiring me to create this.


# License

[![gplv3](https://www.gnu.org/graphics/gplv3-127x51.png)](gplv3)

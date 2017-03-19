# :no_entry_sign: hostsctl

Hostsctl.sh allows you to control your /etc/hosts easily. you can block ads, porn, social networks with one command.

[![screenshot](https://raw.githubusercontent.com/wiki/0xl3vi/hostsctl/cast.gif)](cast)


# Installation

To install it right away, type: 

```{bash}
  sudo curl -L https://git.io/vy5xx -o /usr/local/bin/hostsctl
  sudo chmod +x /usr/local/bin/hostsctl
```

or download hostsctl.sh and run it.

# Usage

#### run:

```{bash}
  sudo hostsctl update
```

#### after the installation to update the hosts file.

*. Before you can start using `hostsctl` you need to select hosts file.

## List of of hosts files

file   | by 
-------|:------:
[hosts](https://github.com/StevenBlack/hosts/blob/master/readme.md#list-of-all-hosts-file-variants) | StevenBlack/hosts
[hosts](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | AdAway
[hosts](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | add.2o7Net
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts) | add.Spam
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/SpotifyAds/hosts) | SpotifyAds
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts) | UncheckyAds


* Place the hosts file url in the `URL` variable in `hostsctl.sh`

and run `hostsctl update` to download the hosts file.

### Examples

```{bash}
  sudo hostsctl enable  bigsite.tld # Now you have access to this site
  sudo hostsctl disable bigsite.tld # Now the site pointed to 127.0.0.1
```

See also `--help`

# Contributing

Any collaboration is welcome!

# Thanks

* Steven Black [hosts](https://github.com/StevenBlack/hosts) repo for inspiring me to create this.


# License

[![gplv3](https://www.gnu.org/graphics/gplv3-127x51.png)](gplv3)

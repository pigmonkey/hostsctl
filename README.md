# :no_entry_sign: hostsctl

hostsctl allows you to block advertisements, trackers, and other malicious activity by manipulating `/etc/hosts`. By taking advantage of curated lists of known bad hosts and providing an interface to easily manipulate host definitions, you can save bandwidth and stay safer online.


## How it Works

hostsctl gains flexibility by storing host definitions in different files in the `/etc/hostsctl` directory. When hostsctl is first run, it will create this directory and initiate the needed files. If `/etc/hosts` exists, it will be copied to `/etc/hostsctl/orig.hosts`, ensuring that no existing definitions are lost.

A file containing the list of hosts to be blocked, defined in the configuration, is downloaded and stored at `/etc/hostsctl/remote.hosts`. Hosts that are explicitly blocked or unblocked via hostctl are stored at `/etc/hostsctl/disabled.hosts` and `/etc/hostsctl/enabled.hosts`, respectively. hostsctl operates by merging these separate files together into `/etc/hosts`.

*Note* that after using hostsctl, the `/etc/hosts` file should not be edited directly. Any manual changes will be lost on the next run. Instead, edit the appropriate file in the `/etc/hostsctl` directory.


## Installation

Installation can be performed by executing the provided `install.sh` script as root, or by copying `bin/hostctl.sh` to your path.

```bash
$ sudo ./install.sh
```

#### Packages

* Archlinux [hostsctl](https://aur.archlinux.org/packages/hostsctl/) package.

### Bash-completions

Bash completions are automatically installed by the `install.sh` script on Arch Linux systems. On other systems, copy the provided `hostsctl.bash-completion` file to the appropriate directory.


## Configuration

hostsctl is configured via `/etc/hostsctl/hostsctl.conf`. An example configuration is included, and automatically installed by the `install.sh` script.

### `remote_hosts`

This variable defines the source of the blocking hosts file. See below for example URLs.

```bash
# Block adware and malware via StevenBlack's host file
remote_hosts='https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
```

### `ip`

This variable defines the IP address that blocked hosts should point at. The default value of `0.0.0.0` is recommended. For a discussion concerning this vs `127.0.0.1` see [StevenBlack's host project](https://github.com/StevenBlack/hosts/blob/master/readme.md#we-recommend-using-0000-instead-of-127001).

```bash
# Route blocked hosts to 0.0.0.0
ip='0.0.0.0'
```


## Usage

The simplest usage is to run `hostsctl update`. This will download the latest version of the remote hosts file, merge it together with other entries in `/etc/hostsctl` and output the results to `/etc/hosts`.

```bash
$ sudo hostsctl update
```

### Enabling and Disabling Hosts

hostsctl supports enabling hosts that would otherwise be blocked by the remote hosts file. Note that when a host is accessible, it is considered to be enabled.

```bash
$ sudo hostsctl enable facebook.com # facebook.com will now resolve correctly
```

If an unwanted host is not already blocked by the specified remote hosts file, hostctl can also disable it for you.

```bash
$ sudo hostsctl disable facebook.com # facebook.com now resolves to 0.0.0.0
```

To see which hosts are disabled, or to see a list of explicitly enabled hosts, run the appropriate command.

```bash
$ hostsctl list-enabled
$ hostsctl list-disabled
```

### Advanced Usage

hostsctl is also able to update the remote hosts file and combine the various host definitions in `/etc/hostsctl` as separate steps. This may be useful if you wish to view what has changed in the latest version of your remote hosts file before applying those changes.

```bash
# Update the remote hosts file
$ sudo hostsctl fetch-updates
# Export the all entries to stdout and compare them against the current /etc/hosts
$ hostsctl export | diff -y --suppress-common-lines /etc/hosts - | less
# After confirming the changes, save them to /etc/hosts
$ sudo hostsctl merge
```

Similarly, this behaviour allows the host definitions to easily be stored elsewhere.

```bash
$ sudo hostsctl fetch-updates && hostsctl export > ~/myhosts
```


## Example Hosts Files

file   | by 
-------|:------:
[hosts](https://github.com/StevenBlack/hosts/blob/master/readme.md#list-of-all-hosts-file-variants) | StevenBlack/hosts
[hosts](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | AdAway
[hosts](https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt) | add.2o7Net
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts) | add.Spam
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/SpotifyAds/hosts) | SpotifyAds
[hosts](https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts) | UncheckyAds


## Troubleshooting

First try to `restore` the /etc/hosts file.

```bash
$ sudo hostsctl restore
```

If the problem persist please open new [issue](https://github.com/pigmonkey/hostsctl/issues) on Github.

## Original

The original version of this script is available in the [original branch](https://github.com/pigmonkey/hostsctl/tree/original).


## Contributing

Any collaboration is welcome!


## Thanks

* Steven Black [hosts](https://github.com/StevenBlack/hosts) repo for inspiring me to create this.
* Ty-Lucas Kelley [github-templates](https://github.com/tylucaskelley/github-templates)

## License

[![gplv3](https://www.gnu.org/graphics/gplv3-127x51.png)](gplv3)

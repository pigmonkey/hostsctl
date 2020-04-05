# Change Log


## Unreleased

### Changed

- Attempt to persist manual changes that are made to `/etc/hosts` when restoring.
- Various bash improvements.

### Fixed

- Use a 1-based `substr` index to support older versions of mawk.
- Do not reset terminal colors when redirecting output.


## [ 0.1.2 ] - 2018-04-03

### Fixed
- Avoid returning non-zero exit code when cleaning temporary files.


## [ 0.1.1 ] - 2017-06-25

### Changed
- Added compatibility with BSD awk.
- When updating, report on modified entries, not new entries.

### Fixed
- macOS compatibility


## [ 0.1.0 ] - 2017-05-29

### Changed
- Changed default remote hosts file to be more permissive.
- Moved all hostsctl files to the `/etc/hostsctl` directory. To upgrade, existing users should perform the following steps as root prior to executing hostsctl:
```
# mkdir /etc/hostsctl
# mv /etc/hostsctl.conf /etc/hostsctl/
# mv /etc/hostsctl.d/10-hosts /etc/hostsctl/orig.hosts
# grep -v '^#' /etc/hostsctl.d/20-enabled-disabled > /etc/hostsctl/disabled.hosts
# grep '^#' /etc/hostsctl.d/20-enabled-disabled | cut -d' ' -f2 > /etc/hostsctl/enabled.hosts
# rm -r /etc/hostsctl.d
```

### Fixed
- Prevent duplicates when merging host files.

[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![GitHub Issues](https://img.shields.io/github/issues/lhqg/action-os-debbuild-selinux)](https://github.com/lhqg/action-os-debbuild-selinux/issues)
[![GitHub PR](https://img.shields.io/github/issues-pr/lhqg/action-os-debbuild-selinux)](https://github.com/lhqg/action-os-debbuild-selinux/pulls)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/lhqg/action-os-debbuild-selinux)](https://github.com/lhqg/selinux_cassandra/commits/main)
[![GitHub Last commit](https://img.shields.io/github/last-commit/lhqg/action-os-debbuild-selinux)](https://github.com/lhqg/action-os-debbuild-selinux/commits/main)
![GitHub Downloads](https://img.shields.io/github/downloads/lhqg/action-os-debbuild-selinux/total)

Action repository for LHQG to build SELinux DEB packages on targeted OS
=======================================================================
https://github.com/lhqg/action-os-debbuild-selinux

## Introduction

This repository aims to build on a specified OS, DEB pkgs for an SELinux policy module and
to sign them with a GPG key.

## How to use this repository

Main branch is used to manage changes that are applicable to all the other branches.
Specific branches are created for each OS we want the DEBs to be built for.
User must checkout each OS branch in is workflow in order to build the DEBs.

### Inputs

All the following inputs are required:

#### distro_name                    (default: `ubuntu`)
    Name of the GNU/Linux distribution, i.e. `ubuntu` or `debian`.

####  distro_vers                   (no default)
    Code name or release for the distribution, e.g. `noble` or `24.04`.

####  source_repo_location          (default: `SOURCE_REPO`)
    Provides the directory where the source repository was checked out.

####  build_material_dir            (default: `dpkg`)
    Provides the relative path (in the source repository) where the
    Makefile and the control, changelog and copyright files are located.

####  package_version              (no default)
    DEB package full version.

####  gpg_name                      (no default)
    GPG pretty name of the key

####  gpg_private_key_file          (no default)
    GPG key file

## Disclaimer

The code of this repository is provided AS-IS. People and organisation
willing to use it must be fully aware that they are doing so at their own risks and
expenses.

The Author(s) of this repository module SHALL NOT be held liable nor accountable, in
any way, of any malfunction or limitation of said module, nor of the resulting damage, of
any kind, resulting, directly or indirectly, of the usage of this repository.

It is strongly advised to always use the last version of the code.

Finally, users should check regularly for updates.

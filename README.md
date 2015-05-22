OpenVAS Compilation for Ubuntu 14.04
===================

The OpenVAS packages for Ubuntu 14.04 are terribly out-of-date. Version 8 is stable but it only contains version 2 from years ago. Greenbone Security Advisor is even missing.

This repo contains script to be able to compile OpenVAS and automatically generate Debian packages with appropriate dependencies.

**Please note this is still a *Work In Progress*. Generated packages may or may not work. YMMV & contributions are welcome!**

Requirements
-------------

 1. Ubuntu 14.04 (tested on amd64)
 2. Diskspace to build
 2. A clone of this repo (obviously)
 3. A fairly clean system to build from (Vagrant recommended)
 4. A lot of dependencies which will be installed by the `prepare.sh` script

Usage
-------------

 1. Copy `vars.sh.dist` to `vars.sh` (`cp vars.sh.dist vars.sh`)
 2. Fill in the variables in `vars.sh`
 3. Prepare the system for building: `./prepare.sh`
 4. Compile all packages: `./compile.sh`

The `packages` folder will contain all the DEB files required to install OpenVAS and its packages. The nicest way is to add it to your own APT Mirror.

If you'd like to set one up I can highly recommend [Freight](https://github.com/rcrowley/freight) to setup and manage your own repo.

Good luck!

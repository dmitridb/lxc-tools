# lxc-tools

Dead simple scripts for creating and destroying LXC containers on 
(so far only) debian-based distros

adapted from https://github.com/mocig/server-tools

updated to run on debian and popos

written in perl and bash

Ubuntu is leaning full in on pre-installed LXD, which is cool until it
tries too hard to be like docker with a full-on bloat daemon running a REST API
and all this extra stuff not needed in 90% of use cases for containerization.
lxc-tools offers a dead-simple solution for firing up containers based on LXC 
and LXC only, no frills or gimmicks necessary. These scripts also go through
the steps necessary to remove systemd on the containers.

This is still a work in progress...

## TO-DO:
Getting it to work on distros that aren't popos and debian, with out of
the box support for non-debian/ubuntu containers as well

The scripts in /extra need an update, they haven't been fully tested since
this was originally written for debian stretch

setup-lxc.sh
```
Usage: ./setup-lxc.sh <lxc-network>
	
Installs lxc and dnsmasq, configures bridge interface, network, nat
and places commands new-container and destroy-container in 
/usr/local/sbin

Asumes root, and a clean system (f.e. it will overwrite /etc/dnsmasq.conf)
```

new-container
```
Usage: new-container <distro> <release> <containername>

Sets up a new container given the distro, release, and name of container
```

destroy-container
```
destroy-container <containername>

Stops and removes a container.
```

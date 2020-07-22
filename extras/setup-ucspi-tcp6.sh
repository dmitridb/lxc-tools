#!/bin/bash -e
if [ `whoami` != "root" ]; then
        echo "This script must be run as root"
        exit 1
fi
apt-get install -qq gcc make libc-dev
cd ucspi-tcp6
/bin/tar xfz ucspi-tcp6-1.05.tgz
chown -R root.root host
cd host/ucspi-tcp6-1.05/
package/install
cp -a --remove-destination command/* /usr/local/bin
cd ../../


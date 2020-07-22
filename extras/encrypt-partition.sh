#!/bin/bash
if [ $# != "3" ]; then
	echo "Usage: $0: <dev> <mountpoint> <name>"
	exit 1
fi
if [ `whoami` != "root" ]; then
	echo "This script must be run as root"
	exit 1
fi
if [ ! -e $1 ]; then
	echo "Device $1 not found."
	exit 1
fi
if grep -qs "$1" /proc/mounts; then
	echo "$1 is mounted."
	exit 1
fi
if grep -qs "$2" /proc/mounts; then
	echo "$2 is mounted"
	exit 1
fi
if [ -e /dev/mapper/$3 ]; then
	echo "mapper device $3 already exists"
	exit 1
fi
apt-get update -qq
apt-get install -y -qq cryptsetup pv
mkdir -p $2
cryptsetup -y -v luksFormat $1
cryptsetup luksOpen $1 $3
pv -tpreb /dev/zero | dd of=/dev/mapper/$3 bs=128M
mkfs.ext4 /dev/mapper/$3
mount /dev/mapper/$3 $2
df -H
cat <<EOF > ~/mount-$3.sh
#!/bin/bash -e
cryptsetup luksOpen $1 $3
mount /dev/mapper/$3 $2
EOF
chmod 755 ~/mount-$3.sh

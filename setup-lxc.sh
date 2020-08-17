#!/bin/bash -e
if [ $# != 1 ]; then
	echo "Usage: $0 lxc-network"
	exit 1
fi
if [ `whoami` != "root" ]; then
    echo "This script must be run as root"
    exit 1
fi
source tools.sh
if ! valid_ip $1; then 
	echo "$1 is not a valid ip"
	exit 1
fi
IFS='.' read -a NETWORK <<< "$1"
if [ "${NETWORK[3]}" != "0" ]; then
	echo "lxc-network needs to end with .0"
	exit 1
fi
# debian without sudo pre-installed doesn't source /etc/profile as hoped
# when you just su into root, therefore this is in here to make sure of it
if [ "$(id -u)" -eq 0 ]; then
    source /etc/profile
fi

DEFIF=`ip route show |grep default|cut -d " " -f 5`
echo "USING $DEFIF as outgoing"
echo "Installing packages"
apt-get update -qq
apt-get install -y -qq net-tools lxc bridge-utils debootstrap iptables-persistent dnsmasq lxc-templates
LXCNET="${NETWORK[0]}.${NETWORK[1]}.${NETWORK[2]}"
echo "Adding bridge to interfaces"
cat << EOF >> /etc/network/interfaces

# nat bridge for lxc
auto lxc-bridge-nat
iface lxc-bridge-nat inet static
        bridge_ports none
        bridge_fd 0
        bridge_maxwait 0
        address ${NETWORK[0]}.${NETWORK[1]}.${NETWORK[2]}.1
        netmask 255.255.255.0
        up iptables -t nat -A POSTROUTING -o $DEFIF -s $1/24 -j MASQUERADE
EOF
ifup lxc-bridge-nat
echo "Installing /usr/local/sbin/new-container"
cat setup-lxc/new-container | sed "s/NETWORK/${NETWORK[0]}\.${NETWORK[1]}\.${NETWORK[2]}/" > /usr/local/sbin/new-container
chmod 755 /usr/local/sbin/new-container
echo "Installing /usr/local/sbin/destroy-container"
cp setup-lxc/destroy-container /usr/local/sbin
chmod 755 /usr/local/sbin/destroy-container
echo "Installing /usr/local/sbin/infoall-container"
cp setup-lxc/infoall-container /usr/local/sbin
chmod 755 /usr/local/sbin/infoall-container
#chmod 755 /usr/local/sbin/new-pihole
echo "Enabling ip-forwarding"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "Use new-container command to setup a new container"
if [ -f /etc/dnsmasq.conf ]; then
  cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi
cat << EOF > /etc/dnsmasq.conf
interface=lxc-bridge-nat
no-dhcp-interface=lxc-bridge-nat
bind-interfaces
EOF
# TODO: Add determination whether host machine is your laptop on systemd or server on sysvinit
# /etc/init.d/dnsmasq restart
service dnsmasq restart
echo "dnsmasq installed, script complete"

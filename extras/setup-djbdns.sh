#!/bin/bash -e
if [ `whoami` != "root" ]; then
        echo "This script must be run as root"
        exit 1
fi
apt-get install -qq gcc make libc-dev daemontools daemontools-run libcrypt-openssl-rsa-perl
echo Building djbdns...
cd djbdns
tar xfz dnssec-1.05-test27-8ubuntu1-tinydnssec_1.3.tar.gz
cd tinydnssec-dnssec-1.05-test27-8ubuntu1-tinydnssec_1.3
make setup check
cp -a tinydns-sign.pl /usr/local/sbin/tinydns-sign
cd ../../
echo Adding Users
/usr/sbin/useradd -s /bin/false tinydns
/usr/sbin/useradd -s /bin/false dnslog
DEFIF=`ip route show |grep default|cut -d " " -f 5`
MYIP=`ip addr show dev $DEFIF |grep -m 1 ' inet ' |cut -d " " -f 6|sed 's/\/.*//'`
read -p "Setup new tinydns for ip $MYIP? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo All done
    exit 1
fi
echo Setting up new tinydns in /var/tinydns for IP $MYIP
tinydns-conf tinydns dnslog /var/tinydns $MYIP
ln -s /var/tinydns /etc/service
sleep 2
svstat /etc/service/tinydns

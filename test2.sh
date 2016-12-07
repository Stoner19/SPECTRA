####!/bin/bash
echo "########### The server will reboot when the script is complete..."
echo "########### Changing to home dir..."
cd ~
#
####Update Server####
echo "########### Updating Ubuntu..."
apt-get update --force-yes -y
apt-get upgrade --force-yes -y
apt-get install software-properties-common python-software-properties autotools-dev autoconf --force-yes -y
apt-get install build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev git libssl1.0.0-dbg libtool --force-yes -y
apt-get install libdb-dev libdb++-dev libboost-all-dev libminiupnpc-dev libminiupnpc8 libevent-dev libcrypto++-dev libgmp3-dev --force-yes -y
#
####Install Firewall####
echo "########### Firewall rules; allow 22,15150"
apt-get install ufw --force-yes -y
ufw allow 80/tcp
ufw allow 22/tcp
ufw allow 15150/tcp
ufw allow 15151/tcp
ufw --force enable
#
####Create Swap File####
echo "########### Creating Swap..."
dd if=/dev/zero of=/swapfile bs=1M count=512
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
#
####Clone TAO Github - Build levedb####
echo "########### Adding ppa:taoblockchain/tao-core and building leveldb"
mkdir ~/.Tao/
apt-get install git --force-yes -y
git clone https://github.com/taoblockchain/tao-core
cd tao-core/src/leveldb
chmod 755 build_detect_platform
make libleveldb.a libmemenv.a
#
####secp256k1 - Install secp256k1####
cd ../secp256k1
./autogen.sh
./configure
make
make install
git clean -dfx
#
####Clone TAO Github - Build taod####
cd ..
make -f makefile.unix
strip taod
mv taod /usr/bin/
#
####Create tao.conf####
echo "########### Creating config..."
cd ~
config=".Tao/tao.conf"
touch $config
echo "txindex=1" > $config
echo "listen=1" >> $config
echo "server=1" >> $config
echo "daemon=1" >> $config
echo "port=15150" >> $config
echo "rpcport=15151" >> $config
echo "maxconnections=256" >> $config
randUser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
randPass=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
echo "rpcuser=$randUser" >> $config
echo "rpcpassword=$randPass" >> $config
#
####Autostart taod Upon Server Start####
echo "########### Setting up autostart (cron)"
crontab -l > tempcron
echo "@reboot taod" >> tempcron
crontab tempcron
rm tempcron
echo "########### Thanks to Max Kaye."
echo "########### Modified by SPEC Dev Team dev@speccoin.com"
echo "Rebooting.."
reboot

#!/bin/bash

cd "$(dirname "$0")"
. .env

#Senvr's Super Java Finder Fuck Yourself (SSJFY)
#[ -f "$jrelocation" ] && jrebin=$jrelocation || if ! command -v java &> /dev/null; then echo "Java is not found or installed"; exit; else jrebin=$(which java); fi

echo "Adding cert..."
keytool -keystore ${cacertsfile} -storepass changeit -importcert -file <(echo ""|openssl s_client -connect ${ip}:443 2>/dev/null|openssl x509) -alias ${ip} -noprompt

if [ ! -f "avctKVM.jar" ]; then
	[ -d "./lib" ] && rm -r "./lib"; mkdir lib; cd lib
	echo "avctKVM.jar not found, re-extracting"
	curl -k -O https://${ip}:443/software/avctVMLinux64.jar --output - | java -jar --extract libavmlinux.so
	curl -k -O https://${ip}:443/software/avctKVMIOLinux64.jar --output - | java -jar --extract libavctKVMIO.so
	curl -k -O https://${ip}:443/software/avctKVM.jar --output avctKVM.jar
fi

if [ ! -d "./lib" ]; then

fi

set -e
cd ../
java -cp avctKVM.jar -Djava.library.path=./lib/ com.avocent.idrac.kvm.Main ip=${ip} kmport=${kmport} vport=${vport} apcp=${apcp} version=${version} vmprivilege=${vmprivilege} helpurl=https://${ip}:443/help/contents.html user=${username} passwd=${passwd}  > /dev/null 2>&1 &

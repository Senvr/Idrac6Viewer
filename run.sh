#!/bin/bash

cd "$(dirname "$0")"

. .env

echo ${java_bin}
echo ${keytool_bin}

echo "Adding cert..."
${keytool_bin} -storepass changeit -importcert -file <(echo ""|openssl s_client -connect ${idrac_ip}:443 2>/dev/null|openssl x509) -alias ${idrac_ip} -noprompt

if [ ! -f "./avctKVM.jar" ]; then
	curl -k -O https://${idrac_ip}:443/software/avctKVM.jar --output ./avctKVM.jar
fi

if [ ! -d "./lib" ]; then
	mkdir lib
	cd lib	
fi

if [ ! -f "./lib/avctVMLinux64.jar" ]; then
	curl -k -O https://${idrac_ip}:443/software/avctVMLinux64.jar --output - | ../${java_bin} -jar --extract libavmlinux.so
fi

if [ ! -f "./lib/avctKVMIOLinux64.jar" ]; then
	curl -k -O https://${idrac_ip}:443/software/avctKVMIOLinux64.jar --output - | ../${java_bin} -jar --extract libavctKVMIO.so
fi


echo "Running client..."
cd "$(dirname "$0")"
./${java_bin} \
	-cp avctKVM.jar \
	-Djava.library.path=./lib/ \
	com.avocent.idrac.kvm.Main \
	ip=${idrac_ip} \
	kmport=5900 \
	vport=5900 \
	apcp=1 \
	version=2 \
	vmprivilege=true \
	helpurl=https://${idrac_ip}:443/help/contents.html \
	user=${idrac_username} \
	passwd=${idrac_passwd}

#!/bin/bash

#preq
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root (with sudo or doas)."
	exit 1
fi

if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
	apt install -y build-essentials wget git
fi

# cate
verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

needs_cate_update=0
if ! command -v cate &> /dev/null;then
    needs_cate_update=1
else
	_cate_version=$(cate -v)
	cate_version=${_cate_version:1:4}
	if verlt $cate_version "2.8"; then
		needs_cate_update=1
	fi
fi

if [ $needs_cate_update -eq 1 ]; then
	echo "Installing a newer cate version..."
	mkdir catering
	cd catering
	wget https://github.com/TheMilkies/Cate/releases/download/v2.8/linux_cate_v2.8.0.zip
	unzip linux_cate_v2.8.0.zip
	sudo ./install.sh
	cd ..
	rm -rf catering
	echo "done"
fi

# hpp
sudo cp cpp_kolay.hpp /usr/include/cpp_kolay.hpp

#kolayion
sudo cp kolay.sh /usr/bin/kolay

#!/bin/bash

#preq
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root (with sudo or doas)."
	exit 1
fi

case $(uname -m) in
x86_64)
    ;;
*)
	echo "Kolay is currently not supported for " $(uname -m)
	exit 1
    ;;
esac

error_if_doesnt_have() {
	_exit=0
	for program in "$@"; do
		if ! command -v $program &> /dev/null;then
			echo "Please install \"$program\""
			_exit=1
		fi
	done
	if [ _exit -eq 1 ]; then
		exit 1
	fi
}

if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
	apt -qqq install -y build-essential wget git
else
	echo "Currently only debian-based distros are supported."
fi
error_if_doesnt_have g++ bash wget git 

# cate
verlte() {
    [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
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
	echo "Done installing Cate"
fi

# hpp
cp cpp_kolay.hpp /usr/include/cpp_kolay.hpp
cp kolay_colors.hpp /usr/include/kolay_colors.hpp

#kolayion
cp kolay.sh /usr/bin/kolay
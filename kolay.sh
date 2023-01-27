#!/bin/bash

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

require() {
	for program in "$@"; do
		if ! command -v $program &> /dev/null;then
			echo "\"$program\" is not installed but is required for this operation"
		fi
	done
}

help_() {
	echo 'Kolay tools for C++'
	echo '	self-update: updates kolay'
	echo '	init:		 creates a project with the specified name'
	echo
	echo '	add:'
	echo '	    class:   adds a class   with the specified name'
	echo '	    library: adds a library with the specified name'
}

not_empty() {
	if [ -z "$1" ]; then
		echo "Name can not be empty."
		exit 1
	fi
}

init_project() {
	not_empty $1
	if [ -d "cate" ]; then
		echo "Project already inited."
		exit 1
	fi
	require tee cate mkdir

	mkdir -p src include cate
	echo "def debug" > .catel
	printf "Project $1\n" | tee cate/debug.cate cate/release.cate
	printf ".files = {\"src/**.cpp\"}\n.compiler = \"g++\"\n.std = \"c++17\"\n" | tee -a cate/debug.cate cate/release.cate
	printf ".flags = \"-O2\"\n.incs = {\"include\"}\n" | tee -a cate/debug.cate cate/release.cate
	echo ".defs = {\"DEBUG\"}" >> cate/debug.cate
	printf ".build()\n" | tee -a cate/debug.cate cate/release.cate

	printf "#include <cpp_kolay.hpp>\n\ni32 main(i32 argc, char const* argv[])\n{\n\t\n\treturn 0;\n}" > src/main.cpp
}

add_class() {
	not_empty $1
	if [ ! -d "src" ]; then
		echo "Project was not inited."
		exit 1
	fi
	if [ -f "src/$1.cpp" ] || [ -f "include/$1.hpp" ]; then
		echo "$1 was already added."
		exit 1
	fi
	require cate

	printf "#pragma once\nclass $1\n{\n" > include/$1.hpp
	printf "public:\n\t$1();\n\t~$1();\n};" >> include/$1.hpp
	printf "#include \"$1.hpp\"\n$1::$1()\n{\n\t\n}\n\n" > src/$1.cpp
	printf "$1::~$1()\n{\n\t\n}" >> src/$1.cpp
}

if [ "$#" -lt 1 ]; then
    help_
	exit 1
fi

KOLAY_VERSION=0.01
self_update() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root (with sudo or doas)."
		exit 1
	fi
	require git wget mkdir rm #if you don't have mkdir and rm, how are you here?

	echo "Checking for Kolay updates..."
	latest_version=$(wget -qO- https://raw.githubusercontent.com/TheMilkies/Kolay/main/version.txt)
	if verlt $KOLAY_VERSION $latest_version; then
		echo "Updating to" $latest_version
		mkdir kolay_tmp; cd kolay_tmp
		git clone --quiet https://github.com/TheMilkies/Kolay.git
		if [ $? -ne 0 ] || [ ! -d Kolay ]; then
			echo "Error in getting Kolay from github."
			cd ../; rm -rf kolay_tmp
			exit 1
		fi
		cd Kolay; ./install_preq.sh
		cd ../../
		rm -rf kolay_tmp
	else
		echo "Your Kolay is up to date!"
	fi
}

while [[ $# -gt 0 ]]; do
case $1 in
	self-update)
		shift 
		self_update
		;;
	init)
		shift
		if [ -z $1 ]; then
			echo "Expected a name for the project"; fi
		init_project $1
		shift
		;;
	add)
		shift 
		if [ -z $1 ]; then
			echo "Expected a type (currently only class is supported)"; fi
		case $1 in
		class)
			shift
			add_class $1
			;;
		esac
		shift 
		;;
	-v|version)
		echo $KOLAY_VERSION
		exit
		;;
	*)
		echo "Unknown option $1"
		exit 1
		;;
esac
done
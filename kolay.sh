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
	echo 'Kolay (tools) for C++'
	echo 'kolay <action> [subaction] <name>'
	echo
	echo '  self-update:       updates kolay'
	echo '  init:              creates a project with the specified name'
	echo
	echo '  new:' 
	echo '    class:           creates a class   with the specified name'
	echo '    static-library:  creates a library with the specified name'
	echo '    dynamic-library: same as above']
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
	printf "compiler = \"g++\"\nstd = \"c++17\"\nProject $1\n" | tee cate/debug.cate cate/release.cate > /dev/null 2>&1
	printf ".files = {\"src/*.cpp\"}\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	printf ".flags = \"-O2 -fpermissive\"\n.incs = {\"include\"}\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	echo ".defs = {\"DEBUG\"}" >> cate/debug.cate 
	printf ".build()\n\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1

	printf "#include <cpp_kolay.hpp>\n\ni32 main(i32 argc, char* const* argv)\n{\n\t\n\treturn 0;\n}" > src/main.cpp

	echo Done.
}

init_library() {
	not_empty $1
	if [ -d "src/lib$1" ]; then
		echo "library already inited."
		exit 1
	fi
	require tee cate mkdir

	libname="lib${1,,}"
	mkdir -p src/$libname include/$libname cate
	if [ ! -f .catel ]; then echo "def debug" > .catel; fi

	if [ $2 == "static" ]; then
		type="static"
	elif [ $2 == 'stynamic' ]; then
		type="static"
		stynamic='1'
	else
		type="dynamic"
	fi

	printf "Library $1($type)\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	printf ".files = {\"src/$libname/*.cpp\"}\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	printf ".flags = \"-O2 -fpermissive\"\n.incs = {\"include\"}\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	echo ".defs = {\"DEBUG\"}" >> cate/debug.cate 
	printf ".build()\n\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1

	if [ ! -z $stynamic ]; then
		printf ".type = dynamic\n.build()\n\n" | tee -a cate/debug.cate cate/release.cate > /dev/null 2>&1
	fi

	namespace_name=$1
	start_header	include/$libname/$1.hpp
	start_namespace include/$libname/$1.hpp
	end_namespace   include/$libname/$1.hpp

	printf "#include \"$libname/$1.hpp\"\n\n" > src/$libname/$1.cpp
	start_namespace src/$libname/$1.cpp
	end_namespace   src/$libname/$1.cpp

	reset_namespace
	stynamic=''
	echo Done.
}

add_guard() {
	not_empty $1
	if [ ! -d "src" ]; then
		echo "Project was not inited."
		exit 1
	fi
	if [ -f "src/$1.cpp" ] || [ -f "include/$1.hpp" ]; then
		echo "$1 was already created."
		exit 1
	fi
}

split_namespace() {
	not_empty $1
	if [[ $1 != *"::"* ]]; then return; fi

	#namespace things
	class_name=${1##*\:\:}
	namespace_name=${1%\:\:*}

	#check if it's in library
	temp=${1%%\:\:*}
	temp=${temp,,}

	if [ -d src/lib$temp ] || [ -d include/lib$temp ]; then
		lib_path_name="lib$temp"
	fi
}

start_namespace() {
	if [ ! -z $namespace_name ]; then
		printf "namespace $namespace_name {\n\n" >> $1; fi
}

end_namespace() {
	if [ ! -z $namespace_name ]; then
		printf "\n\n} //namespace $namespace_name" >> $1; fi
}

reset_namespace() {
	lib_path_name=''
	class_name=''
	namespace_name=''
}

start_header() {
	printf "#pragma once\n#include <cpp_kolay.hpp>\n\n" > $1
}

new_class() {
	add_guard $1
	split_namespace $1
	name=$1
	if [ ! -z $class_name ]; then
		name=$class_name
	fi

	start_header include/$lib_path_name/$name.hpp
	start_namespace include/$lib_path_name/$name.hpp
	printf "class $name\n{\n" >> include/$lib_path_name/$name.hpp
	printf "public:\n\t$name();\n\t~$name();\n};" >> include/$lib_path_name/$name.hpp
	end_namespace include/$lib_path_name/$name.hpp

	if [ ! -z $lib_path_name ]; then
		printf "#include \"$lib_path_name/$name.hpp\"\n" > src/$lib_path_name/$name.cpp
	else
		printf "#include \"$name.hpp\"\n" > src/$lib_path_name/$name.cpp
	fi

	start_namespace src/$lib_path_name/$name.cpp
	printf "$name::$name()\n{\n\t\n}\n\n" >> src/$lib_path_name/$name.cpp
	printf "$name::~$name()\n{\n\t\n}" >> src/$lib_path_name/$name.cpp
	end_namespace src/$lib_path_name/$name.cpp
	reset_namespace
}

if [ "$#" -lt 1 ]; then
    help_
	exit 1
fi

KOLAY_VERSION=0.02
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
		cd ../../; rm -rf kolay_tmp
	else
		echo "Your Kolay is up to date!"
	fi
}

while [[ $# -gt 0 ]]; do
case $1 in
	self-update)
		shift
		self_update
		exit
		;;
	init)
		shift
		if [ -z $1 ]; then
			echo "Expected a name for the project"; fi
		init_project $1
		shift

		;;
	new)
		shift 
		if [ -z $1 ]; then
			echo "Expected a type (currently only class is supported)"; fi
		case $1 in
		class)
			shift
			new_class $1
			shift
			;;
		static-library)
			shift
			init_library $1 static
			shift
			;;
		stynamic-library)
			shift
			init_library $1 stynamic
			shift
			;;
		dynamic-library)
			shift
			init_library $1 dynamic
			shift
			;;
		*)
			echo "Unknown option $1"
			exit 1
			;;
		esac
		;;
	-v|version)
		echo $KOLAY_VERSION
		exit
		;;
	-h|-\?|--help|help)
		help_
		exit
		;;
	*)
		echo "Unknown option $1"
		exit 1
		;;
esac
done
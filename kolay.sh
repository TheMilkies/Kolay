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

check_not_init() {
	if [ ! -d "src" ]; then
		echo "Project was not inited."
		exit 1
	fi
}

help_() {
	echo 'Kolay (tools) for C++'
	echo 'kolay <action> [subaction] <name>'
	echo
	echo '  init:              creates a project with the specified name'
	echo '  build:             builds debug'
	echo '  release:           rebuilds completely for release'
	echo '  update:            updates kolay'
	echo
	echo '  new:' 
	echo '    class:           creates a class   with the specified name'
	echo '    static-library:  creates a library with the specified name'
	echo '    dynamic-library: same as above'
	echo '    singleton:       creates a singleton like above'
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
	echo   ".defs = {\"DEBUG\"}" >> cate/debug.cate 
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

	reset_temps
	echo Done.
}

add_guard() {
	not_empty $1
	check_not_init

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

reset_temps() {
	lib_path_name=''
	_path=''
	class_name=''
	namespace_name=''
	stynamic=''
}

start_header() {
	printf "#pragma once\n" >> $1
	if [ ! -z $2 ]; then
		printf "#include <$2>\n" >> $1
	fi
	printf "#include <cpp_kolay.hpp>\n\n" >> $1
}

new_header_with_namespace() {
	add_guard $1
	split_namespace $1
	name=$1
	if [ ! -z $class_name ]; then
		name=$class_name
	fi

	# handle "dir/class"
	name=${1##*\/}
	lib_path_name=${1%\/*}
	if [ $lib_path_name == $1 ]; then
		lib_path_name=''
	fi

	if [ ! -d $lib_path_name ] && [ $lib_path_name != $1 ]; then
		mkdir -p src/$lib_path_name include/$lib_path_name
	fi
	
	start_header include/$lib_path_name/$name.hpp $2
	start_namespace include/$lib_path_name/$name.hpp
}

new_cpp_with_namespace() {
	if [ ! -z $lib_path_name ]; then
		printf "#include \"$lib_path_name/$name.hpp\"\n" > src/$lib_path_name/$name.cpp
	else
		printf "#include \"$name.hpp\"\n" > src/$lib_path_name/$name.cpp
	fi

	start_namespace src/$lib_path_name/$name.cpp
}

new_class() {
	new_header_with_namespace $1

	printf "class $name\n{\n" >> include/$lib_path_name/$name.hpp
	printf "public:\n\t$name();\n\t~$name();\n};" >> include/$lib_path_name/$name.hpp
	end_namespace include/$lib_path_name/$name.hpp

	new_cpp_with_namespace
	printf "$name::$name()\n{\n\t\n}\n\n" >> src/$lib_path_name/$name.cpp
	printf "$name::~$name()\n{\n\t\n}" >> src/$lib_path_name/$name.cpp
	end_namespace src/$lib_path_name/$name.cpp
	reset_temps
}

new_singleton() {
	new_header_with_namespace $1

	printf "class $name\n{\n" >> include/$lib_path_name/$name.hpp
	printf "private:\n\tstatic $name* m_instance;\n" >> include/$lib_path_name/$name.hpp
	printf "protected:\n\t$name();\n\t~$name();\n\t//put your variables here\n" >> include/$lib_path_name/$name.hpp
	printf "\t$name($name &other) = delete;\n\tvoid operator=(const $name &) = delete;\n" >> include/$lib_path_name/$name.hpp
	printf "public:\n\tstatic $name* get_instance();" >> include/$lib_path_name/$name.hpp
	printf "\n};" >> include/$lib_path_name/$name.hpp

	end_namespace include/$lib_path_name/$name.hpp

	new_cpp_with_namespace
	printf "$name* $name::m_instance = NULL;\n$name* $name::get_instance()\n{\n\t" >> src/$lib_path_name/$name.cpp
	printf "if(m_instance == NULL) m_instance = new $name;\n\treturn m_instance;\n}\n\n" >> src/$lib_path_name/$name.cpp
	printf "$name::$name()\n{\n\t\n}\n\n" >> src/$lib_path_name/$name.cpp
	printf "$name::~$name()\n{\n\t\n}" >> src/$lib_path_name/$name.cpp
	end_namespace src/$lib_path_name/$name.cpp
	reset_temps
}

if [ "$#" -lt 1 ]; then
    help_
	exit 1
fi

KOLAY_VERSION=0.031
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
		
		installed_version=$(kolay -v)
		if [ "$installed_version" != "$latest_version" ]; then
			echo "Error in updating Kolay."
			exit 1
		else
			echo "Done. Welcome to Kolay v$installed_version!"
		fi

	else
		echo "Your Kolay is up to date!"
	fi
}

while [[ $# -gt 0 ]]; do
case $1 in
	self-update|update)
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
		singleton)
			shift
			new_singleton $1
			shift
			;;
		static|static-library)
			shift
			init_library $1 static
			shift
			;;
		stynamic|stynamic-library)
			shift
			init_library $1 stynamic
			shift
			;;
		dynamic|dynamic-library)
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
	build)
		check_not_init
		require cate
		cate debug
		;;
	release)
		check_not_init
		require cate
		cate release -f
		;;

esac
done
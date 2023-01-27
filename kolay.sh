#!/bin/bash

help_() {
	echo 'Kolay tools for C++'
	echo '	self-update: updates kolay'
	echo '	init: creates a project with the specified name'
	echo '	add:'
	echo '	    class: adds a class with the specified name'
	#echo '	    class: adds a class with the specified name'
}

init_project() {
	if [ -d "cate" ]; then
		echo "Project already inited."
		exit 1
	fi

	mkdir -p src include cate
	echo "def debug" > .catel
	printf "Project $1\n" | tee cate/debug.cate cate/build.cate
	printf ".files = {\"src/**.cpp\"}\n.compiler = \"g++\"\n.std = \"c++17\"\n" | tee -a cate/debug.cate cate/build.cate
	printf ".flags = \"-O2\"\n.incs = {\"include\"}\n" | tee -a cate/debug.cate cate/build.cate
	echo ".defs = {\"DEBUG\"}" >> cate/debug.cate
	printf ".build()\n" | tee -a cate/debug.cate cate/build.cate

	printf "#include <cpp_kolay.hpp>\n\ni32 main(i32 argc, char const* argv[])\n{\n\t\n\treturn 0;\n}" > src/main.cpp
}

if [ "$#" -lt 1 ]; then
    help_
	exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    self-update)
      shift 
	  echo "unimplemented"
      ;;
    init)
      shift # past argument
	  if [ -z $1 ]; then
	  	echo "Expected a name for the project"; fi
	  init_project $1
      shift # past value
      ;;
	add)
      shift 
	  if [ -z $1 ]; then
	  	echo "Expected a type (currently only class is supported)"; fi
      shift 
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done
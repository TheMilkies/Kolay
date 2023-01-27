#!/bin/bash
mkdir test;cd test

kolay init test
kolay add class TestClass
kolay add class Namespace::Test

cate
if [ $? -ne 0 ]; then
	echo "Error"
	cd ../; rm -rf _test
	exit 1
fi

cd ../; rm -rf _test
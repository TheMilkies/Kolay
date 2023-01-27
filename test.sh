#!/bin/bash
mkdir test;cd test

kolay init test
kolay new class TestClass
kolay new class TestNamespace::Test

cate
if [ $? -ne 0 ]; then
	echo "Error"
	cd ../; rm -rf _test
	exit 1
fi

cd ../; rm -rf _test
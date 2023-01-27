#!/bin/bash
mkdir _test;cd _test

kolay init test
kolay add class TestClass

cate
if [ $? -ne 0 ]; then
	echo "Error"
	cd ../; rm -rf _test
	exit 1
fi

cd ../; rm -rf _test
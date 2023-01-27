#!/bin/bash
mkdir test;cd test

kolay init test
kolay new class TestClass new class TestNamespace::Test
kolay new static-library TTTT new dynamic-library AAAA
kolay new stynamic-library QQQQ

cate
if [ $? -ne 0 ]; then
	echo "Error"
	cd ../; rm -rf _test
	exit 1
fi

cd ../; rm -rf test
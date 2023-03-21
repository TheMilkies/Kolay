#!/bin/bash
mkdir test;cd test

kolay init test
kolay new class a/TestClass new class TestNamespace::Test
kolay new static-library TestA new dynamic-library TestB
kolay new stynamic-library TestC
kolay new class TestC::Aquarius 
kolay new singleton TestA::Singleton new singleton TestB::Sengliton

kolay build
kolay release
if [ $? -ne 0 ]; then
	echo "Error"
	cd ../; rm -rf _test
	exit 1
fi

cd ../; rm -rf test
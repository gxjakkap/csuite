#!/usr/bin/env bash

name = $1
src = $2

if [[[ -z "$name"] || [ -z "$src"]]]; then
    echo "Invalid Parameter!"
    exit 1
fi

compileCommand = "./cm "$name" "$src""
eval $compileCommand

testCommand = "python3 .csuite/test/tester.py .csuite/bin/"$name"_"$src" 1"
eval $testCommand

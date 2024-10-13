#!/usr/bin/env bash

name=$1
src=$2
ext=$3

dir="./$src"

if [ -z "$name" ]; then
    echo "Invalid Parameter!"
    exit 1
fi

if [ -z "$ext" ]; then
    ext="c"
fi

if [ ! -d "./.csuite/bin" ]; then
    mkdir -p "./.csuite/bin"
fi

if [ "$ext" = "c" ]; then
    if [ -f "$dir/$name.c" ]; then
        compile_command="gcc \"$dir/$name.c\" -o \"./.csuite/bin/${name}_${src}\""
        echo "Compiling with command: $compile_command"

        eval $compile_command

        if [ $? -ne 0 ]; then
            echo "Error compiling $name. Check the source code for errors."
            exit 1
        else
            echo "$name.$ext compiled successfully! binary at .csuite/bin/${name}_${src}"
        fi
    else
        echo "File does not exist!"
    fi

elif [ "$ext" = "cc" ] || [ "$ext" = "cpp" ]; then
    if [ -f "$dir/$name.cc" ]; then
        compile_command="g++ \"$dir/$name.cc\" -o \"./.csuite/bin/${name}_${src}\""
        echo "Compiling with command: $compile_command"

        eval $compile_command

        if [ $? -ne 0 ]; then
            echo "Error compiling $name. Check the source code for errors."
            exit 1
        else
            echo "$name.$ext compiled successfully! binary at .csuite/bin/${name}_${src}"
        fi
    else
        echo "File does not exist!"
    fi

else
    echo "Compile command does not exist for $ext!"
    exit 1
fi


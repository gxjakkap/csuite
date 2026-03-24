#!/usr/bin/env bash

fileName=$1
dest=$2
ext=$3

templatedir=".csuite/template"

if [ -z "$ext" ]; then
    ext="c"
fi

if [ -z "$dest" ]; then
    echo "Missing Argument!"
    exit 1
fi

if [ "$ext" = "c" ]; then
    if [ -f "./$dest/$fileName.c" ]; then
        echo "./$dest/$fileName.c already exists!"
    else
        if [ ! -d "./$dest/" ]; then
            echo "$dest/$fileName does not exist. Creating..."
            mkdir -p "./$dest" || exit 1
        fi
        cp "./$templatedir/c.c" "./$dest/$fileName.c" || exit 1
        echo "./$dest/$fileName.c created successfully!"
    fi

elif [ "$ext" = "py" ] || [ "$ext" = "python" ]; then
    if [ -f "./$dest/$fileName.py" ]; then
        echo "./$dest/$fileName.py already exists!"
    else
        if [ ! -d "./$dest/" ]; then
            echo "$dest/$fileName does not exist. Creating..."
            mkdir -p "./$dest" || exit 1
        fi
        touch "./$dest/$fileName.py" || exit 1
        echo "./$dest/$fileName.py created successfully!"
    fi

elif [ "$ext" = "test" ] || [ "$ext" = "test.json" ]; then
    if [ -f "./$dest/$fileName.test.json" ]; then
        echo "./$dest/$fileName.test.json already exists!"
    else
        if [ ! -d "./$dest/" ]; then
            echo "$dest/$fileName does not exist. Creating..."
            mkdir -p "./$dest" || exit 1
        fi
        cp "./$templatedir/test.json" "./$dest/$fileName.test.json" || exit 1
        echo "./$dest/$fileName.test.json created successfully!"
    fi

else
    if [ -f "./$dest/$fileName.$ext" ]; then
        echo "./$dest/$fileName.$ext already exists!"
    else
        if [ ! -d "./$dest/" ]; then
            echo "$dest/$fileName does not exist. Creating..."
            mkdir -p "./$dest" || exit 1
        fi
        touch "./$dest/$fileName.$ext" || exit 1
        echo "./$dest/$fileName.$ext created successfully!"
    fi
fi

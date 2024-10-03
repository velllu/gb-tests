#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
CLEAR="\033[0m"

mkdir -p dist

if [ "$1" = "clean" ]; then
    printf "${GREEN}Cleaning${CLEAR}\n"
    find dist/ -not -name "*.gb" -type f -delete
    exit 0
fi

if [ -f src/$1.asm ]; then
    printf "${GREEN}Found 'src/$1.asm', building..."
else
    printf "${RED}File 'src/$1.asm' does not exist\n${CLEAR}"
    exit 1
fi

# Anything past this is gonna be an error
printf "${RED}\n"

rgbgfx -A -T -m -o dist/sprite.2bpp -t /dev/null assets/sprite.png && \
rm assets/*.attrmap && \

rgbasm -o dist/$1.obj "src/$1.asm" && \
rgblink -m dist/$1.map -n dist/$1.sym -o dist/$1.gb dist/$1.obj && \
rgbfix -p0 -v dist/$1.gb && \

printf "${GREEN}Built 'dist/$1.gb'!\n${CLEAR}"
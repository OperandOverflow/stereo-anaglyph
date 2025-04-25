#!/bin/bash

# Script to compile and link Anagliph.asm and Biblioteca.asm

# Filenames
SRC1="Anaglyph.asm"
SRC2="Biblioteca.asm"
OBJ1="Anagliph.o"
OBJ2="Biblioteca.o"
OUTPUT="anaglyph"

# Assemble both source files
nasm -F dwarf -f elf64 "$SRC1" -o "$OBJ1"
if [ $? -ne 0 ]; then
    echo "Assembly failed for $SRC1"
    exit 1
fi

nasm -F dwarf -f elf64 "$SRC2" -o "$OBJ2"
if [ $? -ne 0 ]; then
    echo "Assembly failed for $SRC2"
    exit 1
fi

# Link object files into final executable
ld "$OBJ1" "$OBJ2" -o "$OUTPUT"
if [ $? -ne 0 ]; then
    echo "Linking failed"
    exit 1
fi

echo "Build successful. Executable: $OUTPUT"

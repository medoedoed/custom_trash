#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Некорректное количество параметров"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Укажите путь"
    exit 1
else
    target_filename="$1"
fi

if [ ! -f "./$target_filename" ]; then 
    echo "Файл $target_filename не существует"
    exit 1
fi


trash_path="$HOME/.trash"
trash_log_filename=$".trash.log"

mkdir -p $trash_path

if [ ! -f "$HOME/$trash_log_filename" ]; then
    touch -p "$HOME/$trash_log_filename"
fi

pattern="hardlink[0-9]+"

max_number=$(find $trash_path -type f -name "hardlink*" \
    | grep -o 'hardlink[0-9]*' \
    | awk -F 'hardlink' '{print $2}' \
    | sort -n | tail -1)

next_number=$((max_number + 1))

hardlink_name="hardlink$next_number"

ln "$target_filename" "$trash_path/$hardlink_name"
rm $target_filename

echo "$PWD/$target_filename $hardlink_name" >> "$HOME/$trash_log_filename"



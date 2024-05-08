#!/bin/bash

if [ ! -z "$2" ]; then 
    echo "Слишком много параметров"
fi

if [ -z "$1" ]; then
        echo "Файл не указан"
        exit 1
    else
        filename="$1"
fi

read_ans() {
    while true; do
        read -p "Восстановить этот файл: (y/n)" ans < /dev/tty
        case "$ans" in
            [Yy]*) return 0 ;;  
            [Nn]*) return 1 ;;  
        esac
    done
}

trash_log_path="$HOME/.trash.log"
trash_path="$HOME/.trash"
recovered_files=() 

while IFS= read -r line; do
    full_path=$(echo $line | awk '{print $1}')
    hardlink_name=$(echo $line | awk '{print $2}')
    name=$(echo $full_path | awk -F/ '{print $NF}')
    
    if [ "$name" == "$filename" ]; then
        echo "$full_path"
        path=$(dirname "$full_path")
        
        if $(read_ans); then
            if [ -f "$full_path" ]; then
                echo "Такой файл уже существует укажите новое название файла: "
                read new_name < /dev/tty

                if [ -z "$new_name" ]; then
                    echo "Новое имя файла не указано. Операция отменена."
                    continue
                fi
                
                name=$new_name
                full_path="$path/$name"

                if [ -f "$full_path" ]; then
                    echo "Такой файл тоже существует. Операция отменена."
                    continue
                fi
            fi
        
            if [ -d "$path" ]; then
                ln "$trash_path/$hardlink_name" "$full_path"
    
            else
                ln "$trash_path$hardlink_name" "$name"

                echo "файл создан в текущей директории"
            fi

            recovered_files+=("$line")

            rm "$trash_path/$hardlink_name"
            
        fi
    fi
done < "$trash_log_path"

mapfile -t all_lines < "$trash_log_path"

for item in "${recovered_files[@]}"; do
    all_lines=("${all_lines[@]/$item/}") 
done

printf "%s\n" "${all_lines[@]}" > "$trash_log_path"


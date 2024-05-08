#!/bin/bash

last_backup_date=$(ls -d "$HOME"/Backup-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]  | sort -r | head -n 1 | awk -F/ '{print $NF}' | cut -c 8-)
current_date=$(date +"%Y-%m-%d")
backup_report_file="$HOME/backup-report"
backup_dir="$HOME/Backup-$current_date"
source_dir="$HOME/source"

if [ ! -f $backup_report_file ]; then
    touch $backup_report_file
fi

old_backup=$(($(date -d "$last_backup_date" +%s) / 86400))
cur_backup=$(($(date -d "$current_date" +%s ) / 86400))
diff=$(($cur_backup - $old_backup))

if [ $diff -ge 7 ]; then
    mkdir $backup_dir
    cp $source_dir/* $backup_dir

    echo "new backup created: $(echo $backup_dir | awk -F/ '{print $NF}')" >> $backup_report_file
    for file in $source_dir/*; do
        echo "added: $(basename $file)" >> $backup_report_file
    done
    echo " " >> $backup_report_file

    exit 0
else 
    update_backup_dir="$HOME/Backup-$last_backup_date"
    echo "old backup updated: $(echo $backup_dir | awk -F/ '{print $NF}')" >> $backup_report_file
    for file in $(ls $source_dir); do
        source_file="$source_dir/$file"
        backup_file="$update_backup_dir/$file"

        if [ ! -f $backup_file ]; then
            cp $source_file $backup_file
            echo "added: $(basename $file)" >> $backup_report_file
        else
            if [ $(stat -c%s "$source_file") -ne $(stat -c%s "$backup_file") ]; then
                mv "$backup_file" "$backup_file.$current_date"
                cp "$source_file" "$backup_file"
                echo "updated: $(basename $file)" >> $backup_report_file
            fi
        fi
    done

    echo " " >> $backup_report_file
    exit 0
fi


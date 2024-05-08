#!/bin/bash

last_backup_date=$(ls -d "$HOME"/Backup-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] | sort -r | head -n 1 | awk -F/ '{print $NF}')
restore_dir="$HOME/restore"

mkdir -p $restore_dir


for file in $(find "$HOME/$last_backup_date" -type f); do
    if ! [[ $(basename "$file") =~ \.[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]  ]]; then
        cp "$file" "$restore_dir"
    fi
done
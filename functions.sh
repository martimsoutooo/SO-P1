#!/bin/bash

target_directory=""
regex=""
lastdate=""

na=0
da=0
sa=0
ra=0
aa=0

function spacecheck(){
    for dir in "$@"; do 
        if [ -d "$dir" ]; then 
            target_directory="$dir"
        fi
    done

    while getopts ":n:d:s:ral:" opt; do 
        case $opt in
            n)
                regex=$OPTARG
                if is_regex "$regex"; then 
                    na=1
                else
                    echo "Missing or ivalida regular expression."
                fi
                ;;
            d)
                lastdate=$OPTARG
                da=1
                ;;
            s)
                minsize="$OPTARG"
                sa=1
                ;;
            r)
                ra=1
                ;;
            a)
                aa=1
                ;;
            l)
                ;;
        esac
    done

    name_filter "$target_directory" "$regex"
    size_filter "$target_directory" "$minsize"
    date_filter "$target_directory" "$lastdate"
    alphabetic_filter "$target_directory"                     
}

function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then
        
        while IFS= read -r -d '' k; do
            size=0
            folder=$(echo "$k" | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"

            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done < <(find "$k" -type f -regex ".*$padrao.*" -print0)
            echo "Size: $size"
        done < <(find "$repository" -type d -print0)
    fi
}

function date_filter() {
    repository="$1"
    user_date="$2"

    if [ $da -eq 1 ]; then

        while IFS= read -r -d '' k; do

            size=0
            folder=$(echo "$k" | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"

            while IFS= read -r -d '' i; do
                
                file_date_seconds=$(date -r "$i" "+%s")
                user_date_seconds=$(date -d "$user_date" +%s)

                if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                    
                    size_i=$(du -b "$i" | cut -f1)
                    size=$(($size+$size_i))

                fi

            done < <(find "$k" -type f -print0)

            echo "Size: $size"

        done < <(find "$repository" -type d -print0)

    fi 

}


function size_filter() {
    repository="$1"
    minsize="$2"

    if [ $sa -eq 1 ]; then

        while IFS= read -r -d '' k; do
            
            size=0
            folder=$(echo "$k" | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"

            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)

                    if [ $size_i -ge $minsize ]; then
                        size=$(($size+$size_i))
                    fi
            done < <(find "$k" -type f -print0)
            
            echo "Size: $size"

        done < <(find "$repository" -type d -print0)

    fi 
}

function is_regex() {
    pattern="$1"

    if [[ "$pattern" =~ ^[a-zA-Z0-9.*?]+$ ]]; then
        return 0
    else
        return 1
    fi
}

function alphabetic_filter(){

    repository="$1"
    if [ $aa -eq 1 ]; then
        echo "ALPHABETIC ORDER $repository"
        find "$repository" -type d | sort
    fi
}
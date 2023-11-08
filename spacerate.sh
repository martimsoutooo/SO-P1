#!/bin/bash

reverse=0
alphabetical=0
files=()

while getopts "ra" opt; do
    case $opt in
        r)
        reverse=1
        ;;
        a)
        alphabetical=1
        ;;
    esac
done
shift $((OPTIND -1))

for file in "$@"; do
    if [ -f "$file" ]; then
        files+=("$file")
    else
        echo "File $file does not exist, try again"
    fi
done

if [ ${#files[@]} -ne 2 ]; then
    echo "This script requires exactly two input files to compare."
    exit 1
fi

# Crie um array associativo para armazenar as informações do arquivo mais antigo
declare -A folders_older
while read -r line; do
    if [[ "$line" != *"SIZE"* ]]; then
        folder_older=$(echo "$line" | awk '{print $2}')
        size_older=$(echo "$line" | awk '{print $1}')
        
        folders_older["$folder_older"]=$size_older
    fi
done < "${files[1]}"

output=()

while read -r line; do
    if [[ "$line" == *"SIZE"* ]]; then
        continue
    fi

    size_new=$(echo "$line" | awk '{print $1}')
    folder_new=$(echo "$line" | awk '{print $2}')

    if [[ ! "${folders_older[$folder_new]+_}" ]]; then
        output+=("$size_new $folder_new NEW")
    else
        size_older=${folders_older[$folder_new]}
        unset "folders_older[$folder_new]"

        if [ "$size_new" -gt "$size_older" ]; then
            size_diff=$((size_new - size_older))
            output+=("$size_diff $folder_new")
        elif [ "$size_new" -lt "$size_older" ]; then
            size_diff=$((size_older - size_new))
            output+=("-$size_diff $folder_new")
        else
            output+=("0 $folder_new")
        fi
    fi
done < "${files[0]}"

# Verifique se há pastas removidas no arquivo mais antigo
for folder_older in "${!folders_older[@]}"; do
    size_older=${folders_older[$folder_older]}
    output+=("-$size_older $folder_older REMOVED")
done

# Imprimir o array de saída de acordo com as opções
if [ $reverse -eq 1 ]; then
    if [ $alphabetical -eq 1 ]; then
        printf "%-10s %-20s   %s\n" "SIZE" "NAME" "STATUS"
        printf "%s\n" "${output[@]}" | sort -r | awk '{printf "%-10s %-20s   %s\n", $1, $2, $3}'
    else
        printf "%-10s %-20s   %s\n" "SIZE" "NAME" "STATUS"
        printf "%s\n" "${output[@]}" | tac | awk '{printf "%-10s %-20s   %s\n", $1, $2, $3}'
    fi
else
    if [ $alphabetical -eq 1 ]; then
        printf "%-10s %-20s   %s\n" "SIZE" "NAME" "STATUS"
        printf "%s\n" "${output[@]}" | sort | awk '{printf "%-10s %-20s   %s\n", $1, $2, $3}'
    else
        printf "%-10s %-20s   %s\n" "SIZE" "NAME" "STATUS"
        printf "%s\n" "${output[@]}" | awk '{printf "%-10s %-20s   %s\n", $1, $2, $3}'
    fi
fi

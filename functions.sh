function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then    

        # Only search within the given directory, not subdirectories
        while IFS= read -r -d '' k; do
            size=0
            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done < <(find "$k" -type f -regex ".*$padrao.*" -print0)
            
            table_line_print $size $k
        done < <(find "$repository" -type d -print0)
        
    fi

}

function date_filter() {
    repository="$1"
    user_date_seconds="$2"

    if [ $da -eq 1 ]; then
        
        while IFS= read -r -d '' k; do

            size=0
            folder=$(echo "$k" | grep -P -o '(?<=\.\.\/).*')
            
            while IFS= read -r -d '' i; do
                
                file_date=$(date -r "$i" "+%Y-%m-%d")
                file_date_seconds=$(date -r "$i" +%s)
                
                if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                    size_i=$(du -b "$i" | cut -f1)
                    size=$(($size+$size_i))
                fi
            done < <(find "$k" -type f -print0)

            table_line_print $size $k
        done < <(find "$repository" -type d -print0)
    fi
}



function size_filter() {
    repository="$1"
    minsize="$2"

    if [ $sa -eq 1 ]; then

        while IFS= read -r -d '' k; do 
        # O -R CERTIFICA QUE A BACKSLASH É TRATADA COMO CHARACTER E NAO ESCAPE
        # O -D DIZ QUE O READ É DELIMITADO POR UM NULL \0
        # ISTO PERMITE TRATAR CORRETAMENTE DE DIRETÓRIOS COM ESCAÇOS NELES
            size=0
            
            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)

                if [ $size_i -ge $minsize ]; then
                    size=$(($size+$size_i))
                fi
            done < <(find "$k" -type f -print0)

            table_line_print $size $k
        done < <(find "$repository" -type d -print0)

        # EXECUTA O COMANDO E LE O OUTPUT COMO SE FOSSE UMA LINHA
        # < QUER LER UM FICHEIRO, <() METE O CONTENT DOS ()A SER LIDOS COMO FILE
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

function is_number() {
    local re='^[1-9][0-9]*$'
    if [[ $1 =~ $re ]]; then
        return 0  # Success (true)
    else
        return 1  # Failure (false)
    fi
}

function alphabetic_order(){

    repository="$1"
    if [ $aa -eq 1 ]; then
        find "$repository" -type d | sort | xargs -I {} du -sb {} | while read -r line; do    
            size=$(echo "$line" | awk '{print $1}')
            folder=$(echo "$line" | awk '{print $2}')
            table_line_print "$size" "$folder"
        done
    fi
}

function table_header_print() {
    
    header="SIZE NAME $(date +'%Y%m%d') "
    printf "%-10s %-5s %-10s" $header
    
    for ((i = 1; i <= $# - 1; i++)); do
        if [[ "${!i}" =~ ^[0-9]+$ ]]; then
            # Handle numeric arguments differently (without quotes)
            printf " %s" "${!i}"
        elif is_regex "${!i}"; then
            printf " \"%-4s\"" "${!i}"
        else
            printf "%3s" "${!i}"
        fi
    done
    
    printf "%3s \n" $(basename "${!#}") 

}

function table_line_print() {
    local array=("$@")
    local size="${array[0]}"
    local folder=$(echo "${array[1]}" | grep -P -o '(?<=\.\.\/).*')

    if [ "$max" == "Default" ]; then
        printf "%-10s %-5s \n" "$size" "$folder"
    else
        if [ $lines_printed -le $max ]; then
            printf "%-10s %-5s \n" "$size" "$folder"
            lines_printed=$(($lines_printed+1))
        fi
    fi
}
function no_argument() {
    repository="$1"

    if [ $na -eq 0 ] && [ $sa -eq 0 ] && [ $da -eq 0 ]; then  
    
        # Only search within the given directory, not subdirectories
        while IFS= read -r -d '' k; do
            size=0
            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done < <(find "$k" -type f -print0)
            
            associative["$k"]="$size"
        
        done < <(find "$repository" -type d -print0)
        
        table_line_print
    fi
}

function name_filter() {
    repository="$1"
    padrao="$2"
    nc=1
    declare -A passed_name

    if [ $na -eq 1 ]; then  
        if [ ${#passed_filters[@]} -eq 0 ];then
            # Only search within the given directory, not subdirectories
            while IFS= read -r -d '' k; do
                size=0
                folder_files=()
                while IFS= read -r -d '' i; do
                    size_i=$(du -b "$i" | cut -f1)
                    size=$(($size+$size_i))
                    folder_files+=("$i")
                done < <(find "$k" -type f -regex ".*$padrao.*" -print0)
                
                # COnVERTER O ARRAY NUMA STRING PARA PODER GUARDAR
                # A VIRGULA GUARDA OS ELEMENTOS DO ARRAY SEPARADOS POR UMA VIRGULA
                passed_name["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"
            
            done < <(find "$repository" -type d -print0)
            
        else
            # run through the files previoulsy filtered and filter AGAIN
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                # RECONVERTE EM ARRAY A STRING
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
                    if [[ $j =~ $padrao ]]; then
                        size_i=$(du -b "$j" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$j")
                    fi
                done
                passed_name["$folder"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$folder"]="$size"
            done
            

            
        fi

        for key in "${!passed_filters[@]}"; do
            unset passed_filters["$key"]
        done
        for i in "${!passed_name[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_name[$i]}"
            # isto associa um folder a uma string de files filtrados
        done
        
        table_line_print
    fi
}

function size_filter() {
    repository="$1"
    minsize="$2"
    sc=1
    declare -A passed_size
    if [ $sa -eq 1 ]; then
        
        if [ ${#passed_filters[@]} -eq 0 ];then
            while IFS= read -r -d '' k; do 
            
                size=0
                folder_files=()              
                while IFS= read -r -d '' i; do
                    size_i=$(du -b "$i" | cut -f1)

                    if [ $size_i -ge $minsize ]; then
                        size=$(($size+$size_i))
                        folder_files+=("$i")
                    fi
                done < <(find "$k" -type f -print0)        
                 # EXECUTA O COMANDO E LE O OUTPUT COMO SE FOSSE UMA LINHA
                # < QUER LER UM FICHEIRO, <() METE O CONTENT DOS ()A SER LIDOS COMO FILE

                passed_size["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$repository" -type d -print0)

        else
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
                    size_i=$(du -b "$j" | cut -f1)
                    if [ $size_i -ge $minsize ]; then
                        size=$(($size+$size_i))
                        folder_files+=("$j")
                    fi
                done

                passed_size["$folder"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$folder"]="$size"
            done
            

            
        fi
        
        for key in "${!passed_filters[@]}"; do
            unset passed_filters["$key"]
        done

        for i in "${!passed_size[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_size[$i]}"
        done
        
        table_line_print
    fi
}



function date_filter() {
    repository="$1"
    user_date_seconds="$2"
    dc=1
    declare -A passed_date

    if [ $da -eq 1 ]; then

        if [ ${#passed_filters[@]} -eq 0 ]; then
            while IFS= read -r -d '' k; do

                size=0
                folder_files=()
                while IFS= read -r -d '' i; do
                    
                    file_date=$(date -r "$i" "+%Y-%m-%d")
                    file_date_seconds=$(date -r "$i" +%s)

                    if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                        size_i=$(du -b "$i" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$i")
                    fi

                done < <(find "$k" -type f -print0)

                passed_date["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$repository" -type d -print0)
        else
            
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
                    
                    file_date=$(date -r "$j" "+%Y-%m-%d")
                    file_date_seconds=$(date -r "$j" +%s)
                    
                    if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                        size_j=$(du -b "$j" | cut -f1)
                        size=$(($size+$size_j))
                        folder_files+=("$j")
                    fi
                done
                
                passed_date["$folder"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$folder"]="$size"
            done

        fi

        for key in "${!passed_filters[@]}"; do
            unset passed_filters["$key"]
        done

        for i in "${!passed_date[@]}"; do
                if [ -z "${passed_filters[$i]}" ]; then
                    passed_filters["$i"]=""
                fi
                passed_filters["$i"]+="${passed_date[$i]}"
                
        done

        
        table_line_print
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

function table_header_print() {
    
    header="SIZE NAME $(date +'%Y%m%d') "
    printf "%-10s %-5s %-10s" $header
    
    for i in "${args[@]}"; do     
        if is_number "$i"; then
            # Handle numeric arguments differently (without quotes)
            printf " %s" "$i"
        elif is_regex "$i"; then
            printf " \"%-4s\"" "$i"
        elif [ -d "$i" ]; then
            continue
        else
            printf " %3s" "$i"
        fi
    done
    
    printf "%3s \n" $(basename "${!#}") 

}

function table_line_print() {

    if [ $dc -eq 1 ] && [ $nc -eq 1 ] && [ $sc -eq 1 ]; then

        if [ $aa -eq 1 ] && [ $ra -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort -r ))
        elif [ $aa -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort ))
        elif [ $ra -eq 1 ]; then
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' | tac ))
        else 
            # POR DEFAUT IMPRIME POR SIZE 
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' ))
        fi

        for i in "${folders[@]}"; do
            folder_pretty=$(echo "${i}" | grep -P -o '(?<=\.\.\/).*')
            size="${associative[$i]}" 
            if [ "$max" == "Default" ]; then
                printf "%-10s %-5s \n" "$size" "$folder_pretty"
            else
                if [ $lines_printed -le $max ]; then             
                    printf "%-10s %-5s \n" "$size" "$folder_pretty"
                    lines_printed=$(($lines_printed+1))
                fi
            fi
        done
    fi
}
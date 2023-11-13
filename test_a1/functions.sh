function no_argument() {
    # a função executa apenas quando o unico argumento é o diretorio
    directory="$1"
    
    if [ $na -eq 0 ] && [ $sa -eq 0 ] && [ $da -eq 0 ]; then # verifica se nehnuma função foi ativada
    
        while IFS= read -r -d '' k; do # guarda o directorio na variable k
            size=0
            while IFS= read -r -d '' i; do # guarda o file na variable i
                size_i=$(du -b "$i" | cut -f1) # encontra o tamanho do file
                size=$(($size+$size_i))
            done < <(find "$k" -type f -print0) # encontra todos os files dentro do diretorio k
            
            associative["$k"]="$size" # guarda o tamanho como value da key folder
        
        done < <(find "$directory" -type d -print0) # encontra todos os subdiretorios dentro do diretorio dado
        
        table_line_print # imprime a tabela
    fi
}

function name_filter() {
    directory="$1"
    padrao="$2"
    nc=1 # declara que a função foi ativada
    declare -A passed_name # declara um array associativo, vai ter como values as pastas e como values os ficheiros que passam ao filtro

    if [ $na -eq 1 ]; then # verifica se a função foi ativada 
        if [ ${#passed_filters[@]} -eq 0 ];then # verifica se a função foi a primeira a ser corrida ou se houve uma filtragem previamente            
            while IFS= read -r -d '' k; do
                size=0
                folder_files=()
                while IFS= read -r -d '' i; do
                    size_i=$(du -b "$i" | cut -f1)
                    size=$(($size+$size_i))
                    folder_files+=("$i")
                done < <(find "$k" -type f -regex ".*$padrao.*" -print0 2>/dev/null) # se for encontrado um erro no find, o erro é redirecionado para o /dev/null

                # O array de ficheiros filtrados é convertido numa string 
                passed_name["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"
            
            done < <(find "$directory" -type d -print0 2>/dev/null)
            
        else
            # Pega no array que contem os ficheiros que passaram os filtros e filtra novamente
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                array_string="${passed_filters[$folder]}"

                # Reconverte a string que contem os ficheiros filtrados num array
                IFS=, read -ra folder_files_before <<< "$array_string" 
                for j in "${folder_files_before[@]}"; do
                    if [[ $j =~ $padrao ]]; then
                        size_i=$(du -b "$j" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$j")
                    fi
                done
                passed_name["$folder"]=$(IFS=,; echo "${folder_files[*]}") # guarda num array associativo os files que passaram o filtro
                associative["$folder"]="$size"
            done
            

            
        fi

        # esvazia o array que contem os ficheiros que passaram os filtros
        for key in "${!passed_filters[@]}"; do
            unset passed_filters["$key"]
        done

        # torna os valores do passed_filters nos valores do passed_name, que foram filtrados mais recentemente
        for i in "${!passed_name[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_name[$i]}"
            # isto associa um folder a uma string de files filtrados
        done
        
        for key in "${!passed_name[@]}"; do
            unset passed_name["$key"] # esvazia o array passed_name para caso esta função seja chamada novamente
        done


        table_line_print
    fi
}

function size_filter() {
    directory="$1"
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
                done < <(find "$k" -type f -print0 2>/dev/null)        
                # Executa o comando e lê o output do comando, o output é lido como um ficheiro
                # < Quer ler um ficheiro, <() mete o content dos () a ser lidos como file

                passed_size["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$directory" -type d -print0 2>/dev/null)

        else
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                array_string="${passed_filters[$folder]}"

                IFS=, read -ra folder_files_before <<< "$array_string"
                for j in "${folder_files_before[@]}"; do
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
        for key in "${!passed_size[@]}"; do
            unset passed_sized["$key"]
        done
        
        table_line_print
    fi
}

function date_filter() {

    directory="$1"
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
                    file_date_seconds=$(date -r "$i" +%s) # converte a data para segundos

                    if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                        size_i=$(du -b "$i" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$i")
                    fi
                    

                done < <(find "$k" -type f -print0 2>/dev/null)
                

                passed_date["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$directory" -type d -print0 2>/dev/null)
        
        else
            for folder in "${!passed_filters[@]}"; do
                size=0
                folder_files=()
                array_string="${passed_filters[$folder]}"
                
                IFS=, read -ra folder_files_before <<< "$array_string"
                for j in "${folder_files_before[@]}"; do
                    
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
        for key in "${!passed_date[@]}"; do
            unset passed_date["$key"]
        done
        
        table_line_print
    fi
    
}


function is_regex() {
    pattern="$1"

    # verifica se o arguemnto é uma expressão regular válida
    if [[ "$pattern" =~ ^[a-zA-Z0-9.*?]+$ ]]; then
        return 0
    else
        return 1
    fi
}

function is_number() {

    # verifica se o argumento é um numero inteiro maior ou igual a 0
    local re='^[0-9]+$'
    if [[ $1 =~ $re ]]; then
        return 0 
    else
        return 1  
    fi
}

function table_header_print() {

    # printa o header da tabela
    if [ $folder_count -eq "${#dirs[@]}" ]; then

        header="SIZE NAME $(date +'%Y%m%d') "
        printf "% s % s % s" $header
        diretorios=()
    
        for i in "${args[@]}"; do     
            if is_regex "$i" || [[ "$i" =~ ^[A-Z][a-z]{2}\ [0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
                printf " \"%s\"" "$i" # se o argumento for uma expressão regular ou uma data, printa o argumento entre aspas
            elif [ -d "$i" ]; then
                diretorios+=("$i") # se for um directory, adiciona a um array para dar print no final do header
                continue
            else
                printf " %s" "$i"
            fi
        done
        for i in "${diretorios[@]}"; do
            printf " %s" $(basename "$i") 
        done
        printf "\n" ""
    fi
    
}

function table_line_print() {

    # verifica se tudo o que foi pedido foi corrido
    if [ $dc -eq 1 ] && [ $nc -eq 1 ] && [ $sc -eq 1 ] && [ $folder_count -eq "${#dirs[@]}" ] && [ $name_counter -eq "${#regex_ar[@]}" ]; then
        
        # analisa a maneira de ler os dados que o user pediu
        if [ $aa -eq 1 ] && [ $ra -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort -r ))
        elif [ $aa -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort ))
        elif [ $ra -eq 1 ]; then
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' | tac ))
        else 
            # Por default ordena por ordem decresecnte de size
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' ))
        fi

        for i in "${folders[@]}"; do
            folder_pretty=$(echo "${i}" | sed -e 's/\.\.\///g' -e 's/\.\///g') # remove a parte indesejada do path
            size="${associative[$i]}" 
            if [ -z $size ]; then #verifica se o array existe
                size="NA"
            fi

            if [ "$max" == "Default" ]; then
                printf "% s % s \n" "$size" "$folder_pretty"
            else
                if [ $lines_printed -le $max ]; then             
                    printf "% s % s \n" "$size" "$folder_pretty"
                    lines_printed=$(($lines_printed+1))
                fi
            fi
        done
        exit 0
    fi
}
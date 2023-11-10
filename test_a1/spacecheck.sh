
#!/bin/bash

# Importa funções do ficheiro functions.sh
source functions.sh

# Inicializa variáveis para controlo de opções
na=0
da=0
sa=0
ra=0
aa=0
nc=1
dc=1
sc=1

#Arrays
dirs=()
declare -A associative
declare -A passed_filters
args_bons=()

max="Default"
lines_printed=1
folder_count=0

# Itera pelos argumentos da linha de comando
for dir in "$@"; do 
    if [ -d "$dir" ]; then   
        dirs+=("$dir")  # Define o diretório de destino se for um diretório válido
    fi
done

regex_ar=()
options=("-n" "-d" "-s" "-l" "-r" "-a")
args_bons=()
# Processa as opções da linha de comando com getopts
while getopts "n:d:s:l:ra" opt; do case $opt in
        n)
            regex=$OPTARG
            if is_regex "$regex"; then 
                regex_ar+=($regex)
                args_bons+=($regex)
                na=1
                nc=0
            else
                echo "Error: Regex is either invalid or missing"
                exit 1
            fi
            ;;
        d)
            lastDate=$OPTARG
            # Verifica se a data fornecida é válida
            if [[ "$lastDate" =~ ^[A-Z][a-z]{2}\ [0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
                if date -d "$lastDate" >/dev/null 2>&1; then
                    lDate=$(date --date="$lastDate" +"%s") # Converte a data para segundos desde a época
                    args_bons+=($lastDate)
                    da=1   
                    dc=0                                  
                else 
                    echo "Error: Date is invalid"
                    exit 1
                fi
            else 
                echo "Error: Date is not in the expected format--> \"MMM DD HH:MM\""
                exit 1
            fi
            ;;  
        s)
            minsize="$OPTARG"
            if is_number "$minsize"; then
                args_bons+=($minsize)
                sa=1
                sc=0
            else
                echo "Error: Size is either empty or invalid"
                exit 1
            fi
            ;;
        r)
            ra=1
            ;;
        a)
            aa=1
            ;;
        l)
            n_lines="$OPTARG"
            if is_number "$n_lines"; then
                args_bons+=($n_lines)
                max="$n_lines"
            else 
                echo "Error: Invalid number of lines"
                exit 1
            fi
            ;;
        *)
            echo "Error: Invalid option"
            exit 1
            ;;
    esac
done

args=("$@")
for i in "${args[@]}"; do
    if [[ " ${args_bons[@]} " =~ " $i " ]] || [[ " ${options[@]} " =~ " $i " ]] || [[ " ${dirs[@]} " =~ " $i " ]]; then
        continue
    else
        echo "Error: Invalid argument \"$i\"" 
        exit 1
    fi
done

# Chama funções para processar os filtros e imprimir a tabela
for folder in ${dirs[@]}; do
    name_counter=0
    folder_count=$(($folder_count+1))
    for key in "${!passed_filters[@]}"; do
        unset passed_filters["$key"]
    done
    for key in "${!associative[@]}"; do
        unset passed_filters["$key"]
    done
    table_header_print "${args[@]}"
    no_argument "$folder"
    for i in "${regex_ar[@]}"; do
        name_counter=$(($name_counter+1))
        name_filter "$folder" "$i"
        
    done
    date_filter "$folder" "$lDate"
    size_filter "$folder" "$minsize"
    
done



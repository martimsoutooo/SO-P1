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
extras_podres=()

max="Default"
lines_printed=1

# Itera pelos argumentos da linha de comando
for dir in "$@"; do 
    if [ -d "$dir" ]; then 
        dirs+=("$dir")  # Define o diretório de destino se for um diretório válido
    fi
done

# Processa as opções da linha de comando com getopts
while getopts "n:d:s:l:ra" opt; do 
    case $opt in
        n)
            regex=$OPTARG
            if is_regex "$regex"; then 
                na=1
                nc=0
            else
                echo "Falta ou regex inválida."
            fi
            ;;
        d)
            lastDate=$OPTARG
            echo $lastDate
                
            # Verifica se a data fornecida é válida
            if date -d "$lastDate" >/dev/null 2>&1; then                                       
                lDate=$(date --date="$lastDate" +"%s")  # Converte a data para segundos desde a época
                da=1   
                dc=0                                  
            else 
                echo "Erro: Data de início inválida"
                exit 1
            fi
            ;;  
        s)
            minsize="$OPTARG"
            sa=1
            sc=0
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
                max="$n_lines"
            fi
            ;;
        *)
            echo "Opção inválida: -$OPTARG" >&2
            exit 1
    esac
done

shift $((OPTIND-1))

for folder in ${dirs[@]}; do 
    echo "$folder"
done

# Função para processar filtros e imprimir a tabela para um diretório
process_directory() {
    local folder="$1"
    declare -A associative
    declare -A passed_filters

    table_header_print "$@"
    no_argument "$folder"
    name_filter "$folder" "$regex"
    size_filter "$folder" "$minsize"
    date_filter "$folder" "$lDate"
}

# Processa cada diretório individualmente
for folder in "${dirs[@]}"; do
    process_directory "$folder"
done



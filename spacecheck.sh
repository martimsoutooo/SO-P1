#!/bin/bash

# Importa funções do ficheiro functions.sh
source functions.sh

# Inicializa variáveis para controlo de opções
na=0
da=0
sa=0
ra=0
aa=0

max="Default"
lines_printed=1

# Itera pelos argumentos da linha de comando
for dir in "$@"; do 
    if [ -d "$dir" ]; then 
        target_directory="$dir"  # Define o diretório de destino se for um diretório válido
    fi
done

# Processa as opções da linha de comando com getopts
while getopts "n:d:s:l:ra" opt; do 
    case $opt in
        n)
            regex=$OPTARG
            if is_regex "$regex"; then 
                na=1
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
            else 
                echo "Erro: Data de início inválida"
                exit 1
            fi
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

# Chama funções para processar os filtros e imprimir a tabela
table_header_print $@
name_filter "$target_directory" "$regex"
size_filter "$target_directory" "$minsize"
date_filter "$target_directory" "$lDate"
alphabetic_order "$target_directory"



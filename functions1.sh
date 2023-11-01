#!/bin/bash

function spacecheck1(){
    for dir in $@: do
        if [dir -d]; then
            target_directory=$dir
        fi
    done

    while getopts "n:d:s:l:ar" opt; do
        case $opt in
            n)
                # Opção -n: filtrar por expressão regular
                regex=$OPTARG

                if is_regex "$regex";then
                    
                else 
                    echo "$regex não é uma expressão regular"
                fi
                
                ;;
            d)
                # Opção -d: filtrar por data
                date=$OPTARG
                
                ;;
            s)
                # Opção -s: filtrar por tamanho mínimo
                minsize=$OPTARG
                
                ;;
            r)
                # Opção -r: classificar em ordem reversa
                
                ;;
            a)
                # Opção -a: classificar em ordem normal
                
                ;;
            l) 
                # Opção -l: número de linhas na tabela
                tablelines=$OPTARG
                
                ;;
            *)
                echo "Option not found"
                
                ;; 
        esac
    done

}

is_regex() {
    local pattern="$1"
    if echo "dummy" | grep -P "$pattern" >/dev/null 2>&1; then
        return 0  # A string é uma expressão regular
    else
        return 1  # A string não é uma expressão regular
    fi
}
spacecheck1

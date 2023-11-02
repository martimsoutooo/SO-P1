target_directory=""
regex=""
date="2050-01-01"
na=0
da=0
sa=0
ra=0
aa=0

function spacecheck() {
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            target_directory="$dir"
        fi
    done

    while getopts "n:d:s:ral" opt; do
        case $opt in
            n)
                regex="$OPTARG"
                if is_regex "$regex"; then
                    na=1
                else
                    echo "Missing or invalid regular expression argument for -n option."
                    exit 1
                fi
                ;;
            d)
                date="$OPTARG"
                if is_date "$date"; then
                    echo "$date"
                    da=1
                else
                    echo "Missing or invalid date argument for -d option."
                    exit 1
                fi
                ;;
            s)
                minsize="$OPTARG"
                sa=1
                ;;
            r)
                # ordem inversa
                ra=1
                ;;
            a)
                # ordem alfabética
                aa=1
                ;;
            l)
                # número de linhas que o utilizador quer na tabela
                ;;
            *)
                echo "Deu merda mano"
                ;;
        esac
    done

    name_filter "$target_directory" "$regex"
    size_filter "$target_directory" "$minsize"
    alphabetic_order "$target_directory"
    table_print $@
}

# ################# FUNCOES OPERAÇOES POSSIVEIS #########################
# #-----------------------------------------------------------------------#

function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then
        echo "SIZE NAME $repository $padrao"
    

        # Only search within the given directory, not subdirectories
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

function size_filter() {
    repository="$1"
    minsize="$2"

    if [ $sa -eq 1 ]; then
        echo "SIZE NAME $repository $minsize"

        while IFS= read -r -d '' k; do 
        # O -R CERTIFICA QUE A BACKSLASH É TRATADA COMO CHARACTER E NAO ESCAPE
        # O -D DIZ QUE O READ É DELIMITADO POR UM NULL \0
        # ISTO PERMITE TRATAR CORRETAMENTE DE DIRETÓRIOS COM ESCAÇOS NELES
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

        # EXECUTA O COMANDO E LE O OUTPUT COMO SE FOSSE UMA LINHA
        # < QUER LER UM FICHEIRO, <() METE O CONTENT DOS ()A SER LIDOS COMO FILE
    fi
}

function alphabetic_order(){

    repository="$1"
    if [ $aa -eq 1 ]; then
        echo "ALPHABETIC ORDER $repository"
        find "$repository" -type d | sort
    fi
}

function table_print() {
    header="Size Name $(date +'%Y-%m-%d') "
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

# ################# FUNCOES VERIFICAO E AUXILIARES #########################
# #-----------------------------------------------------------------------#

function is_date() {
    local date_str="$1"
    date -d "$date_str" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function is_regex() {
    local pattern="$1"

    # Verifica se o padrão parece ser uma expressão regular válida
    if [[ "$pattern" =~ ^[a-zA-Z0-9.*?]+$ ]]; then
        return 0
    else
        return 1
    fi
}




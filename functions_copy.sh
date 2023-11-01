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
                lastdate="$OPTARG"
                da=1
                
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
                ;;
        esac
    done

    name_filter "$target_directory" "$regex"
    size_filter "$target_directory" "$minsize"
    date_filter "$target_directory" "$lastdate"
}

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


function date_filter() {
    repository="$1"
    user_date="$2"

    if [ $da -eq 1 ]; then
        echo "DATE NAME $repository $user_date"
        
        user_date_formatted=$(date -d "$user_date" "+%Y-%m-%d")

        while IFS= read -r -d '' k; do
            size=0
            folder=$(echo "$k" | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"
            
            while IFS= read -r -d '' i; do
                
                file_date=$(date -r "$i" "+%Y-%m-%d")

                file_date_seconds=$(date -r "$i" +%s)
                user_date_seconds=$(date -d "$user_date_formatted" +%s)
                
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

function is_date() {
   local date_str="\$1"
   local date_out=$(date -d "$date_str" 2>&1)
   if [[ $date_out =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
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




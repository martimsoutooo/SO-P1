
target_directory=0
regex=""
date="2050-01-01"
na=0
da=0
sa=0
ra=0
aa=0

function spacecheck() {
     for dir in $@: do
        if [dir -d]; then
            target_directory=$dir
        fi
    done
        
    
    while getopts "n:d:s:l:ar" opt; do
        case $opt in
            n)
                regex=$OPTARG
                if is_regex "$regex"; then
                    na=1 
                else
                    echo "Missing regular expression argument for -n option."
                    exit 1
                fi
                ;;
            d)
                date=$OPTARG
                if is_date $date; then
                    echo "$date"
                    da=1
                else
                    echo "Missing date argument for -d option."
                    exit 1
                fi
                ;;
            s)
                # tamanho mínimo
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
                #if [ -d $i ]
                ;;
        esac
    done

    name_filter "$target_directory" "$regex"
}

function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then
        echo "Name filter"
        echo "$repository"
        echo "$padrao"
    fi

    # Only search within the given directory, not subdirectories
    for k in $(find "$repository" -maxdepth 1 -type d); do
    
        size=0
        echo "Folder"
        echo "$k"
        for i in $(find "$k" -maxdepth 1 -type f -regex ".*$padrao.*"); do
            echo "$i"
            size=$(du -h "$i" | cut -f1)
            echo "Size: $size"
        done
    done
}


function is_date(){
    local date_str="$1"
    date -d "$date_str" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valid date"
    else
        echo "Invalid date"
    fi
}

function is_regex() {
    local pattern="$1"
    if echo "dummy" | grep -P "$pattern" >/dev/null 2>&1; then
        return 0  
    else
        return 1  
    fi
}
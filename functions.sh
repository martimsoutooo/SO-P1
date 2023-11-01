
padrao=""
data="2050-01-01"
na=0
da=0
sa=0
ra=0
aa=0

function spacecheck() {
    if [ $# -lt 1 ]; then
        echo "Nenhum argumento foi fornecido."
        exit 1
    fi  
    if [ ! -d "${!#}" ]; then
        echo "O último argumento NÃO é um diretório: ${!#}"
    fi
        
    
    for ((i=1; i<=$#; i++)); do
        case "${!i}" in
            "-n")
                if [ $((i + 1)) -le $# ]; then
                    temp=$((i+1))
                    padrao="${!temp}"

                    na=1
                    #DAR SKIP AO PRÓXIMO ARGUMENTO PORQUE VAI SER O REGEX
                    i=$((i + 1))
                else
                    echo "Missing regular expression argument for -n option."
                    exit 1
                fi
                
                ;;
            "-d")
                # data máxima de modificação
                if [ $((i + 1)) -le $# ] && [[ "${!i}" == '"'* ]]; then
                    data="${!i}"
                    shift
                    echo "${data}"
                    data_check "$data"
                    da=1
                    # SKIP TO THE NEXT ARGUMENT BECAUSE IT WILL BE A DATE
                    i=$((i + 1))
                else
                    echo "Missing date argument for -d option."
                    exit 1
                fi
                ;;
            "-s")
                # tamanho mínimo
                ;;
            "-r")
                # ordem inversa
                ;;
            "-a")
                # ordem alfabética
                # ${!#} SIGNIFICA ULTIMO ARGUMENTO
                du -b "$repository" | awk ' {print $1, $2}' | sort -k2,2 
                ;;
            "-l")
                # número de linhas que o utilizador quer na tabela
                ;;
            *)
                #if [ -d $i ]
                ;;
        esac
    done
    repository="${!#}" 

    name_filter "$repository" "$padrao"
}

function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then
        echo "SIZE NAME $repository $padrao"
    

        # Only search within the given directory, not subdirectories
        for k in $(find "$repository" -maxdepth 1 -type d); do
        
            size=0
            folder=$(echo $k | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"
            for i in $(find "$k" -type f -regex ".*$padrao.*"); do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done
            echo "Size: $size"
        done
    fi
}


function data_check(){
    local date_str="$1"
    date -d "$date_str" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valid date"
    else
        echo "Invalid date"
    fi
}
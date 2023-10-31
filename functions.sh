
function name_filter() {
    repository="$1"
    padrao="$2"


    find "$repository" -type f -name "*$padrao*" | while read -r file; do
        dir=$(dirname "$file") # todos
        size=$(du -sh "$dir" | cut -f1)
        echo "$size $dir"
        
    done

}

function spacecheck() {
    if [ $# -lt 1 ]; then
        echo "Nenhum argumento foi fornecido."
        exit 1
    fi  
    if [ ! -d "${!#}" ]; then
        echo "O último argumento NÃO é um diretório: ${!#}"
    fi
        
    padrao=""
    na=1
    da=0
    sa=0
    ra=0
    aa=0
    
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

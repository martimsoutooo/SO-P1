target_directory=""
regex=""
date="2050-01-01"
na=0
da=0
sa=0
ra=0
aa=0
max="Default"
lines_printed=1
declare -A associative
declare -A passed_filters
nc=1
dc=1
sc=1

# ################# FUNCOES OPERAÇOES POSSIVEIS #########################
# #-----------------------------------------------------------------------#

function no_argument() {
    repository="$1"

    if [ $na -eq 0 ] && [ $sa -eq 0 ] && [ $da -eq 0 ]; then  
    
        # Only search within the given directory, not subdirectories
        while IFS= read -r -d '' k; do
            size=0
            while IFS= read -r -d '' i; do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done < <(find "$k" -type f -print0)
            
            associative["$k"]="$size"
        
        done < <(find "$repository" -type d -print0)
        
        table_line_print
    fi
}


function name_filter() {
    repository="$1"
    padrao="$2"
    nc=1
    declare -A passed_name

    if [ $na -eq 1 ]; then  
        if [ ${#passed_filters[@]} -eq 0 ];then
            # Only search within the given directory, not subdirectories
            while IFS= read -r -d '' k; do
                size=0
                folder_files=()
                while IFS= read -r -d '' i; do
                    size_i=$(du -b "$i" | cut -f1)
                    size=$(($size+$size_i))
                    folder_files+=("$i")
                done < <(find "$k" -type f -regex ".*$padrao.*" -print0)
                
                # COnVERTER O ARRAY NUMA STRING PARA PODER GUARDAR
                # A VIRGULA GUARDA OS ELEMENTOS DO ARRAY SEPARADOS POR UMA VIRGULA
                passed_name["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"
            
            done < <(find "$repository" -type d -print0)
            
        else
            # run through the files previoulsy filtered and filter AGAIN
            for folder in "${!passed_filters[@]}"; do
                size=0
                # RECONVERTE EM ARRAY A STRING
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
                    if [[ $j =~ $padrao ]]; then
                        size_i=$(du -b "$j" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$j")
                    fi
                done
                passed_name["$folder"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$folder"]="$size"
            done
            

            
        fi

        for i in "${!passed_name[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_name[$i]}"
            # isto associa um folder a uma string de files filtrados
        done
        
        table_line_print
    fi
}

function size_filter() {
    repository="$1"
    minsize="$2"
    sc=1
    declare -A passed_size
    if [ $sa -eq 1 ]; then
        
        if [ ${#passed_filters[@]} -eq 0 ];then
            while IFS= read -r -d '' k; do 
            # O -R CERTIFICA QUE A BACKSLASH É TRATADA COMO CHARACTER E NAO ESCAPE
            # O -D DIZ QUE O READ É DELIMITADO POR UM NULL \0
            # ISTO PERMITE TRATAR CORRETAMENTE DE DIRETÓRIOS COM ESCAÇOS NELES
                size=0
                folder_files=()                
                while IFS= read -r -d '' i; do
                    size_i=$(du -b "$i" | cut -f1)

                    if [ $size_i -ge $minsize ]; then
                        size=$(($size+$size_i))
                        folder_files+=("$i")
                    fi
                done < <(find "$k" -type f -print0)        
                 # EXECUTA O COMANDO E LE O OUTPUT COMO SE FOSSE UMA LINHA
                # < QUER LER UM FICHEIRO, <() METE O CONTENT DOS ()A SER LIDOS COMO FILE

                passed_size["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$repository" -type d -print0)

        else
            for folder in "${!passed_filters[@]}"; do
                size=0
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
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
        for i in "${!passed_size[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_size[$i]}"
        done
        
        table_line_print
    fi
}

function date_filter() {
    repository="$1"
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
                    file_date_seconds=$(date -r "$i" +%s)
                    
                    if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                        size_i=$(du -b "$i" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$i")
                    fi
                done < <(find "$k" -type f -print0)

                passed_date["$k"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$k"]="$size"

            done < <(find "$repository" -type d -print0)
        else
            for folder in "${!passed_filters[@]}"; do
                size=0
                array_string="${passed_filters[$folder]}"
                IFS=, read -ra folder_files <<< "$array_string"
                for j in "${folder_files[@]}"; do
                    file_date=$(date -r "$j" "+%Y-%m-%d")
                    file_date_seconds=$(date -r "$j" +%s)
                    if [[ "$file_date_seconds" -le "$user_date_seconds" ]]; then
                        size_i=$(du -b "$j" | cut -f1)
                        size=$(($size+$size_i))
                        folder_files+=("$j")
                    fi
                done

                passed_date["$folder"]=$(IFS=,; echo "${folder_files[*]}")
                associative["$folder"]="$size"
            done
            
        fi
        for i in "${!passed_date[@]}"; do
            if [ -z "${passed_filters[$i]}" ]; then
                passed_filters["$i"]=""
            fi
            passed_filters["$i"]+="${passed_date[$i]}"
        done
        table_line_print
    fi
}

function table_header_print() {
    
    header="SIZE NAME $(date +'%Y%m%d') "
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

function table_line_print() {

    if [ $dc -eq 1 ] && [ $nc -eq 1 ] && [ $sc -eq 1 ]; then

        if [ $aa -eq 1 ] && [ $ra -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort -r ))
        elif [ $aa -eq 1 ]; then
            folders=($(echo "${!associative[@]}" | tr ' ' '\n' | sort ))
        elif [ $ra -eq 1 ]; then
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' | tac ))
        else 
            # POR DEFAUT IMPRIME POR SIZE 
            folders=($(for i in "${!associative[@]}"; do echo "${associative[$i]} $i"; done | sort -n -r | awk '{print $2}' ))
        fi

        for i in "${folders[@]}"; do
            folder_pretty=$(echo "${i}" | grep -P -o '(?<=\.\.\/).*')
            size="${associative[$i]}" 
            if [ "$max" == "Default" ]; then
                printf "%-10s %-5s \n" "$size" "$folder_pretty"
            else
                if [ $lines_printed -le $max ]; then             
                    printf "%-10s %-5s \n" "$size" "$folder_pretty"
                    lines_printed=$(($lines_printed+1))
                fi
            fi
        done
    fi
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

# ESTA FUNCAO ESTÁ MAL!!!!!!!!!!!!!!!!!
function is_regex() {
    local pattern="$1"

    # Verifica se o padrão parece ser uma expressão regular válida
    if [[ "$pattern" =~ ^[a-zA-Z0-9.*?]+$ ]]; then
        return 0
    else
        return 1
    fi
}

function is_number() {
    local re='^[1-9][0-9]*$'
    if [[ $1 =~ $re ]]; then
        return 0  # Success (true)
    else
        return 1  # Failure (false)
    fi
}

for dir in "$@"; do
    if [ -d "$dir" ]; then
        target_directory="$dir"
    fi
done

extras_podres=()

while getopts "n:d:s:l:ra" opt; do
    case $opt in
        n)
            regex="$OPTARG"
            if is_regex "$regex"; then
                na=1
                nc=0
            else
                echo -e "Missing or invalid regular expression argument for -n option\n Argument must be a valid regular expression"
                exit 1
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
            if is_number "$minsize"; then
                sa=1
                sc=0
            else
                echo -e "Missing or invalid size argument for -s option\n Argument must be a positive integer"
                exit 1
            fi
            
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
            n_lines="$OPTARG"
            if is_number "$n_lines"; then
                max="$n_lines"
            else
                echo -e "Missing or invalid number of lines argument for -l option\n Argument must be a positive integer"
                exit 1
            fi
            ;;
        \?)
            echo "Deu merda mano"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
for arg in "$@"; do
    extras_podres+=("$arg")
done

if [ ${#extras_podres[@]} -gt 1 ]; then
    echo "Invalid argument(s): ${extras_podres[@]}"
    exit 1
fi

table_header_print $@

name_filter "$target_directory" "$regex"
size_filter "$target_directory" "$minsize"
date_filter "$target_directory" "$lDate"
no_argument "$target_directory"

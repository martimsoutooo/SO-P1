function spacecheck() {
    padrao=""
    sum="0"
    for ((i=1; i<=$#; i++)); do
        case "${!i}" in
            "-n")
                # Acesse o próximo argumento usando $((i+1))
                padrao="${!((i+1))}"
                if [ -n "$padrao" ]; then
                    for folder in $@; do 
                        if [-d folder]; then 
                        find $folder -name "$padrao" | du -b "$folder"
                    done
                fi
                i=$((i+1)) # Avance para o próximo argumento
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
                ;;
            "-l")
                # número de linhas que o utilizador quer na tabela
                ;;
            *)
                echo "Opção Desconhecida: ${!i}"
                ;;
        esac
    done

    return 0
}

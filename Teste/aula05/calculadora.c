#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[])
{
    if(argc != 4){
        printf("%s","Argumentos errados Ó BÓI");
        return EXIT_FAILURE;

    }

    double primeiro = atof(argv[1]);
    double segundo = atof(argv[3]);
    if (argv[2][0] == '+'){
        printf("%f + %f = %f", segundo, primeiro, segundo+primeiro);
    }
    else if (argv[2][0] == '-'){
        printf("%f - %f = %f", segundo, primeiro, segundo-primeiro);

    }
    else if(argv[2][0] == 'x'){
        printf("%f * %f = %f", segundo, primeiro, segundo*primeiro);
    }
    else if(argv[2][0] == '/'){
        if(segundo != 0){
            printf("%f / %f= %f", segundo, primeiro, segundo/primeiro);
        }
        else{
            printf("Division by zero is not allowed.\n");
            return EXIT_FAILURE;
        }
    }
    else if(argv[2][0] == 'p'){
        printf("%lf ^ %lf = %lf", segundo, primeiro, pow(segundo,primeiro));
    }
    else{
        printf("%c is a shit operator", argv[2][0]);
    }

    return EXIT_SUCCESS;
}
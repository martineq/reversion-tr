#//include <unistd.h>		PARA QUE SIRVE ESTO???
#include <stdio.h>

extern void myputchar(char);
extern char mygetchar();

int main(int argc, char** argv){
/*
    myputchar('C'); //esto ya anda, imprime C,D,E,F una abajo de la otra    
    myputchar('D');
    myputchar('E');
    myputchar('F'); 
    myputchar('\n');
*/

    char caracter;
    while ((caracter=mygetchar())!=EOF)
	myputchar(caracter);

    return 0;
    }

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> //Para el getopt
#include <ctype.h> //Para el getopt
#include <getopt.h>

void imprimirMensajeDeAyudaSegunEntrada(){
		printf("Usage:\n\ttp0 -h\n\ttp0 -V\n\ttp0 [options] string1 string2\n\ttp0 [options] string1\nOptions:\n\t-V, --version\tPrint version and quit.\n\t-h, --help\tPrint this information and quit.\n\t-d, --delete\tDelete characters in string1\n\t-s, --squeeze\tSqueeze characters in input.\n");
	}

void cargaParametros(int argc,char** argv,char** str1,char** str2,int* v,int* h,int* d,int* s,int* tra){

static int ver,hlp,del,squ;
       int c; //Variable para uso interno del getopt_long
       while (1)
         {
           static struct option long_options[] =    //Variable para uso interno del getopt_long
             {
               /* These options set a flag. */
               {"version", no_argument, &ver, 1},
               {"help",   no_argument, &hlp, 1},
               {"delete",  no_argument, &del, 1},
               {"squeeze", no_argument, &squ, 1},
               {0, 0, 0, 0}
             };
           int option_index = 0;

           c = getopt_long (argc, argv, "Vhds",
                            long_options, &option_index);

           if (c == -1)
             break;

           switch (c)
             {
             case 0:
               // Si esta opción setea un flag acá no se hace nada.
               // En nuestro caso todas las opciones setean flag, así que no hago nada
                break;

             case 'V':
               ver=1;
               break;

             case 'h':
               hlp=1;
               break;

             case 'd':
               del=1;
               break;

             case 's':
               squ=1;
               break;

            case '?':
              /* getopt_long ya imprime mensaje de error automáticamente. */
               fprintf(stderr,"Parámetro inválido\nPruebe '--help' para obtener más información.\n");
               abort ();
               break;

             default:
               abort ();
             }
         }

        if (optind < argc){
           int i=1;
           while (optind < argc){
             if ( i==1 ){
             (*str1) = (argv[optind]);
             optind++;
             }else{
                if ( i==2 ){
                (*str2)=(argv[optind]);
                optind++;
                }else{
                    fprintf(stderr,"Parámetro '%s' inválido, no procesado\n", argv[optind++]);
                }
             }
            i++;
           }
         }

        // Caso: argumentos incompatibles
        if( hlp==1 &&  ver==1 ){
        	fprintf(stderr,"Operandos incompatibles. Los argumentos de ayuda y versión se emplean sólos.\nPruebe '--help' para obtener más información.\n");
        	abort();
        }

        // Caso: argumentos incompatibles
        if( (hlp==1) && ( del==1 || squ ==1 || (*str1)!=NULL || (*str2)!=NULL) ){
            fprintf(stderr,"Operandos incompatibles. El argumento de ayuda se emplea sólo.\nPruebe '--help' para obtener más información.\n");
            abort();
        }

        // Caso: argumentos incompatibles
        if( (ver==1) && ( del==1 || squ ==1 || (*str1)!=NULL || (*str2)!=NULL) ){
        	fprintf(stderr,"Operandos incompatibles. El argumento de version se emplea sólo.\nPruebe '--help' para obtener más información.\n");
        	abort();
        }

        if ((hlp==0) && (ver==0)){

        	// Caso: sin argumentos
        	if( (*str1)==NULL && (*str2)==NULL){
        		fprintf(stderr,"Falta un operando\nPruebe '--help' para obtener más información.\n");
        		abort();
        	}

        	// Caso: con un argumento
        	if( (*str1)!=NULL && (*str2)==NULL ){
        		if( (del==1 && squ==1) || (del==0 && squ==0 ) ){
        			fprintf (stderr,"Falta un operando\nPruebe '--help' para obtener más información.\n");
        			abort();
        		}
        	}

        	// Caso: con los dos argumentos
        	if( (*str1)!=NULL && (*str2)!=NULL ){
        		if( del==1 && squ==0 ){
        			fprintf (stderr,"Operando extra '%s'\nPruebe '--help' para obtener más información.\n",(*str2));
        			abort();
        		}
        	}
        }

    	// traducir elementos
    	if((*str1)!=NULL && (*str2)!=NULL)
    		*tra = 1;
    	else
    		*tra = 0;

    *v=ver;
    *h=hlp;
    *d=del;
    *s=squ;
}

void extenderString(char* string2,int longitud_string){
		int longitud = longitud_string;
    	int j = strlen(string2);
    	char caracter = *(string2+j-1);
    	while( j < longitud )
    		*(string2+(j++)) = caracter;
    	*(string2+j)='\0';
}

void squeezeArgumento(char* string1,char* string2){

    int indiceA,indiceB,indiceC;
    int posicionPivote;
    int posicionReescritura;
    int caracterRepetido;
    char pivote;

    posicionReescritura = 0;
    for(indiceA=0;indiceA<strlen(string1);indiceA++){

        pivote = *(string1+indiceA);

        caracterRepetido = 0;
        indiceC=0;
        //busca si el caracter pivote ya había salido
        while(indiceC < indiceA){
        	if (pivote == *(string1+indiceC))
        		caracterRepetido=1;
        	indiceC++;
        }

        if (caracterRepetido == 0){
        	posicionPivote = indiceA;
            //busca la última posición del caracter leído
            for( indiceB=indiceA+1 ; indiceB<strlen(string1) ; indiceB++ ){
                    if (pivote == *(string1+indiceB)){
                            posicionPivote = indiceB;
                    }
            }
            *(string1+posicionReescritura)=*(string1+posicionPivote);
            *(string2+posicionReescritura)=*(string2+posicionPivote);
            posicionReescritura++;
        }
    }
    *(string1+posicionReescritura)='\0';
    *(string2+posicionReescritura)='\0';
}

void prepararStrings(char* string1,char* string2,int *long_string1,int *long_string2){
	if (*long_string2 < *long_string1)
		extenderString(string2,*long_string1);

	*long_string1 = strlen(string1);
	*long_string2 = strlen(string2);

	squeezeArgumento(string1,string2);
}

int main(int argc,char** argv){

    ///Las variables que guardan datos provenientes de los parámetros son solo seis
    int ver,hlp,del,squ,tra; // Son los 4 posibles flags: 0-> Falso ; 1-> Verdadero
    char* string1 = NULL;
    char* string2 = NULL;

    /// Esta función se encarga se setear todos los flags, los str (si existen)
    /// y además valida todos los casos (de parámetros) que no sean válidos.
    /// Contempla los 4 casos cortos y los 4 casos largos
    /// Toma como máximo 2 strings (los 2 primeros que encuentre), si no hay strings o hay solo uno, envia error y termina el programa,
    /// y si (por error del usuario) existieran mas, los ignora advirtiendo que no serán procesados
    cargaParametros(argc,argv,&string1,&string2,&ver,&hlp,&del,&squ,&tra);

    //Con estas líneas pueden ver los resultados del proceso de carga de parámetros y a partir de aquí empieza la lógica del programa
    // SOLO PARA VERIFICACIÓN >>> AL FINAL HAY QUE BORRARLAS
    printf ("Parámetros validados.\nResultados del proceso:\nVflag = %d, hflag = %d, dflag = %d, sflag = %d\n",ver,hlp,del,squ);
    printf ("str1: [%s]\n", string1);
    printf ("str2: [%s]\n", string2);

	//Si pidió ayuda, la muestro y salgo del programa. No hace falta nada mas.
    if(hlp){
        imprimirMensajeDeAyudaSegunEntrada();
    }

    //Si pidió información sobre la versión, la muestro y salgo del programa. No hace falta nada mas.
    if(ver){
        printf("Versión 0.2\n");
    }

    if (hlp==0 && ver==0){
    printf("\n\n >> Comienzo de traducción\n\n");

    char	entrada;
    char 	caracterAnterior='\0';
    int		habilitarSalida;
    int		traducir = 0;

    int long_string1 = 0;
    int long_string2 = 0;

    if(string1 != NULL)
    	long_string1 = strlen(string1);

    if(string2 != NULL)
    	long_string2 = strlen(string2);

    if (tra==1 && !(del==1 && squ==1)){
    	traducir = 1;

    	char* auxString1 = malloc(sizeof(char)*long_string1);
    	string1 = strcpy(auxString1,string1);

    	char *auxString2 = malloc(sizeof(char)*long_string1);
    	string2 = strcpy(auxString2,string2);

    	prepararStrings(string1,string2,&long_string1,&long_string2);
    }


    while( ( entrada=getchar() )!= EOF ){

    	int j;
    	habilitarSalida = 1;

        /// Acá empieza toda la lógica del programa, tomando los caracteres del stdin
        // Básicamente tiene que procesar el stdin, tomando en cuenta los flags "del" (para el delete) y "squ" (para el squeeze)
        // Ahora debemos tomar de a UN SOLO CARACTER del stdin
        // y como mucho guardarnos el caracter anterior en una variable aux, para procesar lo pedido.
        if( (del==1) && (squ==1)){			//squeeze y delete

        	//borrar entradas
    		j = 0;
        	while( j<long_string1 ){
        		if( entrada == *(string1+j) ){
        			habilitarSalida = 0;
        			j = long_string1+1;
        		}
        		j++;
        	}

        	int p = 0;
    		while( p<long_string2 ){
    			if( entrada == *(string2+p) )
    				if( caracterAnterior == *(string2+p) ){
    					habilitarSalida = 0;
    					p = long_string2+1;
    				}
    			p++;
    		}
    		caracterAnterior = entrada;
        }

        if (tra==1 && !(del==1 && squ==1)){
        	j = 0;
        	while(j<long_string1){
        		if(entrada == *(string1+j)){
        			entrada =*(string2+j);
        			j = long_string1+1;
        		}
        		j++;
        	}
        }

    	if( (del==1) && (squ==0) ){
    		j = 0;
    		while(j<long_string1){
    			if(entrada == *(string1+j)){
    				habilitarSalida = 0;
    				j = long_string1+1;
    			}
    			j++;
    		}

    	}

    	if( (del==0) && (squ==1) ){
    		char* stringAUX;

    		if ( traducir == 0 )
    			stringAUX = string1;
    		else
    			stringAUX = string2;

    		j = 0;
    		while(j<long_string1){
    			if(entrada == *(stringAUX+j))
    				if( caracterAnterior == *(stringAUX+j)){
    					j = long_string1+1;
    					habilitarSalida = 0;
    				}
    			j++;
    		}
    		caracterAnterior = entrada;
    	}

		if(habilitarSalida == 1)
			putchar(entrada);
    }

    if(tra==1 && !(squ==1 && del==1)){
    	free(string1);
    	free(string2);
    }

    }

    printf("\n\n%s","*******  FIN  *******");
    return 0;
}

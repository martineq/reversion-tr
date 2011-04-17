#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> //Para el getopt
#include <ctype.h> //Para el getopt
#include <getopt.h>

int contarCaracteres(char* entrada,char caracteresBuscados){
	int contador = 0;
	int w;
	for(w=0;w<strlen(entrada);w++)
		if(entrada[w]==caracteresBuscados)
			contador++;
	return contador;
    }

char* borrarCaracteres(char* entrada,char caracterAborrar,int squeeze){

	int cont = contarCaracteres(entrada,caracterAborrar);
	char* salida = malloc(sizeof(char) * ( (strlen(entrada) - cont) + 1 )); //sumo 1 para guardar '\0'
	int w;
    int b = 0;
    for(w=0; w < strlen(entrada) ; w++){
    	if(entrada[w]!=caracterAborrar){
    		salida[b++]=entrada[w];
    	}else if (squeeze == 1){
    		if (w==0 || (w>0 && entrada[w-1]!=caracterAborrar ))
    			salida[b++]=entrada[w];
    	}
	}
    salida[b]='\0';
	return salida;
}

//devuelve el caracter despues del reemplazo.
char* reemplazarCaracteres(char* entrada,char caracterAreemplazar,char reemplazo){
	int w;
	char* entradaReemplazada = malloc(sizeof(char) * ( (strlen(entrada) + 1 )));
	for(w=0; w < strlen(entrada); w++){
		if (entrada[w] == caracterAreemplazar)
			entradaReemplazada[w]=reemplazo;
		if (entrada[w] != caracterAreemplazar)
			entradaReemplazada[w] = entrada[w];
	}
        entradaReemplazada[strlen(entrada)]='\0';
		return entradaReemplazada;
}

void imprimirMensajeDeAyudaSegunEntrada(){
		printf("Usage:\n\ttp0 -h\n\ttp0 -V\n\ttp0 [options] string1 string2\n\ttp0 [options] string1\nOptions:\n\t-V, --version\tPrint version and quit.\n\t-h, --help\tPrint this information and quit.\n\t-d, --delete\tDelete characters in string1\n\t-s, --squeeze\tSqueeze characters in input.\n");
	}

void procesarErrores(int error, char** msgerr){
	  if (error!=0) {  //Chequea si existen errores
        switch ( error ) {
            case 1:
                *msgerr="Error de parámetro\n";
                break;
            case 2:
                *msgerr="Error de lectura de entrada\n";
                break;
            case 3:
                *msgerr="Error en función 'squeeze' y 'delete', se necesitan dos operandos\n";
                break;
            case 4:
                *msgerr="Error en función 'delete', sólo se admite un operando\n";
                break;
            default:
                break;
         }
	fwrite(*msgerr, sizeof(char),strlen(*msgerr),stderr);//Si existió algún error, sale el mensaje por stderr
    }
	  //else
    	//fwrite(, sizeof(char),strlen(str1.dato),stdout);
}

void cargaParametros(int argc,char** argv,char** str1,char** str2,int* v,int* h,int* d,int* s){

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

    if ( (hlp==0 && ver==0) ){  //Cuando no pide ni ayuda ni versión, valido los strings

        // Caso: sin argumentos
        if( (*str1)==NULL && (*str2)==NULL ){
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

    *v=ver;
    *h=hlp;
    *d=del;
    *s=squ;
}

int main(int argc,char** argv){

    ///Las variables que guardan datos provenientes de los parámetros son solo seis
    int ver,hlp,del,squ; // Son los 4 posibles flags: 0-> Falso ; 1-> Verdadero
    char* string1 = NULL;
    char* string2 = NULL;

    /// Esta función se encarga se setear todos los flags, los str (si existen)
    /// y además valida todos los casos (de parámetros) que no sean válidos.
    /// Contempla los 4 casos cortos y los 4 casos largos
    /// Toma como máximo 2 strings (los 2 primeros que encuentre), si no hay strings o hay solo uno, envia error y termina el programa,
    /// y si (por error del usuario) existieran mas, los ignora advirtiendo que no serán procesados
    cargaParametros(argc,argv,&string1,&string2,&ver,&hlp,&del,&squ);

    //Con estas líneas pueden ver los resultados del proceso de carga de parámetros y a partir de aquí empieza la lógica del programa
    // SOLO PARA VERIFICACIÓN >>> AL FINAL HAY QUE BORRARLAS
    printf ("Parámetros validados.\nResultados del proceso:\nVflag = %d, hflag = %d, dflag = %d, sflag = %d\n",ver,hlp,del,squ);
    printf ("str1: [%s]\n", string1);
    printf ("str2: [%s]\n", string2);

    printf("\n\n >> Comienzo de traducción\n\n");

    char* entradaVECTOR="holaaa mundo!";
    char entrada;
    int w;
    char caracterAnterior='\0';
    int long_string1;
    int long_string2;
    if(string1 == NULL)
    	long_string1 = 0;
    else
    	long_string1 = strlen(string1);

    if(string2 == NULL)
    	long_string2 = 0;
    else
    	long_string2 = strlen(string2);

	int long_entradaVECTOR = strlen(entradaVECTOR);
    for (w=0;w<long_entradaVECTOR;w++){

    	entrada = entradaVECTOR[w];
    	int j;

    	//Si pidió ayuda, la muestro y salgo del programa. No hace falta nada mas.
        if(hlp){
            imprimirMensajeDeAyudaSegunEntrada();
        }

        //Si pidió información sobre la versión, la muestro y salgo del programa. No hace falta nada mas.
        if(ver){
            printf("Versión 0.2\n");
        }

        /// Acá empieza toda la lógica del programa, tomando los caracteres del stdin
        // Básicamente tiene que procesar el stdin, tomando en cuenta los flags "del" (para el delete) y "squ" (para el squeeze)
        // Ahora debemos tomar de a UN SOLO CARACTER del stdin
        // y como mucho guardarnos el caracter anterior en una variable aux, para procesar lo pedido.

        if( (del==1) && (squ==1)){			//squeeze y delete
    		j = 0;
        	while( j<long_string1 ){
        		if( entrada == *(string1+j) )
        			j = long_string1+1;
        		j++;
        	}

        	int p = 0;
    		while( p<long_string2 ){
    			if( entrada == *(string2+p) )
    				if( caracterAnterior == *(string2+p) )
    					p = long_string2+1;
    			p++;
    		}
    		caracterAnterior = entrada;

    		if( j == long_string1 && p == long_string2)
        		putchar(entrada);
        }

        if (string1!=NULL && string2!=NULL && !(del==1 && squ==1)){				//inicia la traducción

        	//antes hay que extender el string2 al tamaño del string1
        	j = 0;
        	while(j<long_string1){
        		if(entrada == *(string1+j)){
        			putchar(*(string2+j));
        			j = long_string1+1;
        		}
        		j++;
        	}

        	if( j == long_string1 )
        		putchar(entrada);
        }

    	if( (del==1) && (squ==0) ){
    		j = 0;
    		while(j<long_string1){
    			if(entrada == *(string1+j)){
    				j = long_string1+1;
    			}
    			j++;
    		}
    		if( j == long_string1 )
    			putchar(entrada);
    	}

    	if( (del==0) && (squ==1)){
    		j = 0;
    		while(j<long_string1){
    			if(entrada == *(string1+j))
    				if( caracterAnterior == *(string1+j))
    					j = long_string1+1;
    			j++;
    		}
    		caracterAnterior = entrada;

    		if( j == long_string1 )
    			putchar(entrada);
    	}
    }

    printf("\n\n%s","*******  FIN  *******");
    return 0;
}

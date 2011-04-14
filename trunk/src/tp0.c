#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAMANIO_BUFFER 3

typedef struct cadena{
       char* dato;
       int V,H,S,D,err;

}tCadena;

int main(int argc,char** argv){

    tCadena str1;

    char* string1 = NULL; //para guardar la primera entrada pasada por parametro.
    char* string2 = NULL; //para guardar la segunda entrada pasada por parametro.

    char* msgerr;

    //indicadores de las entradas validas
    char* flag[] = {"-V","--version","-h","--help","-s","--squeeze","--delete","-d","-sd","-ds"};

	//para ver los mensajes de ayuda/version
	if ((argv[1][0] == '-') && (argv[1][1] == 'h')){
		imprimirMensajeDeAyudaSegunEntrada();
		return 0;
	}
	if ((argv[1][0] == '-') && (argv[1][1] == 'V')){
		printf("Versión 0.0000001\n");
		return 0;
	}
    str1.dato = leerEntrada();

    guardarEntradas(argc, argv, &string1, &string2);

    // Inicialar flags
    str1.V=str1.H=str1.S=str1.D=str1.err=0;
    definirFlagsSegunEntradas(argc, argv, flag, &str1);
    procesarEntradas(string1, string2, &str1);

    procesarErrores(str1, &msgerr);

    free(str1.dato);
    return 0;
}

char* leerEntrada(){
	char* aux;
	char* str1dato;
	int fin = 0;
	int objetosleidos = 0;
	int tamanio = TAMANIO_BUFFER;

	str1dato=malloc(sizeof(char)*tamanio);
	aux = malloc(sizeof(char)*tamanio);

	while(!fin){

		objetosleidos=fread(aux,sizeof(char),TAMANIO_BUFFER,stdin);
		aux[objetosleidos]='\0';

		if (TAMANIO_BUFFER > objetosleidos)
			fin = !fin;
		else
			tamanio += TAMANIO_BUFFER;

		str1dato = realloc(str1dato,tamanio);
		strcat(str1dato,aux);
	}

	free(aux);
	return str1dato;
}

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

// Extiende la longitud del string2 a la del string1 copiando el último caracter.
void traducir(char** dato,char* string1,char* string2){
	char* aux=string2;
	if( strlen(string1) > strlen(string2) ){
		aux = malloc(sizeof(char)*strlen(string1));
		int l;
		for(l=0 ; l<strlen(string2) ; l++)
			*(aux+l)=*(string2+l);
		int f;
		for(f=l ; f<strlen(string1) ; f++)
			*(aux+f)=*(string2+l-1);
		*(aux+strlen(string1))='\0';
	}

	char* aTraducir = malloc(sizeof(char)*strlen(string1));
	char* traductores = malloc(sizeof(char)*strlen(aux));

	*aTraducir= '\0';
	*traductores = '\0';

	int a;
	int b;
	int c;
	int posicionNueva;
	int caracterRepetido;
	int posicionChar;
	char caracterAuxiliar;

	posicionNueva = 0;
	for(a=0;a<strlen(string1);a++){
		posicionChar = a;
		caracterAuxiliar = *(string1+a);

		//verifica si ya salió anteriormente
		caracterRepetido=0;
		c=0;
		while(c<a && caracterRepetido==0){
			if (caracterAuxiliar == *(aTraducir+c))
				caracterRepetido=1;
			c++;
		}

		if (caracterRepetido == 0){
		//busca la última posición del caracter leído
		for(b=a+1;b<strlen(string1);b++){
			if (caracterAuxiliar == *(string1+b)){
				posicionChar = b;
			}
		}

		*(aTraducir+posicionNueva)=caracterAuxiliar;
		*(traductores+posicionNueva)=*(aux+posicionChar);
		posicionNueva+=1;
		*(aTraducir+posicionNueva)='\0';
		*(traductores+posicionNueva)='\0';


		}
	}

	int index;
	for (index = 0; index < strlen(aTraducir);index++ ){
		*dato = reemplazarCaracteres(*dato,*(aTraducir+index),*(traductores+index));
}
	free(aTraducir);
	free(traductores);
	if (strlen(aux)!=strlen(string2))
		free(aux);
}

//crea dos punteros a los string de las entradas pasadas por parametro
void guardarEntradas(int argc, char** argv, char** string1, char** string2){
	int p = 1;
    while (p < argc){
    	if ( *argv[p] != '-' ){
    		if (*string1 == NULL) *string1 = argv[p];
    		else if (*string2 == NULL) *string2 = argv[p];
    	}
    	p++;
    }
 }

void definirFlagsSegunEntradas(int argc, char** argv, char** flag, tCadena* str1){
    int i;
    //bandera: para salir de los ciclos, suponiendo que el formato estandar
    //que se tiene que leer de linea de comando es del estilo:
    // tp0 [options] string1 string2. mejora un poco la eficiencia
    int bandera = 0;
    for (i=1;i<argc && (bandera!=1);i++){
        int j;
        for (j=0;j<10 && (bandera!=1);j++){
            if ( strcmp(argv[i],flag[j])==0 )
            switch ( j ) {
                case 0:
                case 1:
						(*str1).V=1;
						bandera = 1;
						break;
                case 2:
                case 3:
						(*str1).H=1;
						bandera = 1;
						break;
                case 4:
                case 5:
						(*str1).S=1;
						bandera = 1;
						break;

                case 6:
                case 7:
						(*str1).D=1;
						bandera = 1;
						break;
                case 8:
                case 9:
						(*str1).S=1;
						(*str1).D=1;
						bandera = 1;
						break;
                default:
						(*str1).err=1;
						bandera = 1;
						break;
                }
        }
    }
}

void imprimirMensajeDeAyudaSegunEntrada(){
		printf("Usage:\n\ttp0 -h\n\ttp0 -V\n\ttp0 [options] string1 string2\n\ttp0 [options] string1\nOptions:\n\t-V, --version\tPrint version and quit.\n\t-h, --help\tPrint this information and quit.\n\t-d, --delete\tDelete characters in string1\n\t-s, --squeeze\tSqueeze characters in input.\n");
	}

void procesarEntradas(char* string1, char* string2, tCadena* str1){
	int r;
	if ( (*str1).D==1){

    	for (r = 0 ; r < strlen(string1) ; r++ )
    	 	(*str1).dato = borrarCaracteres((*str1).dato,*(string1+r),0);

       	if ((*str1).S==1){
        		if (string2!=NULL){
            		for (r = 0; r < strlen(string2);r++ )
            			(*str1).dato = borrarCaracteres((*str1).dato,*(string2+r),1);
    	        	}else{
    	        		(*str1).err=3;
    	        	}
    	    }else if (string2!=NULL){
    	       	(*str1).err=4;
    	}
    }else if ( (*str1).S==1 ){
    	if (string2==NULL){
    		int r;
    		for (r = 0; r < strlen(string1);r++ )
    			(*str1).dato = borrarCaracteres((*str1).dato,*(string1+r),1);
    	}else{
    		traducir(&((*str1).dato),string1,string2);
     		int r;
     		for (r = 0; r < strlen(string2);r++ )
    		   	(*str1).dato = borrarCaracteres((*str1).dato,*(string2+r),1);
    	}
    }else if (string1!=NULL && string2!=NULL){
    	traducir(&((*str1).dato),string1,string2);
		for (r = 0; r < strlen(string1);r++ )
		    reemplazarCaracteres((*str1).dato,*(string1+r),*(string2+r));
	}
}

void procesarErrores(tCadena str1, char** msgerr){
	  if (str1.err!=0) {  //Chequea si existen errores
        switch ( str1.err ) {
            case 1:
                *msgerr="Error de parámetro\n";
                break;
            case 2:
                *msgerr="Error de lectura de entrada\n";
                break;
            case 3:
                *msgerr="Error squeezzing and deleting, se necesitan dos strings\n";
                break;
            case 4:
                *msgerr="Error en deleting, sólo se admite un string\n";
                break;
            default:
                break;
         }
	fwrite(*msgerr, sizeof(char),strlen(*msgerr),stderr);//Si existió algún error, sale el mensaje por stderr
    }else
    	fwrite(str1.dato, sizeof(char),strlen(str1.dato),stdout);
}

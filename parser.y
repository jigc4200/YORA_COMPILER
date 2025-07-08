%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Declaraciones de archivos globales
FILE *html_output_file;
FILE *listado_file;

// Declaraciones de funciones y variables externas del lexer (Flex)
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yylineno; // Para reportar el número de línea en errores
extern int columna; // Asegúrate de que esta variable sea global en tu lexer también

void yyerror(const char *s); // Declaración de la función de manejo de errores

%}

// Definición de la unión para los valores semánticos de los tokens
%union {
    char *str; // Para tokens que transportan cadenas de texto (TEXTO, CARACTER_ESPECIAL, y las reglas %type)
}

// Declaración de tokens (terminales)
// Los tokens <str> llevan un valor de cadena
%token <str> TEXTO CARACTER_ESPECIAL
%token CABECERA FINCABECERA TITULO FINTITULO
%token PARRAFO FINPARRAFO NEGRITA FINNEGRITA
%token CURSIVA FINCURSIVA
%token LISTA FINLISTA ITEM FINITEM
%token ENLACE FINENLACE
%token PIEPAGINA FINPIEPAGINA

// Regla inicial de la gramática
%start documento

// Declaración de tipos para los no-terminales que devuelven un valor de cadena
%type <str> titulo
%type <str> contenido
%type <str> fragmento
%type <str> items

%% // Inicio de la sección de reglas gramaticales

// Reglas gramaticales

documento
    : cabecera cuerpo pie_pagina
        {
            // Las etiquetas </body> y </html> se imprimen en main() para evitar duplicación.
            // Esta acción ahora está vacía, solo indica que la estructura del documento es correcta.
        }
    ;

cabecera
    : CABECERA titulo FINCABECERA
        {
            fprintf(html_output_file, "<header>\n");
            fprintf(html_output_file, "%s", $2); // $2 es el valor semántico de 'titulo'
            fprintf(html_output_file, "</header>\n");
            free($2); // Liberar la memoria asignada para el título
        }
    ;

titulo
    : TITULO contenido FINTITULO
        {
            // Asignamos un tamaño de buffer suficiente para la etiqueta <h1> y el contenido
            char *buf = malloc(strlen($2) + 32); // +32 para "<h1>", "</h1>\n" y margen
            if (buf == NULL) { // Verificación de error de malloc
                perror("Error de asignación de memoria para titulo");
                exit(EXIT_FAILURE);
            }
            sprintf(buf, "<h1>%s</h1>\n", $2);
            $$ = buf; // El valor semántico de 'titulo' es la cadena HTML generada
            free($2); // Liberar la memoria del 'contenido' original
        }
    ;

cuerpo
    : /* vacío */ // Un cuerpo puede estar vacío
    | cuerpo elemento // Un cuerpo puede contener múltiples elementos
    ;

elemento
    : parrafo
    | negrita
    | cursiva
    | lista
    | enlace
    ;

parrafo
    : PARRAFO contenido FINPARRAFO
        {
            fprintf(html_output_file, "<p>%s</p>\n", $2);
            free($2); // Liberar la memoria del 'contenido'
        }
    ;

negrita
    : NEGRITA contenido FINNEGRITA
        {
            fprintf(html_output_file, "<b>%s</b>\n", $2);
            free($2); // Liberar la memoria del 'contenido'
        }
    ;

cursiva
    : CURSIVA contenido FINCURSIVA
        {
            fprintf(html_output_file, "<i>%s</i>\n", $2);
            free($2); // Liberar la memoria del 'contenido'
        }
    ;

enlace
    : ENLACE contenido FINENLACE
        {
            // Para simplificar, el href se fija a "#". En un parser más complejo, el href podría ser otro token.
            fprintf(html_output_file, "<a href=\"#\">%s</a>\n", $2);
            free($2); // Liberar la memoria del 'contenido'
        }
    ;

lista
    : LISTA items FINLISTA
        {
            fprintf(html_output_file, "<ul>\n%s</ul>\n", $2);
            free($2); // Liberar la memoria de la cadena de 'items'
        }
    ;

items
    : /* vacío */ { $$ = strdup(""); } // Inicializar con una cadena vacía para la concatenación
    | items ITEM contenido FINITEM
        {
            // Asignamos un tamaño de buffer suficiente para la concatenación
            char *buf = malloc(strlen($1) + strlen($3) + 32); // +32 para "<li>", "</li>\n" y margen
            if (buf == NULL) { // Verificación de error de malloc
                perror("Error de asignación de memoria para items");
                exit(EXIT_FAILURE);
            }
            sprintf(buf, "%s<li>%s</li>\n", $1, $3);
            $$ = buf;
            free($1); // Liberar la memoria del 'items' anterior
            free($3); // Liberar la memoria del 'contenido' del item actual
        }
    ;

pie_pagina
    : PIEPAGINA contenido FINPIEPAGINA
        {
            fprintf(html_output_file, "<footer>%s</footer>\n", $2);
            free($2); // Liberar la memoria del 'contenido'
        }
    ;

contenido // Regla para concatenar fragmentos de texto (TEXTO, CARACTER_ESPECIAL)
    : fragmento
        { $$ = $1; } // El contenido es simplemente el fragmento
    | contenido fragmento
        {
            // --- MODIFICACIÓN PARA AÑADIR ESPACIOS ---
            // Calcular el tamaño necesario: longitud de $1 + longitud de $2 + 1 (para el espacio) + 1 (para \0)
            char *buf = malloc(strlen($1) + strlen($2) + 2);
            if (buf == NULL) {
                perror("Error de asignación de memoria para contenido (con espacio)");
                exit(EXIT_FAILURE);
            }
            strcpy(buf, $1);
            strcat(buf, " "); // ¡Aquí se añade el espacio!
            strcat(buf, $2);
            $$ = buf;
            free($1); // Liberar el contenido previo
            free($2); // Liberar el fragmento que se acaba de añadir
        }
    ;

fragmento // Los fragmentos son los elementos más básicos del texto
    : TEXTO
        { $$ = $1; } // El lexer ya hizo strdup, simplemente pasamos el puntero.
                     // La memoria de $1 (que viene del yytext del lexer) se libera aquí
                     // para que no se duplique al concatenar en 'contenido' o directamente en otras reglas.
                     // ¡Es crucial que el lexer haga strdup y que se libere una vez usada!
    | CARACTER_ESPECIAL
        { $$ = $1; } // Igual que TEXTO.
    ;

%% // Fin de la sección de reglas gramaticales

// Función de manejo de errores de sintaxis
void yyerror(const char *s) {
    // Si 'columna' no es externa, no se podrá acceder aquí. Asegúrate de su ámbito.
    fprintf(stderr, "Error de sintaxis en línea %d, columna %d: %s\n", yylineno, columna, s);
}

// Función principal del programa
int main(int argc, char *argv[]) {
    // Verificación de argumentos de línea de comandos
    if (argc != 4 || strcmp(argv[2], "-o") != 0) {
        fprintf(stderr, "Uso: %s archivo_entrada.L5 -o archivo_salida.html\n", argv[0]);
        return 1;
    }

    // --- Apertura de archivos ---

    // Abrir archivo de entrada L5
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error abriendo archivo de entrada");
        return 1;
    }

    // Abrir archivo de salida HTML
    html_output_file = fopen(argv[3], "w");
    if (!html_output_file) {
        perror("Error abriendo archivo de salida HTML");
        fclose(yyin); // Cerrar el archivo de entrada antes de salir
        return 1;
    }

    // Abrir listado.txt para el log de tokens (usado por el lexer)
    listado_file = fopen("listado.txt", "w");
    if (!listado_file) {
        perror("Error abriendo listado.txt");
        fclose(yyin);
        fclose(html_output_file); // Cerrar archivos previos
        return 1;
    }

    // --- Inicio de la generación HTML ---

    // Escribir la estructura básica HTML inicial
    fprintf(html_output_file, "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"UTF-8\">\n<title>Documento L5</title>\n</head>\n<body>\n");

    // --- Llamada al analizador sintáctico (parser) ---
    int res = yyparse();

    // --- Finalización de la generación HTML ---

    // Finalizar la estructura HTML (solo se imprime aquí)
    fprintf(html_output_file, "</body>\n</html>\n");

    // --- Cierre de archivos ---
    fclose(yyin);
    fclose(html_output_file);
    fclose(listado_file);

    // --- Mensaje final ---
    if (res == 0) {
        printf("Archivo HTML generado correctamente en '%s'.\n", argv[3]);
    } else {
        printf("Se encontraron errores de sintaxis durante el análisis.\n");
    }

    return res;
}
%{
#include "parser.tab.h" // Asume que este archivo define tus IDs de token
#include <stdio.h>
#include <string.h>
#include <stdlib.h> // Necesario para strdup

int columna = 1;
extern int yylineno; // Flex lo proporciona automáticamente
extern FILE *listado_file; // Este puntero de archivo debe abrirse en main()

void actualizar_columna(const char *yytext) {
    columna += strlen(yytext);
}
%}

%option noyywrap
%option yylineno
%option noinput
%option nounput

%%

[ \t]+         { actualizar_columna(yytext); }
\n             { columna = 1; }

"CABECERA"     { fprintf(listado_file, "%d, %d: <CABECERA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return CABECERA; }
"FINCABECERA"  { fprintf(listado_file, "%d, %d: <FINCABECERA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINCABECERA; }
"TITULO"       { fprintf(listado_file, "%d, %d: <TITULO> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return TITULO; }
"FINTITULO"    { fprintf(listado_file, "%d, %d: <FINTITULO> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINTITULO; }
"PARRAFO"      { fprintf(listado_file, "%d, %d: <PARRAFO> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return PARRAFO; }
"FINPARRAFO"   { fprintf(listado_file, "%d, %d: <FINPARRAFO> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINPARRAFO; }
"NEGRITA"      { fprintf(listado_file, "%d, %d: <NEGRITA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return NEGRITA; }
"FINNEGRITA"   { fprintf(listado_file, "%d, %d: <FINNEGRITA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINNEGRITA; }
"CURSIVA"      { fprintf(listado_file, "%d, %d: <CURSIVA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return CURSIVA; }
"FINCURSIVA"   { fprintf(listado_file, "%d, %d: <FINCURSIVA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINCURSIVA; }
"LISTA"        { fprintf(listado_file, "%d, %d: <LISTA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return LISTA; }
"FINLISTA"     { fprintf(listado_file, "%d, %d: <FINLISTA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINLISTA; }
"ITEM"         { fprintf(listado_file, "%d, %d: <ITEM> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return ITEM; }
"FINITEM"      { fprintf(listado_file, "%d, %d: <FINITEM> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINITEM; }
"ENLACE"       { fprintf(listado_file, "%d, %d: <ENLACE> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return ENLACE; }
"FINENLACE"    { fprintf(listado_file, "%d, %d: <FINENLACE> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINENLACE; }
"PIEPAGINA"    { fprintf(listado_file, "%d, %d: <PIEPAGINA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return PIEPAGINA; }
"FINPIEPAGINA" { fprintf(listado_file, "%d, %d: <FINPIEPAGINA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return FINPIEPAGINA; }

[©®@™]         {
    fprintf(listado_file, "%d, %d: <CARACTER_ESPECIAL> '%s'\n", yylineno, columna, yytext);
    actualizar_columna(yytext);
    yylval.str = strdup(yytext);
    return CARACTER_ESPECIAL;
}


\"[^\"]*\"     {
    fprintf(listado_file, "%d, %d: <TEXTO_ENTRE_COMILLAS> '%s'\n", yylineno, columna, yytext);
    actualizar_columna(yytext);
    yylval.str = strdup(yytext + 1);
    if (yylval.str) {
        yylval.str[strlen(yylval.str) - 1] = '\0';
    }
    return TEXTO;
}


[^ \t\n\"©®@™]+ { // + significa una o más veces
    fprintf(listado_file, "%d, %d: <TEXTO_GENERAL> '%s'\n", yylineno, columna, yytext);
    actualizar_columna(yytext);
    yylval.str = strdup(yytext);
    return TEXTO;
}

.              {
    fprintf(stderr, "Error léxico en línea %d, columna %d: Caracter inesperado '%s'\n", yylineno, columna, yytext);
    columna++;
}

%%
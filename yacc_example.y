%{
#include <stdio.h>
// Declara yylex y yyerror explícitamente para evitar advertencias
extern int yylex();
extern void yyerror(const char *s);
%}

%token NUMBER

%%
start: NUMBER { printf("Entrada válida: Un número\n"); }
;

%%

// Esta es la ÚNICA función main para tu programa combinado
int main() {
    printf("Ingrese un número y presione Enter (luego Ctrl+D para finalizar):\n");
    yyparse(); // Llama al analizador sintáctico
    return 0;
}

// Tu función de error personalizada, ahora declarada explícitamente arriba
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
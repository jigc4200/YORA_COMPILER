# Documentación Detallada del Analizador Léxico (`escaner.l`)

Este documento explica en detalle el funcionamiento del archivo `escaner.l`, que es el analizador léxico del proyecto `YORA_COMPILER`. Este archivo es procesado por la herramienta Flex para generar el código fuente en C del escáner.

## 1. Introducción

El archivo `escaner.l` define las reglas para reconocer los "tokens" (unidades mínimas de significado) en el lenguaje de entrada (`.L5`). Su función principal es leer el código fuente carácter por carácter y agruparlos en estos tokens, que luego serán pasados al analizador sintáctico (parser) para su posterior procesamiento.

## 2. Sección de Definiciones (`%{ %}`)

Esta sección, delimitada por `%{` y `}%`, contiene código C que se copia directamente al archivo `lex.yy.c` generado por Flex. Aquí se incluyen cabeceras necesarias, se declaran variables globales y se definen funciones auxiliares.

*   **`#include "parser.tab.h"`**: Incluye el archivo de cabecera generado por Bison (`parser.tab.h`). Este archivo es crucial porque contiene las definiciones de los IDs numéricos para cada token que el analizador léxico debe retornar al analizador sintáctico (ej. `CABECERA`, `TITULO`, `TEXTO`, etc.).
*   **`#include <stdio.h>`**: Para funciones de entrada/salida estándar como `fprintf`.
*   **`#include <string.h>`**: Para funciones de manipulación de cadenas como `strlen` y `strdup`.
*   **`#include <stdlib.h>`**: Necesario para `strdup` (que duplica una cadena) y `exit`.
*   **`int columna = 1;`**: Una variable global que rastrea la columna actual en la línea que se está procesando. Es útil para reportar errores con mayor precisión.
*   **`extern int yylineno;`**: `yylineno` es una variable global proporcionada automáticamente por Flex que almacena el número de línea actual del archivo de entrada. Se declara como `extern` porque es definida por Flex.
*   **`extern FILE *listado_file;`**: Un puntero a un archivo global que se espera que sea abierto en la función `main()` del parser. Se utiliza para escribir un "listado" de los tokens reconocidos, incluyendo su línea, columna, tipo y valor.
*   **`void actualizar_columna(const char *yytext)`**: Una función auxiliar que incrementa la variable `columna` por la longitud del texto (`yytext`) del token recién reconocido. `yytext` es una variable global de Flex que contiene el texto del token actual.

## 3. Opciones de Flex (`%option`)

Estas directivas configuran el comportamiento del analizador léxico generado:

*   **`%option noyywrap`**: Indica a Flex que no debe llamar a la función `yywrap()` cuando llega al final del archivo de entrada. Si no se especifica, Flex espera que `yywrap()` devuelva 1 para indicar el final de la entrada o 0 para indicar que hay más entrada disponible (por ejemplo, de otro archivo). Para un solo archivo de entrada, `noyywrap` es común.
*   **`%option yylineno`**: Habilita el seguimiento automático del número de línea en la variable global `yylineno`.
*   **`%option noinput`**: Suprime la generación de la función `yyinput()`.
*   **`%option nounput`**: Suprime la generación de la función `yyunput()`.

## 4. Sección de Reglas (`%%`)

Esta es la sección principal donde se definen las reglas léxicas. Cada regla consta de una expresión regular y una acción C asociada, que se ejecuta cuando la expresión regular coincide con una parte de la entrada.

### 4.1. Manejo de Espacios y Saltos de Línea

*   **`[ \t]+ { actualizar_columna(yytext); }`**: Esta regla ignora uno o más espacios (` `) o tabulaciones (`\t`). La acción simplemente actualiza la columna, pero no retorna ningún token, lo que efectivamente los "descarta".
*   **`\n { columna = 1; }`**: Cuando se encuentra un salto de línea (`\n`), la columna se reinicia a 1. No se retorna ningún token, ya que los saltos de línea no son significativos como tokens en este lenguaje.

### 4.2. Palabras Clave (Tokens Predefinidos)

El escáner reconoce una serie de palabras clave que corresponden a etiquetas HTML o estructuras del lenguaje `.L5`. Cada vez que una de estas palabras clave es reconocida, se imprime información en `listado_file` y se retorna el ID de token correspondiente al parser.

Ejemplo de regla:
`"CABECERA" { fprintf(listado_file, "%d, %d: <CABECERA> '%s'\n", yylineno, columna, yytext); actualizar_columna(yytext); return CABECERA; }`

*   **`"CABECERA"`**: La expresión regular es la cadena literal "CABECERA".
*   **`fprintf(listado_file, ...)`**: Escribe en el archivo `listado.txt` la línea, columna, tipo de token (`<CABECERA>`) y el texto reconocido (`yytext`).
*   **`actualizar_columna(yytext);`**: Actualiza la posición de la columna.
*   **`return CABECERA;`**: Retorna el ID numérico `CABECERA` al analizador sintáctico. Este ID está definido en `parser.tab.h`.

Las palabras clave reconocidas incluyen:
*   `CABECERA`, `FINCABECERA`
*   `TITULO`, `FINTITULO`
*   `PARRAFO`, `FINPARRAFO`
*   `NEGRITA`, `FINNEGRITA`
*   `CURSIVA`, `FINCURSIVA`
*   `LISTA`, `FINLISTA`
*   `ITEM`, `FINITEM`
*   `ENLACE`, `FINENLACE`
*   `PIEPAGINA`, `FINPIEPAGINA`

### 4.3. Caracteres Especiales

*   **`[©®@™] { ... return CARACTER_ESPECIAL; }`**: Esta regla reconoce cualquiera de los caracteres especiales listados (`©`, `®`, `@`, `™`).
    *   Se imprime en `listado_file` como `<CARACTER_ESPECIAL>`.
    *   **`yylval.str = strdup(yytext);`**: Aquí, el valor semántico del token se establece. `yylval` es una unión global (definida en `parser.y`) que permite al lexer pasar datos al parser. En este caso, se duplica el texto reconocido (`yytext`) y se asigna a `yylval.str`. `strdup` es crucial porque `yytext` es un puntero a un buffer interno de Flex que puede ser sobrescrito en la siguiente llamada a `yylex()`. Al duplicarlo, se asegura que el parser reciba una copia persistente.

### 4.4. Texto (Entre Comillas y General)

El escáner distingue entre texto encerrado en comillas y texto general.

*   **`\"[^\"]*\" { ... return TEXTO; }`**: Reconoce una cadena de texto encerrada entre comillas dobles. `[^\"]*` coincide con cero o más caracteres que no sean una comilla doble.
    *   Se imprime en `listado_file` como `<TEXTO_ENTRE_COMILLAS>`.
    *   **`yylval.str = strdup(yytext + 1);`**: Duplica el texto, pero `yytext + 1` se usa para omitir la comilla inicial.
    *   **`yylval.str[strlen(yylval.str) - 1] = '\0';`**: Se sobrescribe la comilla final con un terminador nulo (`\0`) para que la cadena solo contenga el texto interno.
    *   Retorna el token `TEXTO`.

*   **`[^ \t\n\"©®@™]+ { ... return TEXTO; }`**: Esta es una regla "catch-all" para texto general. Reconoce una o más (`+`) caracteres que no sean espacios, tabulaciones, saltos de línea, comillas dobles o los caracteres especiales definidos anteriormente.
    *   Se imprime en `listado_file` como `<TEXTO_GENERAL>`.
    *   **`yylval.str = strdup(yytext);`**: Duplica el texto reconocido y lo asigna a `yylval.str`.
    *   Retorna el token `TEXTO`.

### 4.5. Manejo de Errores Léxicos

*   **`. { ... }`**: Esta es la regla de "comodín" o "fallback". El punto (`.`) coincide con cualquier carácter individual (excepto el salto de línea, a menos que se use la opción `dotall`). Si ningún otra regla coincide con el carácter actual, esta regla se activa.
    *   Se imprime un mensaje de error en `stderr` (salida de error estándar) indicando el carácter inesperado y su posición.
    *   La columna se incrementa, pero no se retorna ningún token, lo que significa que el carácter problemático es descartado.

## 5. Conclusión

`escaner.l` es el componente fundamental para la primera fase del compilador: el análisis léxico. Define con precisión cómo se deben reconocer los elementos básicos del lenguaje de entrada y cómo se deben pasar al analizador sintáctico, incluyendo la gestión de la posición en el código fuente y la transmisión de valores semánticos (cadenas de texto) asociados a los tokens.
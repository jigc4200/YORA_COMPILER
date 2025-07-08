# Documentación Detallada del Analizador Sintáctico (`parser.y`)

Este documento explica en detalle el funcionamiento del archivo `parser.y`, que es el analizador sintáctico del proyecto `YORA_COMPILER`. Este archivo es procesado por la herramienta Bison para generar el código fuente en C del parser.

## 1. Introducción

El archivo `parser.y` define la gramática del lenguaje de entrada (`.L5`) y cómo los tokens (proporcionados por el analizador léxico `escaner.l`) se combinan para formar estructuras sintácticas válidas. A medida que el parser reconoce estas estructuras, ejecuta acciones asociadas que, en este proyecto, generan el contenido HTML de salida.

## 2. Sección de Definiciones (`%{ %}`)

Esta sección, delimitada por `%{` y `}%`, contiene código C que se copia directamente al archivo `parser.tab.c` generado por Bison.

*   **Inclusiones de Cabecera:**
    *   `#include <stdio.h>`: Para funciones de entrada/salida estándar.
    *   `#include <stdlib.h>`: Para funciones de asignación de memoria (`malloc`, `free`) y salida (`exit`).
    *   `#include <string.h>`: Para funciones de manipulación de cadenas (`strlen`, `strcpy`, `strcat`, `strcmp`).
*   **Declaraciones de Archivos Globales:**
    *   `FILE *html_output_file;`: Puntero al archivo donde se escribirá la salida HTML.
    *   `FILE *listado_file;`: Puntero al archivo de listado de tokens (compartido con el lexer).
*   **Declaraciones de Funciones y Variables Externas del Lexer (Flex):**
    *   `extern int yylex();`: La función principal del analizador léxico, llamada por el parser para obtener el siguiente token.
    *   `extern int yyparse();`: La función principal del analizador sintáctico (el parser en sí).
    *   `extern FILE *yyin;`: Puntero al archivo de entrada del lexer.
    *   `extern int yylineno;`: Número de línea actual (para reportar errores).
    *   `extern int columna;`: Columna actual (para reportar errores).
*   **`void yyerror(const char *s);`**: Declaración de la función de manejo de errores de sintaxis, que Bison llamará cuando encuentre un error.

## 3. Unión de Valores Semánticos (`%union`)

La directiva `%union` define una unión de tipos de datos que pueden ser asociados con los tokens y los no-terminales de la gramática. Esto permite que el analizador léxico pase valores (atributos semánticos) al analizador sintáctico, y que los no-terminales acumulen o transformen estos valores.

*   **`char *str;`**: En este proyecto, la unión solo contiene un miembro `str` de tipo `char*`. Esto significa que los tokens y no-terminales que transportan información textual (como el contenido de un párrafo o un título) lo harán a través de punteros a cadenas de caracteres.

## 4. Declaración de Tokens (`%token`)

La directiva `%token` declara los símbolos terminales (tokens) que el analizador léxico (`escaner.l`) puede retornar.

*   **`%token <str> TEXTO CARACTER_ESPECIAL`**: Estos tokens están asociados con el miembro `str` de la unión `%union`, lo que significa que el lexer les adjuntará una cadena de texto.
*   **`%token CABECERA FINCABECERA ... PIEPAGINA FINPIEPAGINA`**: Estos son tokens simples (palabras clave) que no llevan un valor semántico asociado directamente en la unión. Su significado se deriva de su presencia en la gramática.

## 5. Regla Inicial (`%start`)

*   **`%start documento`**: Indica que `documento` es la regla inicial de la gramática. El parser intentará construir un "documento" completo a partir de la secuencia de tokens de entrada.

## 6. Declaración de Tipos para No-Terminales (`%type`)

La directiva `%type` se utiliza para especificar qué miembro de la unión `%union` deben usar los no-terminales para sus valores semánticos.

*   **`%type <str> titulo`**: El no-terminal `titulo` manejará su valor semántico como una cadena de caracteres (`char*`).
*   **`%type <str> contenido`**: El no-terminal `contenido` también manejará cadenas.
*   **`%type <str> fragmento`**: El no-terminal `fragmento` manejará cadenas.
*   **`%type <str> items`**: El no-terminal `items` manejará cadenas (concatenación de ítems de lista).

## 7. Sección de Reglas Gramaticales (`%%`)

Esta es la sección principal donde se definen las reglas de producción de la gramática y las acciones C asociadas. Cada regla tiene la forma `no_terminal : producción { acción_C };`.

*   **`$$`**: Representa el valor semántico del no-terminal del lado izquierdo de la regla.
*   **`$1, $2, $3, ...`**: Representan los valores semánticos de los símbolos (terminales o no-terminales) en el lado derecho de la producción, en orden.

### 7.1. Estructura General del Documento

*   **`documento : cabecera cuerpo pie_pagina`**: Define la estructura de alto nivel del documento: una `cabecera`, seguida de un `cuerpo`, y finalmente un `pie_pagina`. Las etiquetas `<body>` y `</html>` se imprimen en `main()` para evitar duplicaciones.

### 7.2. Cabecera y Título

*   **`cabecera : CABECERA titulo FINCABECERA`**:
    *   Reconoce la secuencia de tokens `CABECERA`, un `titulo` (no-terminal), y `FINCABECERA`.
    *   **Acción:** Imprime la etiqueta HTML `<header>`, el contenido del título (`$2`), y cierra la etiqueta `</header>`. La memoria asignada para `$2` (el título) se libera.
*   **`titulo : TITULO contenido FINTITULO`**:
    *   Reconoce `TITULO`, un `contenido` (no-terminal), y `FINTITULO`.
    *   **Acción:** Asigna memoria para una nueva cadena (`buf`), formatea el contenido como una etiqueta `<h1>` (`<h1>%s</h1>\n`), y asigna esta nueva cadena a `$$` (el valor semántico de `titulo`). La memoria de `$2` (el contenido original) se libera.

### 7.3. Cuerpo y Elementos

*   **`cuerpo : /* vacío */ | cuerpo elemento`**:
    *   Un `cuerpo` puede estar vacío (representado por `/* vacío */`).
    *   Un `cuerpo` puede ser recursivo, conteniendo un `cuerpo` previo seguido de un `elemento`. Esto permite múltiples elementos en el cuerpo.
*   **`elemento : parrafo | negrita | cursiva | lista | enlace`**: Un `elemento` puede ser cualquiera de los tipos de contenido definidos.

### 7.4. Elementos de Contenido (Párrafo, Negrita, Cursiva, Enlace)

Estas reglas siguen un patrón similar: reconocen una etiqueta de apertura, un `contenido` y una etiqueta de cierre, y luego imprimen la etiqueta HTML correspondiente con el contenido.

*   **`parrafo : PARRAFO contenido FINPARRAFO`**: Genera `<p>%s</p>\n`.
*   **`negrita : NEGRITA contenido FINNEGRITA`**: Genera `<b>%s</b>\n`.
*   **`cursiva : CURSIVA contenido FINCURSIVA`**: Genera `<i>%s</i>\n`.
*   **`enlace : ENLACE contenido FINENLACE`**: Genera `<a href=\"#\">%s</a>\n`. (Nota: El `href` está fijo a `#` para simplificar).

En cada caso, la memoria de `$2` (el `contenido`) se libera después de su uso.

### 7.5. Listas

*   **`lista : LISTA items FINLISTA`**:
    *   Reconoce `LISTA`, una colección de `items` (no-terminal), y `FINLISTA`.
    *   **Acción:** Imprime la etiqueta `<ul>`, el contenido de los ítems (`$2`), y cierra la etiqueta `</ul>`. La memoria de `$2` se libera.
*   **`items : /* vacío */ { $$ = strdup(""); } | items ITEM contenido FINITEM`**:
    *   La primera producción (`/* vacío */`) inicializa `items` con una cadena vacía. Esto es crucial para la recursión, ya que permite concatenar ítems sin un valor inicial nulo.
    *   La segunda producción es recursiva: un `items` puede ser un `items` previo, seguido de `ITEM`, un `contenido` y `FINITEM`.
    *   **Acción:** Asigna memoria para concatenar el `items` previo (`$1`) con el nuevo ítem formateado como `<li>%s</li>\n` (`$3`). La nueva cadena se asigna a `$$`. La memoria de `$1` y `$3` se libera.

### 7.6. Pie de Página

*   **`pie_pagina : PIEPAGINA contenido FINPIEPAGINA`**:
    *   Reconoce `PIEPAGINA`, un `contenido`, y `FINPIEPAGINA`.
    *   **Acción:** Imprime la etiqueta `<footer>` con el contenido (`$2`) y cierra la etiqueta. La memoria de `$2` se libera.

### 7.7. Contenido y Fragmentos de Texto

Estas reglas son fundamentales para manejar el texto dentro de las etiquetas.

*   **`contenido : fragmento { $$ = $1; } | contenido fragmento { ... }`**:
    *   Un `contenido` puede ser un solo `fragmento`.
    *   Un `contenido` puede ser un `contenido` previo concatenado con un nuevo `fragmento`.
    *   **Acción de concatenación:** Asigna memoria para la nueva cadena, copia el `contenido` previo (`$1`), añade un espacio (`" "`), concatena el nuevo `fragmento` (`$2`), y asigna el resultado a `$$`. Es importante liberar la memoria de `$1` y `$2` después de la concatenación para evitar fugas de memoria. La adición del espacio es clave para que las palabras no se unan.
*   **`fragmento : TEXTO { $$ = $1; } | CARACTER_ESPECIAL { $$ = $1; }`**:
    *   Un `fragmento` es un `TEXTO` o un `CARACTER_ESPECIAL`.
    *   **Acción:** Simplemente pasa el valor semántico (`$1`) del token al no-terminal `fragmento` (`$$`). La memoria de `$1` ya fue asignada por `strdup` en el lexer y será liberada cuando se use en la regla `contenido`.

## 8. Función de Manejo de Errores (`yyerror`)

*   **`void yyerror(const char *s)`**: Esta función es llamada por Bison cuando se detecta un error de sintaxis. Imprime un mensaje de error en `stderr`, incluyendo el número de línea (`yylineno`) y la columna (`columna`) donde ocurrió el error, junto con el mensaje proporcionado por Bison (`s`).

## 9. Función Principal (`main`)

La función `main` es el punto de entrada del programa compilado.

*   **Manejo de Argumentos:** Verifica que se proporcionen los argumentos correctos (`archivo_entrada.L5 -o archivo_salida.html`).
*   **Apertura de Archivos:**
    *   Abre el archivo de entrada (`yyin`) en modo lectura.
    *   Abre el archivo de salida HTML (`html_output_file`) en modo escritura.
    *   Abre `listado.txt` (`listado_file`) en modo escritura para el log del lexer.
    *   Maneja errores si algún archivo no puede abrirse.
*   **Inicio de Generación HTML:** Imprime la estructura HTML básica inicial (`<!DOCTYPE html>`, `<html>`, `<head>`, `<body>`).
*   **Llamada al Analizador Sintáctico:** Llama a `yyparse()`, que es la función que inicia el proceso de análisis. `yyparse()` a su vez llama a `yylex()` para obtener tokens.
*   **Finalización de Generación HTML:** Imprime las etiquetas de cierre `</body>` y `</html>`.
*   **Cierre de Archivos:** Cierra todos los archivos abiertos.
*   **Mensaje Final:** Imprime un mensaje indicando si la generación HTML fue exitosa o si se encontraron errores de sintaxis.
*   **Retorno:** Retorna el resultado de `yyparse()` (0 si no hay errores, 1 si hay errores).

## 10. Conclusión

`parser.y` es el cerebro del compilador, responsable de entender la estructura del lenguaje de entrada y de traducir esa estructura en el formato de salida deseado (HTML). A través de sus reglas gramaticales y acciones semánticas, coordina el flujo de tokens del lexer y construye progresivamente el documento HTML final. La gestión de memoria con `malloc` y `free` es crucial para evitar fugas de memoria al manipular las cadenas de texto.
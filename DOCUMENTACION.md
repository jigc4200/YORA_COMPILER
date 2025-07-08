# Documentación del Proyecto YORA_COMPILER

Este documento proporciona una visión general del proyecto, su estructura, el proceso de compilación y ejecución, y una descripción de alto nivel de sus componentes principales.

## 1. Introducción

El proyecto `YORA_COMPILER` parece ser un compilador o un generador de código simple que procesa un lenguaje de entrada específico (representado por archivos `.L5`) y produce una salida en formato HTML. Utiliza herramientas estándar de desarrollo de compiladores como Flex para el análisis léxico y Bison para el análisis sintáctico.

## 2. Estructura del Proyecto

El directorio del proyecto contiene los siguientes archivos y directorios clave:

*   **`escaner.l`**: Archivo fuente para el analizador léxico, escrito para Flex. Define las reglas para reconocer los tokens (unidades mínimas de significado) del lenguaje de entrada.
*   **`parser.y`**: Archivo fuente para el analizador sintáctico, escrito para Bison. Define la gramática del lenguaje de entrada y cómo los tokens se combinan para formar estructuras sintácticas válidas.
*   **`build.sh`**: Un script de shell que automatiza el proceso de compilación y ejecución del proyecto.
*   **`ejemplo.L5`**: Un archivo de ejemplo que sirve como entrada para el compilador. Contiene código en el lenguaje específico que el compilador está diseñado para procesar.
*   **`salida.html`**: El archivo de salida generado por el compilador después de procesar `ejemplo.L5`. Se espera que contenga contenido HTML.
*   **`notes.md`**: Un archivo de notas que contiene instrucciones manuales para la compilación y ejecución, así como otros apuntes de desarrollo.
*   **`lex.yy.c`**: Archivo C generado por Flex a partir de `escaner.l`. Contiene el código del analizador léxico.
*   **`parser.tab.c`**: Archivo C generado por Bison a partir de `parser.y`. Contiene el código del analizador sintáctico.
*   **`parser.tab.h`**: Archivo de cabecera generado por Bison, que contiene las definiciones de tokens y tipos de datos utilizados por el analizador léxico y sintáctico.
*   **`genweb`**: El ejecutable final del compilador, generado después de la compilación con GCC.

## 3. Proceso de Compilación y Ejecución

El script `build.sh` simplifica el proceso de construcción del compilador. A continuación, se detallan los pasos que realiza y los comandos manuales equivalentes:

### 3.1. Pasos Automatizados con `build.sh`

Para compilar y ejecutar el proyecto, simplemente ejecuta el script `build.sh` en la terminal:

```bash
./build.sh
```

El script realiza las siguientes operaciones:

1.  **Generación del Analizador Léxico:**
    *   Ejecuta Flex sobre `escaner.l` para generar `lex.yy.c`.
    *   Comando: `flex escaner.l`
2.  **Generación del Analizador Sintáctico:**
    *   Ejecuta Bison sobre `parser.y` para generar `parser.tab.c` y `parser.tab.h`.
    *   Comando: `bison -d -t parser.y`
3.  **Compilación del Programa Final:**
    *   Compila `lex.yy.c` y `parser.tab.c` utilizando GCC.
    *   Vincula con la librería Flex (`-lfl`).
    *   Crea el ejecutable `genweb`.
    *   Comando: `gcc lex.yy.c parser.tab.c -lfl -o genweb`
4.  **Ejecución del Compilador:**
    *   Ejecuta el compilador `genweb` con `ejemplo.L5` como entrada.
    *   Redirige la salida a `salida.html`.
    *   Comando: `./genweb ejemplo.L5 -o salida.html`

### 3.2. Comandos Manuales (Alternativa)

Si prefieres ejecutar los pasos manualmente, puedes seguir esta secuencia:

1.  **Generar analizador léxico:**
    ```bash
    flex escaner.l
    ```
2.  **Generar analizador sintáctico:**
    ```bash
    bison -d parser.y
    ```
3.  **Compilar el programa final:**
    ```bash
    gcc lex.yy.c parser.tab.c -lfl -o mi_parser
    ```
    (Nota: El nombre del ejecutable puede variar si no se especifica `-o` o si se usa un nombre diferente al de `build.sh`).

## 4. Uso del Compilador

Una vez compilado, puedes ejecutar el programa `genweb` para procesar un archivo de entrada y generar una salida HTML.

```bash
./genweb <archivo_de_entrada>.L5 -o <archivo_de_salida>.html
```

Por ejemplo, para usar el archivo de ejemplo:

```bash
./genweb ejemplo.L5 -o salida.html
```

## 5. Análisis de `escaner.l` y `parser.y` (Alto Nivel)

*   **`escaner.l` (Analizador Léxico):** Este archivo define las expresiones regulares que identifican los diferentes tipos de tokens en el lenguaje de entrada. Por ejemplo, podría definir cómo reconocer palabras clave, identificadores, números, operadores, etc. Su función es leer el código fuente y dividirlo en una secuencia de tokens que el analizador sintáctico pueda entender.

*   **`parser.y` (Analizador Sintáctico):** Este archivo contiene la gramática formal del lenguaje de entrada, expresada en términos de reglas de producción. Define cómo los tokens (proporcionados por el analizador léxico) se combinan para formar estructuras sintácticas válidas (como declaraciones, expresiones, bucles, etc.). Cuando el analizador sintáctico reconoce una estructura, puede ejecutar acciones asociadas, que en este caso, probablemente construyen el contenido HTML de salida.

Aunque no se ha realizado un análisis profundo del contenido de `ejemplo.L5`, la naturaleza del proyecto sugiere que el lenguaje de entrada es un DSL (Domain Specific Language) diseñado para generar contenido web.
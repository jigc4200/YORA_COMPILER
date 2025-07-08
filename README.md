# YORA_COMPILER: Generador Web/Compilador Simple

## Descripción

`YORA_COMPILER` es un proyecto que implementa un compilador/generador de código simple. Su propósito principal es procesar un lenguaje de entrada específico (definido por archivos con extensión `.L5`) y transformarlo en contenido HTML. Este proyecto sirve como un ejemplo práctico de cómo se pueden utilizar herramientas como Flex y Bison para construir analizadores léxicos y sintácticos, respectivamente, y cómo se integran en un flujo de trabajo de compilación.

## Características

*   **Análisis Léxico:** Utiliza Flex para la tokenización del lenguaje de entrada.
*   **Análisis Sintáctico:** Emplea Bison para la validación de la gramática y la construcción de la estructura del código.
*   **Generación de Salida HTML:** Transforma el código de entrada en un archivo HTML.
*   **Script de Compilación Automatizado:** Incluye un script `build.sh` para simplificar el proceso de compilación y ejecución.

## Tecnologías Utilizadas

*   **Flex (Fast Lexical Analyzer Generator):** Herramienta para generar analizadores léxicos.
*   **Bison (GNU Parser Generator):** Herramienta para generar analizadores sintácticos.
*   **GCC (GNU Compiler Collection):** Compilador utilizado para construir el ejecutable final.
*   **Bash:** Para el script de automatización `build.sh`.

## Cómo Empezar

Para poder compilar y ejecutar este proyecto, necesitarás tener instaladas las siguientes herramientas en tu sistema:

### Prerrequisitos

*   **Flex:** Puedes instalarlo a través del gestor de paquetes de tu sistema operativo (ej. `sudo apt-get install flex` en Debian/Ubuntu, `brew install flex` en macOS).
*   **Bison:** Similar a Flex, se instala a través del gestor de paquetes (ej. `sudo apt-get install bison` en Debian/Ubuntu, `brew install bison` en macOS).
*   **GCC:** Generalmente viene preinstalado en sistemas Linux. Si no, puedes instalarlo (ej. `sudo apt-get install build-essential` en Debian/Ubuntu).

### Instalación

1.  Clona este repositorio (si aplica, asumiendo que es un repositorio Git):
    ```bash
    git clone https://github.com/tu_usuario/YORA_COMPILER.git
    cd YORA_COMPILER
    ```
    (Si no es un repositorio, simplemente asegúrate de tener todos los archivos en un directorio local).

## Uso

El proyecto incluye un script `build.sh` que automatiza el proceso de compilación y ejecución.

### Compilación y Ejecución Automatizada

1.  Abre una terminal en el directorio raíz del proyecto.
2.  Ejecuta el script `build.sh`:
    ```bash
    ./build.sh
    ```
    Este script realizará los siguientes pasos:
    *   Generará `lex.yy.c` a partir de `escaner.l` (Flex).
    *   Generará `parser.tab.c` y `parser.tab.h` a partir de `parser.y` (Bison).
    *   Compilará `lex.yy.c` y `parser.tab.c` junto con la librería Flex (`-lfl`) para crear el ejecutable `genweb`.
    *   Finalmente, ejecutará `genweb` con `ejemplo.L5` como entrada y redirigirá la salida a `salida.html`.

### Compilación y Ejecución Manual (Alternativa)

Si prefieres un control más granular, puedes ejecutar los comandos individualmente:

1.  **Generar el analizador léxico:**
    ```bash
    flex escaner.l
    ```
2.  **Generar el analizador sintáctico:**
    ```bash
    bison -d parser.y
    ```
3.  **Compilar el programa final:**
    ```bash
    gcc lex.yy.c parser.tab.c -lfl -o genweb
    ```
    (Puedes usar `mi_parser` o cualquier otro nombre para el ejecutable si lo deseas).

4.  **Ejecutar el compilador:**
    ```bash
    ./genweb ejemplo.L5 -o salida.html
    ```
    Puedes reemplazar `ejemplo.L5` con tu propio archivo de entrada `.L5` y `salida.html` con el nombre deseado para el archivo de salida.

## Estructura del Proyecto

*   **`escaner.l`**: Definiciones del analizador léxico (Flex).
*   **`parser.y`**: Definiciones del analizador sintáctico (Bison).
*   **`build.sh`**: Script de shell para automatizar la compilación y ejecución.
*   **`ejemplo.L5`**: Archivo de entrada de ejemplo para el compilador.
*   **`salida.html`**: Archivo de salida HTML generado.
*   **`notes.md`**: Notas de desarrollo y comandos manuales.
*   **`DOCUMENTACION.md`**: Documentación detallada del proyecto.
*   **Archivos generados (no versionados, creados durante la compilación):**
    *   `lex.yy.c`
    *   `parser.tab.c`
    *   `parser.tab.h`
    *   `genweb` (el ejecutable final)

## Contribución

Si deseas contribuir a este proyecto, por favor, sigue los siguientes pasos:
1.  Haz un fork del repositorio.
2.  Crea una nueva rama (`git checkout -b feature/nueva-caracteristica`).
3.  Realiza tus cambios y commitea (`git commit -am 'Añadir nueva característica'`).
4.  Sube tus cambios a la rama (`git push origin feature/nueva-caracteristica`).
5.  Abre un Pull Request.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.
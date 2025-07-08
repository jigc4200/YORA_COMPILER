#!/bin/bash

# Nombre de tu archivo .l (Flex)
FLEX_FILE="escaner.l"
# Nombre de tu archivo .y (Bison)
BISON_FILE="parser.y"
# Nombre de tu ejecutable final
OUTPUT_EXECUTABLE="genweb"

echo "--- Generando analizador léxico con Flex ---"
flex "$FLEX_FILE"

# Verificar si Flex tuvo éxito
if [ $? -ne 0 ]; then
    echo "Error: Flex falló. Revisa '$FLEX_FILE'."
    exit 1
fi

echo "--- Generando analizador sintáctico con Bison ---"
bison -d -t "$BISON_FILE"

# Verificar si Bison tuvo éxito
if [ $? -ne 0 ]; then
    echo "Error: Bison falló. Revisa '$BISON_FILE'."
    exit 1
fi

# Determinar el nombre del archivo .tab.c generado por Bison
# Bison genera y.tab.c por defecto, o <nombre_base>.tab.c si el .y no es y.y
BISON_C_FILE="${BISON_FILE%.*}.tab.c" # Esto quita '.y' y añade '.tab.c'
if [ ! -f "$BISON_C_FILE" ]; then
    # Si el nombre por defecto no existe, intenta el nombre estándar
    BISON_C_FILE="y.tab.c"
    if [ ! -f "$BISON_C_FILE" ]; then
        echo "Error: No se encontró el archivo .tab.c generado por Bison. Se esperaba '${BISON_FILE%.*}.tab.c' o 'y.tab.c'."
        exit 1
    fi
fi


echo "--- Compilando el programa final con GCC ---"
gcc lex.yy.c "$BISON_C_FILE" -lfl -o "$OUTPUT_EXECUTABLE"

# Verificar si GCC tuvo éxito
if [ $? -ne 0 ]; then
    echo "Error: La compilación con GCC falló."
    exit 1
fi

echo "--- Compilación completada con éxito. Ejecutable: $OUTPUT_EXECUTABLE ---"
echo "Puedes ejecutarlo con: ./$OUTPUT_EXECUTABLE"

# Ejecutar el programa automáticamente con los argumentos deseados
echo "--- Ejecutando: ./$OUTPUT_EXECUTABLE ejemplo.L5 -o salida.html ---"
./"$OUTPUT_EXECUTABLE" ejemplo.L5 -o salida.html



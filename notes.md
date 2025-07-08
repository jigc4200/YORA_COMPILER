

./build.sh // para ejecutar el bash de los comandos de flex y bison

sino  (
    1.flex lex_example.l,
    2.bison -d yacc_example.y
    3.gcc lex.yy.c yacc_example.tab.c -lfl -o mi_parser )

Ejecutar uno por uno en caracter descendente 

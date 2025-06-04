# PROGRAMA - PROYECTO 9

## Funcionamiento

El programa hace que el bit PC3 siga este ciclo:

CICLO BÁSICO
A PC3 <-- 1,durante  900 mS
B PC3 <-- 0,durante  100 mS
C Retorna al paso A

Si hay un flanco de bajada en el bit PA3 presentará la siguiente secuencia:
1 PC3 <-- 1,durante 2 segundos
2 PC3 <-- 0,durante 2 segundos
3 PC3 <-- 1,durante 500 mS
4 PC3 <-- 0,durante 500 mS
5 Retorna al ciclo básico

> [!Note]
> El código no contiene acentos

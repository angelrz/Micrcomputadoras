#include <p16f877A.inc>  ; Incluir el archivo de configuración del PIC16F877A

valor1 equ 0x21         ; Definimos las direcciones de memoria
valor2 equ 0x22         ; para los valores
valor3 equ 0x23         ;
cte1 equ 0x80           ; Valores hexadecimales para el retardo
cte2 equ 0x50
cte3 equ 0x60

ORG 0                   ; Dirección de inicio
GOTO INICIO             ; Salto a la etiqueta INICIO

ORG 5                   ; Dirección del vector de interrupciones

INICIO:
    BSF STATUS, RP0     ; Cambiar al banco 1
    BCF STATUS, RP1     ; Limpiar RP1 para estar en banco 0
    MOVLW 0x00          ; Cargar 0 en W
    MOVWF TRISB         ; Configurar PORTB como salida
    
    BCF STATUS, RP0     ; Regresar a banco 0
    CLRF PORTB          ; Limpiar PORTB al principio

loop2:
    MOVLW 0x80          ; Cargar el valor H'80' en W
    MOVWF PORTB         ; Actualizar PORTB
    CALL retardo        ; Llamar a la subrutina de retardo

ROTA:
    RRF PORTB, 1        ; Rotar el contenido de PORTB a la derecha
    BTFSS PORTB, 0      ; Comprobar si el bit 0 de PORTB es 0
    GOTO ES_CERO        ; Si es 0, saltamos a ES_CERO
    CALL retardo        ; Llamar al retardo
    GOTO loop2          ; Repetir el ciclo

ES_CERO:
    CALL retardo        ; Hacer un retardo extra cuando el bit 0 es 0
    GOTO ROTA           ; Volver a la rotación

retardo:
    MOVLW cte1          ; Cargar cte1 en W (valor H'80')
    MOVWF valor1        ; Almacenar en valor1
tres:
    MOVLW cte2          ; Cargar cte2 en W (valor H'50')
    MOVWF valor2        ; Almacenar en valor2
dos:
    MOVLW cte3          ; Cargar cte3 en W (valor H'60')
    MOVWF valor3        ; Almacenar en valor3
uno:
    DECFSZ valor3, F    ; Decrementar valor3 y saltar si es cero
    GOTO uno            ; Si no es cero, seguir decrementando
    DECFSZ valor2, F    ; Decrementar valor2 y saltar si es cero
    GOTO dos            ; Si no es cero, seguir decrementando
    DECFSZ valor1, F    ; Decrementar valor1 y saltar si es cero
    GOTO tres           ; Si no es cero, seguir decrementando
    RETURN              ; Retornar al flujo principal

END

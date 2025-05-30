    PROCESSOR 16F877A
    INCLUDE <P16F877A.INC>     ; Se incluyen las librerías necesarias para trabajar

    ORG 0                      ; Vector de reset
    GOTO INICIO                ; Salto al inicio del programa

    ORG 5                      ; Mover al inicio del programa
INICIO:
    CLRF PORTB                 ; Se limpia PORTB
    CLRF PORTA                 ; Limpia PORTA
    BSF STATUS, RP0            ; Cambia a banco 1
    BCF STATUS, RP1            ; Asegura banco 1

    MOVLW 06H                  ; Define puertos A y E como digitales
    MOVWF ADCON1

    MOVLW B'00111111'          ; Configura TRISA (6 bits de entrada, 2 de salida)
    MOVWF TRISA
    MOVLW B'00000000'          ; Configura TRISB como salida
    MOVWF TRISB

    BCF STATUS, RP0            ; Cambia a banco 0

PROGRAMA:
    BTFSS PORTA, 0             ; ¿PORTA.0 = 1?
    GOTO APAGAR                ; No -> Apagar LEDs
    GOTO PRENDER               ; Sí -> Prender LEDs

APAGAR:
    CLRF PORTB                 ; Apagar LEDs
    GOTO PROGRAMA              ; Regresar al programa principal

PRENDER:
    MOVLW H'FF'                ; Cargar valor para encender LEDs
    MOVWF PORTB                ; Encender LEDs en PORTB
    GOTO PROGRAMA              ; Regresar al programa principal

    END                         ; Fin del programa

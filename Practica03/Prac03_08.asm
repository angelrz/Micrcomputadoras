processor 16f877        ; Indica la versión de procesador
include <p16f877.inc>   ; Incluye la librería de la versión del procesador

valor1  EQU 0x21        ; Asigna el valor de 21 a valor1
valor2  EQU 0x22        ; Asigna el valor de 22 a valor2
valor3  EQU 0x23        ; Asigna el valor de 23 a valor3
cte1    EQU 0x08        ; Asigna el valor de 8 a cte1
cte2    EQU 0x50        ; Asigna el valor de 50 a cte2
cte3    EQU 0x60        ; Asigna el valor de 60 a cte3

ORG 0                  ; Especifica un origen (vector de reset)
GOTO INICIO            ; Código del programa

ORG 5                  ; Indica origen para inicio del programa
INICIO:  
    ; === Configuración de Banco ===
    BSF STATUS, RP0     ; Cambia al Banco 1
    BCF STATUS, RP1

    MOVLW H'00'         ; Configura PORTB como salida
    MOVWF TRISB

    BCF STATUS, RP0     ; Regresa a Banco 0
    CLRF PORTB          ; Borra el contenido de PORTB

LOOP2:  
    MOVLW B'11111111'   ; Enciende todos los bits de PORTB
    MOVWF PORTB
    CALL RETARDO        ; Llama a la subrutina RETARDO

    MOVLW B'00000000'   ; Apaga todos los bits de PORTB
    MOVWF PORTB
    CALL RETARDO        ; Llama a la subrutina RETARDO

    GOTO LOOP2          ; Salta a LOOP2

; === Subrutina de Retardo ===
RETARDO:  
    MOVLW cte1          ; Carga el valor inicial del contador
    MOVWF valor1

    MOVLW cte2
    MOVWF valor2

    MOVLW cte3
    MOVWF valor3

UNO:  
    DECFSZ valor3, F    ; Decrementa valor3 hasta cero
    GOTO UNO
    DECFSZ valor2, F    ; Decrementa valor2 hasta cero
    GOTO UNO
    DECFSZ valor1, F    ; Decrementa valor1 hasta cero
    GOTO UNO

    RETURN              ; Regresa de la subrutina
    END                 ; Directiva de fin de programa

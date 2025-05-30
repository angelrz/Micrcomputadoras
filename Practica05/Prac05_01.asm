PROCESSOR 16F877A
INCLUDE <P16F877A.INC>

; Constantes para el retardo 
VALOR1 EQU 0X21    ; Registros temporales
VALOR2 EQU 0X22
VALOR3 EQU 0X23
CTE1   EQU 2       ; Ajuste temporal (~20ms)
CTE2   EQU .200
CTE3   EQU .82

; Vector de reset
RESET:
    ORG 0
    GOTO INICIO    ; Punto de entrada al programa
    ORG 5

; Configuracion inicial de puertos
INICIO:
    CLRF PORTA      ; Limpieza inicial
    CLRF PORTB
    BSF STATUS,RP0  ; Banco 1 para configuracion
    
    ; Configuracion de puertos:
    CLRF TRISB      ; PORTB como salida (control motores)
    MOVLW 0X06
    MOVWF ADCON1    ; Todos los pines como digitales
    MOVLW 0X3F
    MOVWF TRISA     ; PORTA como entrada (6 pines)
    
    BCF STATUS,RP0  ; Vuelta al banco 0

; Bucle principal de control
LOOP:
    MOVF PORTA,W    ; Leer estado de entradas (PORTA)
    CALL MOTORES    ; Obtener patron de control
    MOVWF PORTB     ; Escribir en salida (PORTB)
    CALL RETARDO    ; Pausa para estabilidad
    GOTO LOOP       ; Repetir continuamente

; Tabla de patrones para motores
; Formato: [M2_EN][M2_DIR1][M2_DIR2][M1_EN][M1_DIR1][M1_DIR2]
MOTORES:
    ANDLW 0X0F      ; Usar solo 4 bits bajos (0-15)
    ADDWF PCL,F     ; Salto computado segun entrada
    
    ; Los 9 modos predefinidos:
    RETLW B'00000000' ; 0: Todo apagado
    RETLW B'00000100' ; 1: Motor2 sentido A
    RETLW B'00101000' ; 2: Motor2 sentido B
    RETLW B'00000010' ; 3: Motor1 sentido A
    RETLW B'00000001' ; 4: Motor1 sentido B
    RETLW B'00000110' ; 5: Ambos sentido A
    RETLW B'00101001' ; 6: Ambos sentido B
    RETLW B'00001010' ; 7: M1(A) + M2(B)
    RETLW B'00110101' ; 8: M1(B) + M2(A)

; Subrutina de retardo
RETARDO:
    MOVLW CTE1
    MOVWF VALOR1     ; Primer nivel (mas lento)
TRES:
    MOVLW CTE2
    MOVWF VALOR2     ; Segundo nivel
DOS:
    MOVLW CTE3
    MOVWF VALOR3     ; Tercer nivel (mas rapido)
UNO:
    DECFSZ VALOR3,F  ; Bucle interno
    GOTO UNO
    DECFSZ VALOR2,F  ; Bucle medio
    GOTO DOS
    DECFSZ VALOR1,F  ; Bucle externo
    GOTO TRES
    RETURN           ; Fin del retardo

END
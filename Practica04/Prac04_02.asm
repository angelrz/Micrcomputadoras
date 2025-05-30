PROCESSOR 16F877A
INCLUDE <P16F877A.INC>

valor1 equ h'21'   ; Direcciones con las que se trabajará para realizar los retardos
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 20h       ; Constantes necesarias para realizar el retardo
cte2 equ 50h
cte3 equ 60h

ORG 0              ; Vector de reset
GOTO INICIO

ORG 5              ; Se mueve el PC al inicio del programa
INICIO:
    CLRF PORTB     ; Se limpia el PORTB
    CLRF PORTA     ; Limpia PORTA
    BSF STATUS, RP0 ; Cambia a banco 1
    BCF STATUS, RP1
    MOVLW 06H      ; Define puertos A y E como digitales
    MOVWF ADCON1
    MOVLW H'3F'    ; Configura puerto A como entrada
    MOVWF TRISA
    MOVLW B'00000000' ; Configura al puerto B como salida (8 bits)
    MOVWF TRISB
    BCF STATUS, RP0 ; Cambia al banco 0

LOOP:
    MOVF PORTA, W  ; W <- PORTA
    ANDLW 7        ; W <- W AND 00000111 (máscara para los 3 bits menos significativos)
    ADDWF PCL, F   ; PCL <- PCL + W (simula un switch)
    GOTO APAGADOS
    GOTO ENCENDIDOS
    GOTO CORRDER
    GOTO CORRIZQ
    GOTO CORRZIGZAG
    GOTO ENCENDER_APAGAR
    GOTO DEFAULT

APAGADOS:
    CLRF PORTB     ; Apaga todos los LEDs
    GOTO LOOP

ENCENDIDOS:
    MOVLW H'FF'    ; Enciende todos los LEDs
    MOVWF PORTB
    GOTO LOOP

CORRIZQ:
    MOVLW 0X01     ; Primer bit encendido
    MOVWF PORTB
    CALL retardo
ROTA2:
    RLF PORTB, 1   ; Rota un bit a la izquierda
    BTFSS PORTB, 7 ; Si PORTB.7 = 1
    GOTO ES_CERO2
    CALL retardo
    GOTO LOOP
ES_CERO2:
    CALL retardo
    GOTO ROTA2

CORRDER:
    MOVLW 0X80     ; Bit más significativo encendido
    MOVWF PORTB
    CALL retardo
ROTA1:
    RRF PORTB, 1   ; Rota un bit a la derecha
    BTFSS PORTB, 0 ; Si PORTB.0 = 1
    GOTO ES_CERO
    CALL retardo
    GOTO LOOP
ES_CERO:
    CALL retardo
    GOTO ROTA1

CORRZIGZAG:
    MOVLW 0X01
    MOVWF PORTB
    CALL retardo
ROTA3:
    RLF PORTB, 1
    BTFSS PORTB, 7
    GOTO ES_CERO3
    CALL retardo
    GOTO DERECHA
ES_CERO3:
    CALL retardo
    GOTO ROTA3
DERECHA:
    MOVLW 0X80
    MOVWF PORTB
ROTA4:
    RRF PORTB, 1
    BTFSS PORTB, 0
    GOTO ES_CERO4
    GOTO LOOP
ES_CERO4:
    CALL retardo
    GOTO ROTA4

ENCENDER_APAGAR:
    CLRF PORTB
    CALL retardo
    MOVLW H'FF'
    MOVWF PORTB
    CALL retardo
    GOTO LOOP

DEFAULT:
    GOTO LOOP

retardo:
    MOVLW cte1
    MOVWF valor1
tres:
    MOVLW cte2
    MOVWF valor2
dos:
    MOVLW cte3
    MOVWF valor3
uno:
    DECFSZ valor3
    GOTO uno
    DECFSZ valor2
    GOTO dos
    DECFSZ valor1
    GOTO tres
    RETURN

END
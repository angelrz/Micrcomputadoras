processor 16f877a
include <p16f877a.inc>

valor1 equ h'21'	; registros utilizados en la rutina de retardo
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 0xFF		; constantes que determinan la duración del retardo
cte2 equ 50h
cte3 equ 60h

	ORG 0
	GOTO INICIO		; salta al inicio del programa principal

ORG 5
INICIO:
    BSF STATUS,RP0	; cambia al banco 1 de registros
    MOVLW H'0'
    MOVWF TRISB	; configura el puerto B como salida digital
    BCF STATUS,RP0
    CLRF PORTB		; inicializa el puerto B limpiando sus valores
E1:
    MOVLW h'41'	; configura un patrón en PORTB (v1 r2)
    MOVWF PORTB
    CALL retardo	; llama a la rutina de retardo
    GOTO E2
E2:
    MOVLW H'21'	; configura otro patrón en PORTB (a1 r2)
    MOVWF PORTB
    CALL retardo
    GOTO E3
E3:
    MOVLW H'14'	; configura un tercer patrón en PORTB (r1 v2)
    MOVWF PORTB
    CALL retardo
    GOTO E4
E4:
    MOVLW H'12'	; configura un cuarto patrón en PORTB (r1 a2)
    MOVWF PORTB
    CALL retardo
    GOTO E1		; regresa al inicio del ciclo
retardo:
    MOVLW cte1	; carga los valores iniciales para los registros de retardo
    MOVWF valor1
tres:
    MOVLW cte2
    MOVWF valor2
dos:
    MOVLW cte3
    MOVWF valor3
uno:
    DECFSZ valor3	; decrementa el registro valor3 hasta 0
    GOTO uno
    DECFSZ valor2	; decrementa valor2 y verifica si llegó a 0
    GOTO dos
    DECFSZ valor1	; decrementa valor1 y verifica si llegó a 0
    GOTO tres
    RETURN 		; regresa al programa principal

	END	; finaliza el programa

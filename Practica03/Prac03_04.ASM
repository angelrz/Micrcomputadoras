processor 16f877
include <p16f877.inc>

valor1 equ h'21'	; Declaración de una variable en memoria RAM
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 20h		; Constantes usadas en el retardo
cte2 equ 50h
cte3 equ 60h

	ORG 0		; dirección de memoria inicial
	GOTO INICIO	; Salta a la rutina INICIO

ORG 5	; inicia el código principal en la dirección de memoria 5
INICIO:
    BSF STATUS, RP0
    BCF STATUS, RP1	; cambio al banco 1 de ram
    MOVLW H'0'
    MOVWF TRISB		; Configura los pines del puerto B como salidas
    BCF STATUS, RP0	; regresa al banco 0 de ram
    CLRF PORTB		; limpia el puerto b

loop2:				; loop principal programa cíclico
    BSF PORTB, 0       ; PORTB.0 <-- 1, enciende el bit 0 (un led) del puerto B .
    CALL retardo       ; llama a la rutina de retardo
    BCF PORTB, 0       ; PORTB.0 <-- 0 Apaga el led conectado al bit 0 del puerto B.
    CALL retardo       ; llama nuevamente al retardo
    GOTO loop2         ; vuelve a empezar el ciclo infinito

retardo:
    MOVLW cte1         ; Carga el valor de cte en W
    MOVWF valor1       ; Guarda el valor en valor1
tres:
    MOVLW cte2 
    MOVWF valor2
dos:
    MOVLW cte3 
    MOVWF valor3 
uno:
    DECFSZ valor3      ; Decrementa valor3 y verifica si llega a 0
    GOTO uno           ; Si no llegó a 0, repite el ciclo
    DECFSZ valor2      ; decrementa valor2 y verifica si llega a 0
    GOTO dos           ; Si no llegó a 0, vuelve al ciclo "dos"
    DECFSZ valor1      ; decrementa valor1 y verifica si llega a 0
    GOTO tres          ; Si no llegó a 0, vuelve al ciclo "tres"
    RETURN             ; termina la rutina de retardo
    END                ; finaliza el programa

	;PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>

CHR 	EQU 	0x20	;Para el dato recibido
CONT 	EQU 	0X21	;Para los corrimientos

; Variables para la rutina de retardo
valor1 	EQU 	0x41
valor2 	EQU 	0x42
valor3 	EQU 	0x43

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	CALL 	CONFIG_INICIAL
    
RECIBE:
	;	Comprueba si ya se recibieron datos
    BTFSS   PIR1,RCIF   
    GOTO    RECIBE
    
	; Lee el dato Recibido, lo guarda en el registro CHR
    MOVFW   RCREG
    MOVWF   CHR
	BSF		CHR,5 ; Para convertir los caracteres a minúsculas

CHECK1:
	; Revisa si el dato recibido fue una 'd' (100 en ascii), si es así va a SHIFT_RIGHT
	; si no entonces va a la siguiente comparación
    MOVLW   .100
    XORWF   CHR,W
    BTFSS   STATUS,Z 
    GOTO    CHECK2
	GOTO 	SHIFT_RIGHT
    GOTO    RECIBE
    
CHECK2:
	; Revisa si el dato recibido fue una 'i' (105 en ascii), si es así va a SHIFT_LEFT
	; si no entonces regresa a RECIBE
    MOVLW   .105
    XORWF   CHR,W
    BTFSC   STATUS,Z
	GOTO 	SHIFT_LEFT
    GOTO    RECIBE

SHIFT_RIGHT:
	BCF STATUS,C	;Limpia el carry para evitar errores
	; Carga el valor inicial a B (1000 0000)
	MOVLW 0x80
	MOVWF PORTB
	; Carga 8 al contador para que se haga el corrimiento en todos los leds
	MOVLW 0x08
	MOVWF CONT
	
GIRAR:	
	CALL	RETARDO_500ms	;Hace un retardo de 0.5s
	;Hace un corrimeinto y decrementa el contador. Cuando el contador llega a 0 vuelve a RECIBE
	RRF		PORTB
	DECFSZ	CONT
	GOTO 	GIRAR
	GOTO 	RECIBE

SHIFT_LEFT:
	BCF STATUS,C	;Limpia el carry para evitar errores
	; Carga el valor inicial a B (0000 0001)
	MOVLW 0x01
	MOVWF PORTB
	; Carga 8 al contador para que se haga el corrimiento en todos los leds
	MOVLW 0x08
	MOVWF CONT
	
GIRAL:
	CALL 	RETARDO_500ms	;Hace un retardo de 0.5s
	;Hace un corrimeinto y decrementa el contador. Cuando el contador llega a 0 vuelve a RECIBE
	RLF		PORTB
	DECFSZ	CONT
	GOTO 	GIRAL
	GOTO 	RECIBE

;Rutina para configuración de puertos
CONFIG_INICIAL:
	; Cambio al banco 1
	BSF     STATUS,RP0  
    BCF     STATUS,RP1
    BSF     TXSTA,BRGH  ; Configura la bandera BRGH para alta velocidad.
	; Establece el baudrate en 9600 baudios.
    MOVLW   0x81        
    MOVWF   SPBRG
    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    CLRF    TRISB       ; Puerto B como salida.

    BCF     STATUS,RP0

    BSF     RCSTA,SPEN	; Habilita el puerto serie
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.

    CLRF    PORTB

	RETURN

;Subrutina de retardo de 500ms
RETARDO_500ms 
	MOVLW .50
	MOVWF valor1
tres_500:
	MOVLW .200
	MOVWF valor2
dos_500: 
	MOVLW .82
	MOVWF valor3
uno_500: 
	DECFSZ 	valor3
	GOTO 	uno_500
	DECFSZ 	valor2
	GOTO 	dos_500
	DECFSZ 	valor1
	GOTO 	tres_500
	RETURN

    END
    
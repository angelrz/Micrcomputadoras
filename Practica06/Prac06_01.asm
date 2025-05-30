;PROCESSOR 16f877a
INCLUDE <p16f877a.inc>

;Variables para los retardos
valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43
    
    ORG 0
    GOTO INICIO
    ORG 5

INICIO:
    CALL    CONFIG_INICIAL
    MOVLW   0xE9        ; Selecciona el canal 5
    ANDWF   ADCON0,F

    ;Enciende ADON y la bandera GO/DONE
    MOVLW   0x05
    IORWF   ADCON0,F    
    CALL    RET_200us

READ_PORT:
    ;Se revisa GO/DONE, una vez 
    ; que se pone en cero avanza a la siguiente línea
    BTFSC   ADCON0,2    
    GOTO    READ_PORT   
    
    ;Se leen los 8 MSB del CAD y se pasan al puerto D para mostrarlos en LEDs
    MOVFW   ADRESH
    MOVWF   PORTD

    BSF     ADCON0,2
    GOTO    READ_PORT
    
CONFIG_INICIAL:
    CLRF PORTA
	BCF     STATUS,RP1
	BSF     STATUS,RP0
	CLRF    TRISD

    ; Configura Todos pines del CAD como entradas analógicas. Resultado 
    ; justificado a la izquiera (8 bits del resultado se guardan en ADRESH)
    CLRF    ADCON1
	BCF     STATUS,RP0
    
    ;Frecuencia de muestreo usando el reloj interno, Canalo analógico 5 (AN5)
    MOVLW   0xE9        ;1110 1001    
    MOVWF   ADCON0 

	;Limpia el puerto D
	CLRF    PORTD
	RETURN

;Rutina de retardo de 200 microsegundos
RET_200us:
	MOVLW   0x01
	MOVWF   valor1
	MOVLW   0x20
	MOVWF   valor2
	DECFSZ 	valor2
	GOTO 	$ - 1
	DECFSZ 	valor1
	GOTO 	$ - 5
	RETURN
END

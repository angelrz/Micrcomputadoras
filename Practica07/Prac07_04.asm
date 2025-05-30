	;PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>

CHR EQU 0x20

	ORG 0
	GOTO INICIO
	ORG 5

INICIO: 
   CALL     CONFIG_INICIAL
    
RECIBE:
    ; Comprueba si ya se recibieron datos
    BTFSS   PIR1,RCIF   
    GOTO    RECIBE

    ; Lee el dato Recibido, lo guarda en el registro CHR
    MOVFW   RCREG
    MOVWF   CHR
    
    ; Compara si el dato es 0, si es cero entonces apaga el bit 0 del 
    ; puerto B y vuelve a RECIBE. Si no salta a la siguiente comparación
    MOVLW   0x30
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 3
    BCF     PORTB,0
    GOTO    RECIBE
    
    ; Compara si el dato es 1 si es cero entonces apaga el bit 1 del puerto B 
    ; y vuelve a RECIBE, si no solo vuelve a RECIBE
    MOVLW   0x31
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 2
    BSF     PORTB,0
    GOTO    RECIBE

CONFIG_INICIAL:
    ; Cambio al banco 1
    BSF     STATUS,RP0  
    BCF     STATUS,RP1
    
    BSF     TXSTA,BRGH  ; Configura la bandera BRGH para alta velocidad

    ; Establece el baudrate en 9600 baudios.
    MOVLW   0x81        
    MOVWF   SPBRG

    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    CLRF    TRISB       ; Configura el Puerto B como salida.

    BCF     STATUS,RP0  ;Cambia al banco 0

    BSF     RCSTA,SPEN  ; Habilita el puerto serie
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.

    CLRF    PORTB

    RETURN
    
    END
    
    
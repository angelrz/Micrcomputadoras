	;PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>

CHR EQU 0x20

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
    
    CALL    CONFIG_INICIAL
    
RECIBE:

    ; Comprueba si ya se recibieron datos
    BTFSS   PIR1,RCIF   
    GOTO    RECIBE
    
    ; Lee el dato Recibido, lo guarda en el registro CHR
    MOVFW   RCREG
    MOVWF   CHR
    
    ; Compara si el dato es S
    MOVLW   0x53
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 5
    ; Apaga los motores
    CLRF    PORTD
    CLRF    PORTB
    BCF     PORTB,0
    GOTO    RECIBE


    ; Para todos los demas casos, enciende los motores.
    MOVLW   0x06
    MOVWF   PORTD
    
    ; Compara si el dato es A
    MOVLW   0x41
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
    ; Ambos motores a la derecha
    MOVLW   0x06
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es T
    MOVLW   0x44
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
     ; Ambos motores a la izquierda
    MOVLW   0x0A
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es D
    MOVLW   0x54
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
    ; motor 1 derecha, motor 2 izquierda
    MOVLW   0x09
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es I
    MOVLW   0x69
    XORWF   CHR,W
    BTFSC   STATUS,Z
    GOTO    $ + 4
    ; motor 1 izquierda, motor 2 derecha
    MOVLW   0x05
    MOVWF   PORTB
    GOTO    RECIBE

CONFIG_INICIAL:
    ; Cambio al banco 1
    BSF     STATUS,RP0  
    BCF     STATUS,RP1
    BSF     TXSTA,BRGH  ;  Configura la bandera BRGH para alta velocidad.

    ;   Establece el baudrate en 9600 baudios.
    MOVLW   0x81        
    MOVWF   SPBRG

    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    CLRF    TRISB       ; Puerto B como salida.
    CLRF    TRISD       ; Puerto D como salida
    BCF     STATUS,RP0
    BSF     RCSTA,SPEN  ; Habilita el puerto serie
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.
    CLRF    PORTB
    CLRF    PORTD
    RETURN
    
    END
    
    
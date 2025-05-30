	;PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
	
OFFSET  EQU 0x20
	
	ORG 0
	GOTO INICIO
	ORG 5
	
; Genera una "tabla" con los caracteres a transmitir. Esto lo hace generando una
; serie de instrucciones RETLW cada una con un caracter de la cadena.
; Para devolver el caracter correspondiente se le suma el valor de W a el program counter.
; El valor de W debe tener la posición (OFFSET) del caracter que se desea recuperar. 
HOLA_PUMAS:        
    ADDWF   PCL,F
    DT      "HOLA PUMAS!",'\n',0x00 ; Cadena con el mensaje a transmitir "HOLA PUMAS!\n0".
	
INICIO:
    CALL    CONFIG_INICIAL ; Rutina para configuración de puertos
    
LOOP:
    CLRF    OFFSET      ; Establece el offset para la cadena en 0

PRINT_STR:
    ; Carga la posición del caracter a imprimir y llama a la rutina "hello world", revisa
    ; Si el valor devuelto es 0 (valor que indica el final de la cadena). Si es 0 se vuelve a 
    ; LOOP para resetear el offset
    MOVFW   OFFSET      ; Mueve el offset a W
    CALL    HOLA_PUMAS ; Obtiene el caracter de la tabla con el offset
    IORLW   0x00        ; Comprueba si no es 0 mediante un OR
    BTFSC   STATUS,Z    
    GOTO    LOOP        ; Si es 0, repite el loop desde el inicio.

    ; Mueve el caracter al registro de transmision, incrementa el offset para tomar el 
    ; siguiente caracter de la cadena.
    MOVWF   TXREG       ; Mueve el caracter obtenido a TXREG
    CALL    TRANSMITE   ; Transmite el caracter por TX
    INCF    OFFSET      ; Incrementa en 1 el offset
    GOTO    PRINT_STR   
    GOTO    LOOP
    

TRANSMITE:
    ; Transmite el caracter por el puerto serie
    BSF     STATUS,RP0  ; Cambio del banco 1 para el registro de transmision
    BTFSS   TXSTA,TRMT  ; Comprueba si ya se transmitio el dato
    GOTO    $ - 1
    BCF     STATUS,RP0  ; Regresa al banco 0
    RETURN

CONFIG_INICIAL:
    BSF     STATUS,RP0
    BCF     STATUS,RP1
    BSF     TXSTA,BRGH  ; Configura la bandera BRGH para alta velocidad

    ; Establece el baudrate en 9600 baudios.
    MOVLW   0x81        
    MOVWF   SPBRG
    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    BCF     STATUS,RP0
    BSF     RCSTA,SPEN  ; Habilita el puerto serie
    RETURN
    
    END
    
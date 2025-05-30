    ;processor 16f877             
    include <p16f877.inc>

    ORG 0       ; vector de reset
    GOTO inicio                  
    ORG 5               
        
inicio:
    ; Configuración del USART
    BSF STATUS, RP0             ; Cambia y asegura que estamos en banco 1
    BCF STATUS, RP1        
    BSF TXSTA, BRGH             ; Alta velocidad de transmisión
    MOVLW D'129'                ; Valor para 9600 baudios (20 MHz)
    MOVWF SPBRG                 ; Cargar valor al registro del baud rate
    BCF TXSTA, SYNC             ; Modo asincrónico
    BSF TXSTA, TXEN             ; Habilita el transmisor

    BCF STATUS, RP0             ; Cambia al banco 0
    BSF RCSTA, SPEN             ; Habilita el puerto serial (RX/ TX)
    BSF RCSTA, CREN             ; Habilita recepción continua

recibe:
    BTFSS PIR1, RCIF            ; ¿Dato recibido?
    GOTO recibe                 ; Si no, espera
    MOVF RCREG, W               ; Mueve el dato recibido al registro W
    MOVWF TXREG                 ; Envia el dato por el transmisor (eco)

transmite:
    BSF STATUS, RP0             ; Cambia al banco 1
    BTFSS TXSTA, TRMT           ; ¿Transmisor listo?
    GOTO transmite              ; Si no, espera
    BCF STATUS, RP0             ; Cambia al banco 0
    GOTO recibe                 ; Regresa a recibir otro dato
    END                         ; Fin del programa

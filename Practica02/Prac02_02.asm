PROCESSOR 16f877
#include <p16f877.inc>

MINIMO EQU H'40'   ; direccion en la que almacenamos el valor minimo

    ORG 0         
    GOTO INICIO   

    ORG 5         

INICIO:
    MOVLW 0X20    ; Se carga W con 0x20
    MOVWF FSR     ; Se mueve el apuntador FSR a la dirección 0x20
    MOVF INDF,W   ; W <- (FSR)
    MOVWF MINIMO  ; Movemos el contenido de la direccion de inicio a donde almacenamos el minimo

LOOP:
    INCF FSR      ; Se incrementa el apuntador FSR
    MOVF MINIMO,W ; Se obtiene el valor del apuntador W <- (MINIMO)
    SUBWF INDF,W  ; Se realiza la resta entre el valor actual y el mínimo: W <- W - (FSR)
    BTFSS STATUS,C ; Se analiza si A < B, A = B o A > B
    GOTO ES_MENOR ; Si es menor, se realiza el cambio.

    ; En caso contrario se analiza si todavía no se llega a la posición final
    BTFSS FSR,6   ; Se revisa si el bit 6 de FSR está seteado (se ha llegado a cierta dirección)
    GOTO LOOP
    GOTO FINAL

ES_MENOR:
    MOVF INDF,W   ; W <- (FSR)
    MOVWF MINIMO  ; (MINIMO) <- W
    GOTO LOOP

FINAL:
    END

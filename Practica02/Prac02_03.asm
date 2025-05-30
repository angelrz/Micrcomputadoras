PROCESSOR 16f877A
#include <p16f877A.inc>


TEMP EQU H'40'  ; Direccion donde almacenamos el valor a comparar con el siguiente


    ORG 0      
    GOTO INICIO 

    ORG 5       

INICIO:
    MOVLW 0X20  ; Cragamos W con el primer registro a ordenar con Bubble Sort
    MOVWF FSR   ; Se mueve el apuntador FSR a la dirección 0x20

BUBBLE_SORT:
    MOVF INDF,W ; W <- (FSR)
    MOVWF TEMP  ; Temporal tiene el valor de FSR
    INCF FSR    ; Se incrementa el apuntador FSR -> FSR + 1
    BTFSS FSR,4 ; 
    GOTO CONTINUAR
    GOTO INICIO

CONTINUAR:
    SUBWF INDF,0  ; Se realiza la resta de tal modo que: W <- FSR + 1 - FSR
    BTFSS STATUS,C ; Se analiza si A < B, A = B o A > B
    GOTO CAMBIO    ; Si es menor, se realiza el cambio

    GOTO BUBBLE_SORT    ; En caso contrario se sigue con el proceso

CAMBIO:
    MOVF INDF,W  ; W <- (FSR + 1)  ; El contenido de FSR + 1 se pasa a W
    DECF FSR     ; FSR <- FSR - 1  ; Desplazamos de FSR + 1 a FSR para cambiar los valores
    MOVWF INDF   ; (FSR) <- W
    INCF FSR     ; FSR <- FSR + 1  ; Se regresa a FSR + 1
    MOVF TEMP,W  ; Se recupera el valor de FSR : W <- (TEMP)
    MOVWF INDF   ; (FSR) <- W  ; Se hace el cambio
    GOTO BUBBLE_SORT  ; Se sigue con el algoritmo

END

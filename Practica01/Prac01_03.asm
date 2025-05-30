PROCESSOR 16f877
INCLUDE <p16f877.inc>

J equ H'26'   ; Para almacenar el primer operando
K equ H'27'   ; Para almacenar el Segundo operando
C1 equ H'28'  ; Bandera de acarreo
R1 equ H'29'  ; Resultado

ORG 0
    GOTO INICIO

ORG 5
INICIO:
    CLRF C1          
    MOVF J, W        
    ADDWF K, W      
    MOVWF R1         
    BTFSC STATUS, C  
    BSF C1, 0        
    GOTO INICIO

END

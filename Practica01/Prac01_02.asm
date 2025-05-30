PROCESSOR 16f877
INCLUDE <p16f877.inc>
K equ H'26'
L equ H'27'
M equ H'28' ; las usaremos como registris de ram
ORG 0
 GOTO INICIO
 ORG 5
INICIO: MOVF K,W
 ADDWF L,0
 MOVWF M
 GOTO INICIO
 END
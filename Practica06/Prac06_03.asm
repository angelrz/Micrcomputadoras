;PROCESSOR 16f877a
INCLUDE <p16f877a.inc>

;Registros para guardar las lecturas de los canales analógicos
ACH0    EQU     0x20
ACH1    EQU     0x21
ACH2    EQU     0x22

;Variables para los retardos
valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43
    
    ORG 0
    GOTO INICIO
    ORG 5

INICIO:
    CALL    CONFIG_INICIAL
    ; Selecciona el canal 5
    MOVLW   0xE9
    MOVWF   ADCON0
    CALL    RET_200us

LOOP:
;Lectura de los 3 canales (5, 6 ,7 )conectados a los potenciometros
;Los resultados se guardan en las variables ACH0, ACH1, ACH2
    ;Cambia al canal 5
    MOVLW   0xED    ;11 101 101
    MOVWF   ADCON0
    CALL    RET_200us
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1       ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH0
    
    ; Cambia al canal 6
    MOVLW   0xF5
    MOVWF   ADCON0
    CALL    RET_200us
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1       ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH1
    
    ; Cambia al canal 7
    MOVLW   0xFD
    MOVWF   ADCON0
    CALL    RET_200us
    
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1   ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH2
    
;Comparacion de las lecturas del CAD    
CASE1:
    ;Se revisa si ACH0 es mayor que las otras dos lecturas (ACH0 > ACH1 AND ACH2)
    ;Si en alguno de los casos es menor se cambia al Caso 2
    MOVFW   ACH1
    SUBWF   ACH0,W      ;W = ACH0 - ACH1
    BTFSS   STATUS,C    ;ACH0 > ACH1?
    GOTO CASE2          ;FALSE (ACH0 < ACH1)
    MOVFW   ACH2        
    SUBWF   ACH0,W      ;W = ACH0 - ACH2
    BTFSS   STATUS,C    ;ACH0 > ACH2?
    GOTO CASE2          ;FALSE (ACH0 < ACH1)
    
    ;Si es mayor se despliega 1 en el display.
    MOVLW   0x01
    MOVWF   PORTD
    GOTO LOOP
    
    
CASE2:
    ;Se revisa si ACH0 es mayor que las otras dos lecturas (ACH1 > ACH0 AND ACH2)
    ;Si en alguno de los casos es menor se cambia al Caso 3
    MOVFW   ACH0
    SUBWF   ACH1,W
    BTFSS   STATUS,C
    GOTO CASE3
    MOVFW   ACH2
    SUBWF   ACH1,W
    BTFSS   STATUS,C
    GOTO CASE3
    MOVLW   0x02
    MOVWF   PORTD
    GOTO LOOP

CASE3:
    ; ACH2 > ACH0 AND ACH1, se sabe que ACH2 es mayor, por lo tanto no
    ;se hacen más comparaciones.
    MOVLW   0x03
    MOVWF   PORTD
    GOTO LOOP
        
CONFIG_INICIAL:
	BCF     STATUS,RP1
	BSF     STATUS,RP0
    ;configuracion de pines del puerto D como salida
	CLRF    TRISD
	;Todos los canales como entradas analógicas, resultado justificado
	;A la izquierda
    CLRF    ADCON1
	BCF     STATUS,RP0
    ; Establece la frecuencia de muestreo como la interna del pic
    MOVLW   0xC0    
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


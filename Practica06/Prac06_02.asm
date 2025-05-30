;PROCESSOR 16f877a
INCLUDE <p16f877a.inc>

;Variables para los retardos
valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43

;Constantes, cada uno corresponde con el límite superior de cada uno de los
;Rangos solicitados, por ejemplo para el primer rango el límite es, 50 * 19.6[mV] = .98[V]
RANGO0 equ 0x32		;
RANGO1 equ 0x66
RANGO2 equ 0x99
RANGO3 equ 0xCA
RANGO4 equ 0xF5
RANGO5 equ 0xFF
RESULT equ 0x26 

    ORG 0
    GOTO INICIO
    ORG 5

INICIO:
    CALL    CONFIG_INICIAL
	; Seleccionar el canal 5
    MOVLW   0xE9        
    MOVWF   ADCON0
	MOVLW 	0x00

;Ciclo principal:  Lee el valor del CAD, compara el resultado con los valores de los rangos
;Cuando encuentre el rango en el que se encuentra el valor, lo imprime en el display.
LOOP:
	;Mueve el contenido de W al puerto D
	MOVWF PORTD	

	;Subrutina para lectura del CAD
	CALL READ_PORT

	;Compara la lectura con el valor límite del rango 0 (ADRESH == 0X32?), si es menor o igual
	;Carga un cero al registro W y va al inicio del ciclo principal
	MOVLW	RANGO0
	SUBWF	RESULT, W 	;W = RESULT - RANGO0
	BTFSC	STATUS,C	;RESULT < RANGO0?
	GOTO 	COMP2 	
	MOVLW 0X00		;Despliega un 0
	GOTO LOOP	

;Compara la lectura con el valor límite del rango 1
COMP2
	MOVLW	RANGO1
	SUBWF	RESULT, W 
	BTFSC	STATUS,C
	GOTO 	COMP3 	
	MOVLW 0X01
	GOTO LOOP

;Compara la lectura con el valor límite del rango 2. 
COMP3
	MOVLW	RANGO2
	SUBWF	RESULT, W 
	BTFSC	STATUS,C
	GOTO 	COMP4 	
	MOVLW 0X02
	GOTO LOOP

;Compara la lectura con el valor límite del rango 3. 
COMP4
	MOVLW	RANGO3
	SUBWF	RESULT, W 
	BTFSC	STATUS,C
	GOTO 	COMP5 	
	MOVLW 0X03
	GOTO LOOP		
;Compara la lectura con el valor límite del rango 4. 
COMP5
	MOVLW	RANGO4
	SUBWF	RESULT, W 
	BTFSC	STATUS,C
	GOTO 	COMP6 	
	MOVLW 0X04
	GOTO LOOP

;Si el resultado no se encuentra en los rangos anteriores, entonces es mayor 
;a 4.80 y se despliega 5
COMP6
	MOVLW 0X05		
	GOTO LOOP

READ_PORT:
	MOVLW   0x04
    IORWF   ADCON0,F    ; Enciende ADON y la bandera GO/DONE
    CALL    RET_200us
WAIT:
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO   	WAIT   		; Espera a la lectura
    MOVFW   ADRESH
	MOVWF   RESULT
	RETURN

;Rutina de configuracion y otros registros necesarios para el ejercicios
CONFIG_INICIAL:
	BCF     STATUS,RP1
	BSF     STATUS,RP0
	;configuracion de pines del puerto D como salidas
	CLRF    TRISD
	;Todos los canales como entradas digitales, resultado justificado
	;A la izquierda
    CLRF    ADCON1
	BCF     STATUS,RP0
    ;Frecuencia de muestreo usando el reloj interno, Canalo analógico 5 (AN5)
    MOVLW   0xE9    
    MOVWF   ADCON0  
	;Limpia el puerto D
	CLRF    PORTD
	RETURN

;Rutina de retardo de 200 microsegundos
RET_200us:
	MOVLW   0x02
	MOVWF   valor1
	MOVLW   0xA4
	MOVWF   valor2
	DECFSZ 	valor2
	GOTO 	$ - 1
	DECFSZ 	valor1
	GOTO 	$ - 5
	RETURN
    END

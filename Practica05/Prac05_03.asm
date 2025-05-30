PROCESSOR 16F877
	INCLUDE <P16F877.INC>
	
VALOR1 EQU H'20'	; Variables para los retardos
VALOR2 EQU H'52'
VALOR3 EQU H'53'
CTE1 EQU 03H
CTE2 EQU .2			; multiplicadores para ajustar el tiempo
CTE3 EQU .82
TIEMPO	EQU 20H		; almacena duración del pulso PWM

RESET:
	ORG 0			; vector de reset
	GOTO INICIO		; salto a inicio del programa
	ORG 5

INICIO:
	CLRF PORTA		; limpiar PORTA
	BSF STATUS,RP0	; cambio al Banco 1
	BCF STATUS,RP1	
	MOVLW H'0'		
	MOVWF TRISC		; configura PORTC como salidas (control del servo)
	CLRF PORTC		
	MOVLW H'6'		
	MOVWF ADCON1	; configura entradas digitales
	MOVLW H'3F'	
	MOVWF TRISA		; configura PORTA como entradas (para switches)
	BCF STATUS, RP0	; regreso al Banco 0

CICLO:
	MOVLW 0X04		; compara PORTA con 0x04 (100 binario = SW2 activo)
	SUBWF PORTA, W	
	BTFSS STATUS, Z	; si son iguales, Z=1 y salta
	GOTO GIRO_90_0	; si no son iguales, verifica siguiente posición

; servo a 0 grados (izquierda) - pulso de 1ms
GIRO_0:
	MOVLW 0X01		
	MOVWF PORTC		; activa PORTC (inicia pulso PWM)
	MOVLW .4		; carga 4 para generar 1ms
	MOVWF TIEMPO	
	CALL RETARDO	
	CLRF PORTC		; desactiva PORTC (termina pulso PWM)
	MOVLW .180		; carga 180 para completar periodo de 20ms 
	MOVWF TIEMPO	
	CALL RETARDO	
	GOTO CICLO		

; verifica si es posición 90 grados
GIRO_90_0:
	MOVLW 0X02		; compara PORTA con 0x02 (010 binario = SW1 activo)
	SUBWF PORTA, W	
	BTFSS STATUS, Z	; si son iguales, Z=1 y salta
	GOTO COMP_180	; si no son iguales, verifica la última posición

; servo a 90 grados (centro) - pulso de 1.5ms
GIRO_90:
	MOVLW 0X01		
	MOVWF PORTC		; activa PORTC (inicia pulso PWM)
	MOVLW .15		; carga 15 para generar 1.5ms
	MOVWF TIEMPO	
	CALL RETARDO	
	CLRF PORTC		; desactiva PORTC (termina pulso PWM)
	MOVLW .185		; carga 185 para completar periodo de 20ms
	MOVWF TIEMPO	
	CALL RETARDO	
	GOTO CICLO		

; verifica si es posición 180 grados
COMP_180:
	MOVLW 0X01		; compara PORTA con 0x01 (001 binario = SW0 activo)
	SUBWF PORTA, W	
	BTFSS STATUS, Z	; si son iguales, Z=1 y salta
	GOTO CICLO		; si ningún caso coincide, vuelve al ciclo principal

; servo a 180 grados (derecha) - pulso de 2ms
GIRO_180:
	MOVLW 0X01		
	MOVWF PORTC		; activa PORTC (inicia pulso PWM)
	MOVLW .25		; carga 25 para generar 2ms
	MOVWF TIEMPO	
	CALL RETARDO	
	CLRF PORTC		; desactiva PORTC (termina pulso PWM)
	MOVLW .190		; carga 190 para completar periodo de 20ms
	MOVWF TIEMPO	
	CALL RETARDO	
	GOTO CICLO		

; subrutina de retardo - genera demora según valor en "tiempo"
RETARDO: 
    MOVF TIEMPO, W	; carga valor de tiempo en W
	MOVWF VALOR1	; inicializa contador principal
     
TRES: 
     MOVLW CTE2		; carga constante para bucle secundario
     MOVWF VALOR2	

DOS:
     MOVLW CTE3		; carga constante para bucle terciario
     MOVWF VALOR3	

UNO:
     DECFSZ VALOR3	; decrementa y salta si es cero (bucle interno)
     GOTO UNO		
     DECFSZ VALOR2	; decrementa y salta si es cero (bucle medio)
     GOTO DOS		
     DECFSZ VALOR1	; decrementa y salta si es cero (bucle externo)
     GOTO TRES		
     RETURN			; fin del retardo

END

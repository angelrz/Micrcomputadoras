;PROCESSOR 16F877A
INCLUDE <P16F877A.INC>

VALOR1 equ h'21'          ; Variables para los retardos
VALOR2 equ h'22'
VALOR3 equ h'23'
DIR1 equ h'24'            ; Contadores para control de vueltas
DIR2 equ h'25'
CTE1 equ 10h              ; Constantes para ajustar tiempos de retardo
CTE2 equ 10h
CTE3 equ 10h

; Vector de RESET
	ORG 0                     ; Vector de reset
	    GOTO INICIO
	ORG 5

INICIO:                   
    CLRF PORTB            ; Limpia puerto B (salidas al motor)
    CLRF PORTA            ; Limpia puerto A (entradas)
    BSF STATUS, RP0       ; Cambio al banco 1
    BCF STATUS, RP1
    MOVLW 06H             ; Configura puertos digitales
    MOVWF ADCON1
    MOVLW H'3F'           ; Configura puerto A como entradas
    MOVWF TRISA
    MOVLW B'00000000'     ; Configura puerto B como salidas
    MOVWF TRISB
    BCF STATUS, RP0       ; Regresa al banco 0

LOOP:
    MOVF PORTA, W         ; Lee valor de entrada del puerto A
    ANDLW 7               ; para obtener solo bits 0-2
    ADDWF PCL, F          ; Salto basado en valor
    GOTO CASO0            ; 0x00: Motor en paro
    GOTO CASO1            ; 0x01: Giro horario
    GOTO CASO2            ; 0x02: Giro antihorario
    GOTO CASO3            ; 0x03: 5 vueltas horarias
    GOTO CASO4            ; 0x04: 10 vueltas antihorarias
    GOTO DEFAULT          ; Casos por defecto
    GOTO DEFAULT
    GOTO DEFAULT

CASO0:                    ; Motor detenido
    CLRF PORTB            ; Apaga todas las bobinas
    GOTO LOOP

CASO1:                    ; Giro continuo horario
    CALL HORARIO          ; Llama subrutina de paso horario
    GOTO LOOP

CASO2:                    ; Giro continuo antihorario
    CALL ANTIHORARIO      ; Llama subrutina de paso antihorario
    GOTO LOOP

CASO3:                    ; 5 vueltas en sentido horario
    MOVLW 15              ; Contador para 5 vueltas
    MOVWF DIR1

LOOP1:                    ; Control de número de vueltas
    DECFSZ DIR1, 1        ; Decrementa contador de vueltas
    GOTO VUELTA           ; Si no es cero, da otra vuelta
    CALL RETARDO            ; Retardo adicional al finalizar
    CALL RETARDO
    GOTO LOOP             ; Regresa al bucle principal

VUELTA:                   ; Una vuelta completa en horario
    MOVLW 80h             ; 128 pasos = vuelta completa
    MOVWF DIR2

LOOP2:                    ; Control de pasos por vuelta
    CALL HORARIO          ; Da un paso horario
    DECFSZ DIR2, 1        ; Decrementa contador de pasos
    GOTO LOOP2            ; Si no es cero, da otro paso
    GOTO LOOP1            ; Regresa a contador de vueltas

CASO4:                    ; 10 vueltas en sentido antihorario
    MOVLW 29              ; Contador para 10 vueltas
    MOVWF DIR1

LOOP3:                    ; Control de vueltas (similar a CASO3)
    DECFSZ DIR1, 1
    GOTO VUELTA2
    CALL RETARDO
    CALL RETARDO
    GOTO LOOP

VUELTA2:                  ; Una vuelta completa en antihorario
    MOVLW 80h             ; 128 pasos = vuelta completa
    MOVWF DIR2

LOOP4:                    ; Control de pasos por vuelta
    CALL ANTIHORARIO      ; Da un paso antihorario
    DECFSZ DIR2, 1
    GOTO LOOP4
    GOTO LOOP3

DEFAULT:                  ; Caso por defecto
    GOTO LOOP

; Subrutina de retardo
RETARDO:
    MOVLW CTE1
    MOVWF VALOR1     ; Primer nivel (mas lento)
TRES:
    MOVLW CTE2
    MOVWF VALOR2     ; Segundo nivel
DOS:
    MOVLW CTE3
    MOVWF VALOR3     ; Tercer nivel (mas rapido)
UNO:
    DECFSZ VALOR3,F  ; Bucle interno
    GOTO UNO
    DECFSZ VALOR2,F  ; Bucle medio
    GOTO DOS
    DECFSZ VALOR1,F  ; Bucle externo
    GOTO TRES
    RETURN           ; Fin del retardo

HORARIO:                  ; Secuencia para giro horario (4 pasos)
    CLRF PORTB                
    MOVLW B'10000000'     ; Activa bobina 1 (PORTB.7)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'01000000'     ; Activa bobina 2 (PORTB.6)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'00100000'     ; Activa bobina 3 (PORTB.5)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'00010000'     ; Activa bobina 4 (PORTB.4)
    MOVWF PORTB
    CALL RETARDO
    RETURN

ANTIHORARIO:              ; Secuencia para giro antihorario (4 pasos)
    CLRF PORTB
    MOVLW B'00010000'     ; Secuencia inversa: bobina 4 (PORTB.4)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'00100000'     ; Bobina 3 (PORTB.5)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'01000000'     ; Bobina 2 (PORTB.6)
    MOVWF PORTB
    CALL RETARDO
    MOVLW B'10000000'     ; Bobina 1 (PORTB.7)
    MOVWF PORTB
    CALL RETARDO
    RETURN

END                       ; Fin del programa

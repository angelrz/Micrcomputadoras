; ** PROGRAMA EJEMPLO1_INTFLPTA0 (MODIFICADO PARA PROYECTO 9 FINAL - HEXADECIMAL) **
; ** Basado en el archivo ejemplo1_intflpta0.asm **
; ** Por: Antonio Salva Calleja
; ** 6/abril/2020
; ** Modificado para cumplir los requisitos del Proyecto 9
; ** Por: Daniel Lopez Campillo

;--- Definiciones de Registros ---
;Puerto A (para interrupcion en PA3)
;Port A Pull Enable Register. Usado para habilitar resistencias pull-up/pull-down en los pines del Puerto A.
ptape equ $1840
;Port A Interrupt Status and Control Register. Controla y reporta el estado de las interrupciones del Puerto A.
ptasc equ $1844
;Port A Interrupt Pin Select Register. Selecciona cuales pines del Puerto A pueden generar interrupciones.
ptaps equ $1845
;Port A Interrupt Edge Select Register. Configura la polaridad del flanco para las interrupciones del Puerto A.
ptaes equ $1846
;Port A Data Register. Contiene los datos de los pines del Puerto A.
ptad equ $00
;Port A Data Direction Register. Configura la direccion (entrada/salida) de los pines del Puerto A.
ptadd equ $01

;Puerto C (para salida en PC3)
;Port C Data Register. Contiene los datos de los pines del Puerto C.
PTCD equ $04
;Port C Data Direction Register. Configura la direccion (entrada/salida) de los pines del Puerto C.
PTCDD equ $05

;Directiva del ensamblador para indicar que el siguiente codigo se ensamblara
;a partir de la direccion de memoria $8000. Esta es una direccion comun para
;el inicio del codigo de usuario en la memoria FLASH del MC9S08SH32.
  org $8000

  lda #$21
  sta $1802

;****************** BLOQUE 1 ******************
; ** Configuracion inicial del MCU, incluyendo la salida PC3 y la interrupcion en PA3.

;Configura el pin PC3 (bit 3 del Puerto C) como salida.
;Esto se logra poniendo a 1 el bit 3 en el Port C Data Direction Register (PTCDD).
  bset 3,PTCDD

; ** Configuracion de Interrupcion para PA3 (en lugar de PA0) **
;Configura el pin PA3 (bit 3 del Puerto A) como entrada.
;Esto se logra poniendo a 0 el bit 3 en el Port A Data Direction Register (PTADD).
  bclr 3,ptadd

;Habilita la resistencia de pull-up interna para el pin PA3.
;Carga el valor actual de Port A Pull Enable Register (PTAPE).
  lda ptape
;Realiza una operacion OR con el valor inmediato #$08 (%00001000).
;Esto pone a 1 el bit 3 (PTAPE3) sin afectar otros bits, habilitando el pull-up para PA3.
  ora #$08
;Guarda el nuevo valor en PTAPE.
  sta ptape

;Selecciona el pin PA3 para que pueda generar una interrupcion de pin.
;Carga el valor actual de Port A Interrupt Pin Select Register (PTAPS).
  lda ptaps
;Realiza una operacion OR con el valor inmediato #$08 (%00001000).
;Esto pone a 1 el bit 3 (PTAPS3) sin afectar otros bits, seleccionando PA3.
  ora #$08
;Guarda el nuevo valor en PTAPS.
  sta ptaps

;Configura la interrupcion del pin PA3 para que se active por flanco de bajada.
;Carga el valor actual de Port A Interrupt Edge Select Register (PTAES).
  lda ptaes
;Realiza una operacion AND con el valor inmediato #$F7 (%11110111).
;Esto pone a 0 el bit 3 (PTAES3) sin afectar otros bits. PTAESn=0 selecciona flanco de bajada.
  and #$F7
;Guarda el nuevo valor en PTAES.
  sta ptaes

; ** Se habilita el habilitador local de interrupcion del Puerto A (ptaie),sin que se modifiquen los demas
; ** bits del registro ptasc (PTAMOD se asume 0 por defecto para edge-only).
;Carga el valor actual de Port A Interrupt Status and Control Register (PTASC).
  lda ptasc
;Realiza una operacion OR con el valor inmediato #$02 (%00000010).
;Esto pone a 1 el bit 1 (PTAIE) para habilitar las interrupciones del Puerto A.
  ora #$02
;Realiza una operacion AND con el valor inmediato #$FE (%11111110).
;Esto pone a 0 el bit 0 (PTAMOD) para asegurar deteccion solo por flanco (edge-only).
;PTAMOD=0 para edge-only, PTAMOD=1 para edge and level.
  and #$FE
;Guarda el nuevo valor en PTASC.
  sta ptasc
;...........................................................................

;**** Se regresa a cero la bandera testigo de la instancia de interrupcion del Puerto A (PTAIF)
;**** esto se hace aqui,para evitar invocacion de la interrupcion debido a un flanco
;**** que se pudiera haber presentado antes de la ejecucion de la instruccion CLI.
;Carga el valor actual de PTASC.
  lda ptasc
;Realiza una operacion OR con el valor inmediato #$04 (%00000100).
;Esto pone a 1 el bit 2 (PTAACK - Port A Interrupt Acknowledge).
;Escribir un 1 en PTAACK limpia la bandera PTAIF (bit 3 de PTASC).
  ora #$04
;Guarda el nuevo valor en PTASC, limpiando efectivamente PTAIF.
  sta ptasc
;..................................................................................

;Habilita globalmente las interrupciones.
;Pone a 0 el bit I (Interrupt Mask) en el Condition Code Register (CCR).
  cli

;**************** FIN DEL BLOQUE 1 ***************

;****************** BLOQUE 2 ******************
; ** Bucle principal del programa - CICLO BASICO.
; ** Este bucle genera una senal periodica en PC3.
; ** El ciclo es 900ms en estado ALTO y 100ms en estado BAJO.

;Etiqueta para el inicio del bucle principal.
lazo:  bset 3,PTCD
;Llama a la subrutina de retardo 'ret900ms'.
;Esta subrutina generara una pausa de aproximadamente 900 milisegundos.
       bsr ret900ms

;Pone el pin PC3 (bit 3 del Puerto C) en estado BAJO (0).
;Asumiendo una configuracion de LED con anodo comun, esto encenderia el LED.
       bclr 3,PTCD
;Llama a la subrutina de retardo 'ret100ms'.
;Esta subrutina generara una pausa de aproximadamente 100 milisegundos.
       bsr ret100ms

;Salta incondicionalmente de regreso a la etiqueta 'lazo'.
;Esto crea un bucle infinito que repite la secuencia ALTO/BAJO.
       bra lazo

;**************** FIN DEL BLOQUE 2 ***************

;****************** BLOQUE 3 ******************
; ** Rutina de Servicio de Interrupcion (ISR) y subrutinas de retardo.

;Etiqueta para el inicio de la Rutina de Servicio de Interrupcion (ISR) del Puerto A.
;Esta rutina se ejecuta cuando ocurre un flanco de bajada en PA3.
servfl: lda ptasc
;Realiza una operacion OR con #$04 para poner PTAACK (bit 2) a 1.
;Esto limpia la bandera PTAIF (bit 3 de PTASC). Es crucial hacer esto al inicio de la ISR.
        ora #$04
;Guarda el valor en PTASC.
        sta ptasc

; --- INICIO DE LOGICA ANTIRREBOTE ---
;Salva el contenido del registro H en la pila.
;La subrutina 'ret25ms' modifica H X.
        pshh
;Salva el contenido del registro X en la pila.
        pshx
;Salva el contenido del acumulador A en la pila.
;Buena practica si 'A' se usa despues de leer PTAD y su valor actual es importante.
        psha

;Llama a la subrutina de retardo 'ret25ms'.
;Espera aproximadamente 25ms para permitir que los rebotes mecanicos del
;interruptor (conectado a PA3) terminen antes de verificar el estado del pin.
        bsr ret25ms

;Restaura el valor original del acumulador A desde la pila.
        pula
;Restaura el valor original del registro X desde la pila.
        pulx
;Restaura el valor original del registro H desde la pila.
        pulh

;Verifica el estado del pin PA3 DESPUES del retardo antirebote.
;BRCLR 3,PTAD,proc_int_valida lee el bit 3 del Port A Data Register (PTAD).
;Si el bit 3 (PA3) es 0 (sigue BAJO, confirmando el flanco de bajada), salta a 'proc_int_valida'.
;Si el bit 3 es 1 (ALTO, fue un rebote), la instruccion no salta y se ejecuta la siguiente.
        brclr 3,PTAD,proc_int_valida

;Si PA3 no estaba en BAJO despues del debounce, se considera un rebote o ruido.
;Retorna de la interrupcion sin ejecutar la secuencia de interrupcion.
        rti

;Etiqueta para procesar una interrupcion valida (despues del antirebote).
;Secuencia de LED para la interrupcion PC3 ALTO (2s), BAJO (2s), ALTO (500ms), BAJO (500ms).
proc_int_valida: bset 3,PTCD
;Llama a la subrutina de retardo de 2 segundos.
                 bsr ret2s

;Pone PC3 en BAJO.
                 bclr 3,PTCD
;Llama a la subrutina de retardo de 2 segundos.
                 bsr ret2s

;Pone PC3 en ALTO.
                 bset 3,PTCD
;Llama a la subrutina de retardo de 500 milisegundos.
                 bsr ret500ms

;Pone PC3 en BAJO.
                 bclr 3,PTCD
;Llama a la subrutina de retardo de 500 milisegundos.
                 bsr ret500ms

;Retorna de la rutina de servicio de interrupcion.
;Restaura el estado del CPU (registros PC, A, X, CCR) desde la pila.
                 rti

;--- Subrutina de Retardo de 25ms (Original del ejemplo) ---
;Esta subrutina genera un retardo de aproximadamente 25 milisegundos.
;El calculo asume una frecuencia de bus de 20MHz y que el bucle interno toma 10 ciclos.
;(49997 iteraciones * 10 ciclos/iteracion * 50 ns/ciclo = 24.9985 ms).
ret25ms: pshh
;Salva el registro X en la pila, ya que se modificara.
         pshx
;Carga el par de registros H X con el valor hexadecimal $C34D (49997 decimal).
;Este valor actua como contador para el bucle de retardo.
         ldhx #$c34d
;Etiqueta para el bucle de retardo.
vuelta: nop
;Otra instruccion NOP. Consume 1 ciclo de bus.
        nop
;Anade el valor inmediato #$FF (-1 en complemento a dos) al registro indice H X.
;Efectivamente decrementa H X en 1. Consume 2 ciclos.
        aix #$FF
;Compara el contenido de H X con #$0000. No modifica H X.
;Actualiza los bits del CCR. Consume 3 ciclos.
        cphx #$0000
;Salta a la etiqueta 'vuelta' si el resultado de la comparacion anterior no fue cero (Z=0 en CCR).
;Consume 3 ciclos si el salto se toma.
        bne vuelta
;Instruccion NOP. Usada para ajuste fino del tiempo o como punto de interrupcion.
        nop
;Restaura el valor original del registro X desde la pila.
        pulx
;Restaura el valor original del registro H desde la pila.
        pulh
;Retorna de la subrutina.
        rts

;--- Subrutina de Retardo de 100ms ---
;Genera un retardo de aproximadamente 100ms llamando a 'ret25ms' 4 veces.
ret100ms: psha
;Carga el acumulador A con el valor 4 (numero de iteraciones).
          lda #$04
;Etiqueta para el bucle de 100ms.
loop_100ms: bsr ret25ms
;Decrementa el acumulador A.
            deca
;Salta a 'loop_100ms' si A no es cero.
            bne loop_100ms
;Restaura el valor original del acumulador A desde la pila.
            pula
;Retorna de la subrutina.
            rts

;--- Subrutina de Retardo de 500ms ---
;Genera un retardo de aproximadamente 500ms llamando a 'ret25ms' 20 veces.
;El valor $14 hexadecimal es 20 en decimal.
ret500ms: psha
          lda #$14
loop_500ms: bsr ret25ms
            deca
            bne loop_500ms
            pula
            rts

;--- Subrutina de Retardo de 900ms ---
;Genera un retardo de aproximadamente 900ms llamando a 'ret100ms' 9 veces.
ret900ms: psha
          lda #$09
loop_900ms: bsr ret100ms
            deca
            bne loop_900ms
            pula
            rts

;--- Subrutina de Retardo de 1 segundo ---
;Genera un retardo de aproximadamente 1 segundo (1000ms) llamando a 'ret25ms' 40 veces.
;El valor $28 hexadecimal es 40 en decimal.
ret1seg: psha
         lda #$28
;Etiqueta para el bucle de 1 segundo.
otro25m: bsr ret25ms
         deca
         bne otro25m
         pula
         rts

;--- Subrutina de Retardo de 2 segundos (2000ms) ---
;Genera un retardo de aproximadamente 2 segundos llamando a 'ret1seg' 2 veces.
ret2s: psha
       lda #$02
loop_2s: bsr ret1seg
         deca
         bne loop_2s
         pula
         rts

;**************** FIN DEL BLOQUE 3 ***************

;****************** BLOQUE 4 ******************
; ** Vector de interrupcion para VPortA, ajustado para la tarjeta FACIL_08SH_2.
; ** El MCU MC9S08SH32 en la tarjeta FACIL_08SH_2, cuando esta habilitado como
; ** dispositivo CHIPBAS8SH, puede utilizar una tabla de vectores reubicada.
; ** La direccion estandar para el vector VPortA es $FFD6-$FFD7 segun la hoja de datos del MCU.
; ** Sin embargo, para el sistema de desarrollo AIDA08SH_F2 o el entorno CHIPBAS8SH,
; ** esta direccion se reubica comunmente a $D7D6-$D7D7.

;Establece la direccion de ensamblaje para el vector de interrupcion del Puerto A.
  org $d7d6
;Define una palabra (Define Word, 2 bytes) en la direccion actual ($D7D6).
;Esta palabra contendra la direccion de inicio de la rutina de servicio de interrupcion 'servfl'.
  dw servfl

;**************** FIN DEL BLOQUE 4 ***************
  org $d7fe
  dw $8000
  
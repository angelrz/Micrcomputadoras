processor 16f877
include <p16f877.inc>

CONT        equ H'30'

            org     0
            goto    begin
            org     5

begin:
            clrf    CONT        ; CONT = 0

incl:
            incf    CONT, 1      ; CONT++

            movlw   H'09'        ; W = 0x09
            xorwf   CONT, 0      ; CONT xor W
            btfss   STATUS, Z    ; if(Z == 1) (Salta)
            goto    incl         ; else (repite el ciclo)
            movlw   H'10'        ; W = 0x10
            movwf   CONT         ; CONT = W

inc2:
            incf    CONT, 1      ; CONT++
            movlw   H'19'        ; W = 0x19
            xorwf   CONT, 0      ; CONT xor W
            btfss   STATUS, Z    ; if(Z == 1) (Salta)
            goto    inc2         ; else (repite el ciclo)
            movlw   H'20'        ; W = 0x20
            movwf   CONT         ; CONT = W
            goto    begin
end

PROCESSOR 16f877 
 INCLUDE  <p16f877.inc>    
 
  ORG 0 ;	Vector de reset
  GOTO  INICIO               
  ORG 5 
INICIO:   
  ;BCF STATUS,RP1 
  ;BSF STATUS,RP0 
  MOVLW 0X20 ; W <- 0X20
  MOVWF FSR ; fsr <- W
LOOP: 
  MOVLW 0X5F 
  MOVWF INDF ; INDF <- W
  INCF FSR ;FSR <- FSR +1
  BTFSS FSR,6 ;¿YA ACABE? BIT 6 DE FSR =1?, SI ES ASI, VA A GOTO $
  GOTO LOOP ;NO VE AL LOOP
  GOTO $ ; Salto a referenciado
END 
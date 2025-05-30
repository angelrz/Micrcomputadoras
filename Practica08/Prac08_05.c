// Author:        Edgar Moreno Chalico
// Descripci�n:   BLINK!!!!!!!!!!
// No se requiere configurar puertos.
// El ejecutable resultante es m�s grande
#include <16F877.h>
#fuses HS, NOWDT, NOPROTECT, NOLVP
#use delay(clock = 20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}
// #define use_portb_lcd //4 bits de datos
#include <lcd.c>

void main()
{
  lcd_init(); // Se inicializa el lcd.

  int cont = 0;

  while (TRUE)
  {
    lcd_gotoxy(1, 1); // Va a la columna 5, fila 1.
    printf(lcd_putc, " UNAM\n "); // Imprime desde (1,1)
    lcd_gotoxy(1, 2); // Va a la columna 5, línea 2.
    printf(lcd_putc, " F\n ", cont); // Imprime desde (1,2)
    delay_ms(300); // Espera 1500ms.
  }
}

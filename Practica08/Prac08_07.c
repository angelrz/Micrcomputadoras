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
  int prev_state = 0; // Variable para almacenar el estado previo del pin.

  while (TRUE)
  {
    if (input(PIN_A0) == 1 && prev_state == 0) // Detecta el cambio de 0 a 1 en el pin A0
    {
      cont++; // Se incrementa el contador solo una vez.
      prev_state = 1; // Actualiza el estado previo del pin.
    }
    else if (input(PIN_A0) == 0) // Si el pin A0 está en 0
    {
      prev_state = 0; // Se resetea el estado previo cuando el pin A0 vuelve a 0.
    }

    lcd_gotoxy(5, 1); // Va a la columna 5, fila 1.
    printf(lcd_putc, " %d \n ", cont); // Imprime el contador en decimal.
    lcd_gotoxy(5, 2); // Va a la columna 5, línea 2.
    printf(lcd_putc, " %02x \n ", cont); // Imprime el contador en hex.
    delay_ms(1500); // Espera 1500ms.
  }
}

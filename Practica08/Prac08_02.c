#include <16f877.h>
#fuses HS,NOPROTECT
#use delay(clock=20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}

void main()
{
   while (1)
   {
      output_b(0xFF); // Enciende los leds del puerto B
      delay_ms(1000); // Espera 1s 
      output_b(0x00); // Apaga todos los leds del puerto B
      delay_ms(1000); // Espera 1s
   }
}

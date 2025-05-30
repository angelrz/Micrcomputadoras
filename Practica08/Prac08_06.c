#include <16f877.h>
#fuses HS, NOPROTECT
#use delay(clock = 20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}
#use rs232(baud = 9600, xmit = PIN_C6, rcv = PIN_C7)
#define loop while (1)

void main()
{
  int shift; // Variable para el bit shift.
  int leds_on = 1; // Variable para el blink
  int i;           // Contador
  int dir = 0;
  char in; // Entrada al PIC por RX
  loop {
    if (kbhit() == 1) // Si recibe la entrada de una tecla,
      in = getc();    // la almacena en in.

    switch (in)
    {
    case '0': // Selección 0 apaga los leds.
      output_b(0x00);
      break;
    case '1': // Selección 1 enciende todos los leds.
      output_b(0xFF);
      break;
    case '2': // Selección 2 realiza 8 bit shifts a la derecha a 0x80.
      shift = 0x80;
      for (i = 0; i < 8; i++)
      {
        shift >>= 1;
        output_b(shift);
        delay_ms(200);
      }
      break;
    case '3': // Selección 3 hace 8 bit shifts a la izquierda a 0x01
      shift = 0x01;
      for (i = 0; i < 8; i++)
      {
        shift <<= 1;
        output_b(shift);
        delay_ms(200);
      }
      break;
    case '4': // Selección 4 hace recorridos de izquierda a derecha y
              // viceversa.
      shift = 0x80;
      dir = 0;
      for (i = 0; i < 16; i++)
      {
        if (dir <= 8 && dir == 0)
          dir = 1;
        
        if (dir == 0)
          shift >>= 1;
        else
          shift <<= 1;;

        output_b(shift);
        delay_ms(200);
      }
      break;
    case '5': // Selección 5 ejecuta un blink.
      leds_on = leds_on == 0 ? 0xFF : 0;
      output_b(leds_on);
      delay_ms(500);
      break;
    }
  }
}

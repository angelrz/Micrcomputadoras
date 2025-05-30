#include <16f877.h>
#fuses HS,NOPROTECT
#use delay(clock=20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}

void main()
{
   int var1;

   while (1)
   {
      var1 = input_a(); // Recibe la entrada de A
      output_b(var1); // Redirige el valor de A al puerto B
   }
}


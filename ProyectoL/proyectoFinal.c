//------------------------ DECLARACION DE LIBRERIAS Y CONFIGURACIONES ------------------------

#include <16F877A.h>                   // Libreria del microcontrolador PIC16F877A
#device ADC = 10                       // Configura el ADC a 10 bits (0 a 1023)
#use delay(clock = 4000000)           // Frecuencia del reloj de sistema: 4 MHz
#use rs232(baud = 9600, xmit = PIN_C6, rcv = PIN_C7) // Configuracion del puerto serie (UART)

//---------------------- DEFINICION DE PINES PARA LCD Y BOTONES ------------------------------

#define LCD_ENABLE_PIN PIN_D6
#define LCD_RS_PIN PIN_D7
#define LCD_DATA4 PIN_D5
#define LCD_RW_PIN PIN_D1
#define LCD_DATA5 PIN_D4
#define LCD_DATA6 PIN_D3
#define LCD_DATA7 PIN_D2
#include <lcd.c>                       // Libreria de manejo para el LCD en modo 4 bits

#define BUTTON_UP    PIN_B7           // Boton para subir en el menu
#define BUTTON_DOWN  PIN_B6           // Boton para bajar en el menu
#define BUTTON_ENTER PIN_B5           // Boton para seleccionar opcion
#define BUTTON_BACK  PIN_B4           // Boton para regresar al menu

//---------------- FUNCION PARA MOSTRAR LA OPCION SELECCIONADA EN LCD ------------------------

void show_selected_option(int selected_option) {
   lcd_putc("\f"); // Limpia pantalla
   switch (selected_option) {
      case 1:
         lcd_gotoxy(1, 1); lcd_putc("*Temperatura*");
         lcd_gotoxy(1, 2); lcd_putc("Voltaje");
         break;
      case 2:
         lcd_gotoxy(1, 1); lcd_putc("*Voltaje*");
         lcd_gotoxy(1, 2); lcd_putc("Corriente");
         break;
      case 3:
         lcd_gotoxy(1, 1); lcd_putc("Voltaje");
         lcd_gotoxy(1, 2); lcd_putc("*Corriente*");
         break;
      default:
         lcd_putc("Opcion Invalida");
   }
}

//---------------- FUNCION PARA OBTENER LA TEMPERATURA DESDE EL SENSOR (AN0) -----------------

float getTemperature() {
   int16 bits;
   set_adc_channel(0);    // Selecciona el canal AN0
   delay_us(20);          // Pequena espera para estabilidad del canal
   bits = read_adc();     // Lectura del ADC (0-1023)
   return 0.48828125 * bits; // Conversion a grados Celsius (LM35: 10mV/°C)
}

//---------------- FUNCION PARA OBTENER EL VOLTAJE DESDE UN DIVISOR (AN1) --------------------

float getVoltage() {
   int16 bits;
   set_adc_channel(1);    // Selecciona el canal AN1
   delay_us(20);
   bits = read_adc();
   return (5.0 * bits / 1023.0) * 9 / 2.2; // Ajuste para escalado con divisor resistivo
}

//---------------- FUNCION PARA OBTENER LA CORRIENTE (CAIDA EN SHUNT, AN2) -------------------

float getCurrent() {
   int16 bits;
   set_adc_channel(2);    // Selecciona el canal AN2
   delay_us(20);
   bits = read_adc();
   return bits * 0.0048828125 * 1000; // Conversion a mA (5V/1024 pasos * 1000)
}

// funcion principal

void main() {
   int selected_option = 1;   // Opcion inicial seleccionada
   int option_selected = 0;   // Estado de si se ha presionado ENTER

   setup_adc_ports(ALL_ANALOG);       // Activa AN0, AN1, AN2 como entradas analogicas
   setup_adc(ADC_CLOCK_DIV_32);       // Reloj del ADC dividido por 32
   lcd_init();                        // Inicializa el LCD

   //----------- MENSAJE DE BIENVENIDA AL INICIAR EL PROGRAMA -----------

   lcd_putc("\f");
   lcd_gotoxy(1, 1);
   lcd_putc("  Equipo 3");
   lcd_gotoxy(1, 2);
   lcd_putc("  KEN ANGEL LEO");

   // Esperar a que el usuario presione ENTER para continuar
   while (true) {
      if (input(BUTTON_ENTER) == 0) {
         while (input(BUTTON_ENTER) == 0); // Espera a que se libere el boton
         break;
      }
   }

   // Mostrar primera opcion del menu
   show_selected_option(selected_option);

   //------------- BUCLE PRINCIPAL DEL MENU INTERACTIVO ------------------

   while (true) {
      // Boton UP solo decrementa si no esta en la primera opcion
      if (input(BUTTON_UP) == 0) {
         if (selected_option > 1) {
            selected_option--;
            show_selected_option(selected_option);
         }
         while (input(BUTTON_UP) == 0);
         delay_ms(50); // Antirrebote
      }

      // Boton DOWN solo incrementa si no esta en la ultima opcion
      if (input(BUTTON_DOWN) == 0) {
         if (selected_option < 3) {
            selected_option++;
            show_selected_option(selected_option);
         }
         while (input(BUTTON_DOWN) == 0);
         delay_ms(50); // Antirrebote
      }

      // Boton ENTER activa la medicion de la opcion seleccionada
      if (input(BUTTON_ENTER) == 0) {
         option_selected = 1;
         while (input(BUTTON_ENTER) == 0);
         delay_ms(50);
      }

      // Boton BACK regresa al menu principal
      if (input(BUTTON_BACK) == 0) {
         show_selected_option(selected_option);
         option_selected = 0;
         while (input(BUTTON_BACK) == 0);
         delay_ms(50);
      }

      // Si se selecciona una opcion, mostrar su valor
      if (option_selected == 1) {
         float value;
         if (selected_option == 1) {
            value = getTemperature();
            printf(lcd_putc, "\fTemp: %.2f C", value);
         } else if (selected_option == 2) {
            value = getVoltage();
            printf(lcd_putc, "\fVol: %.2f V", value);
         } else if (selected_option == 3) {
            value = getCurrent();
            printf(lcd_putc, "\fCorr: %.2f mA", value);
         }
         option_selected = 0; // Regresa al menu tras mostrar el valor
      }
   }
}

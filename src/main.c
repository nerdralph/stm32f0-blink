#include <stdint.h>
#include "stm32f031x6.h"

#ifndef DELAY
#define DELAY 250
#endif

// PA9 is serial TX
#define LED_PORT GPIOA
#define LED_PIN 9
//#define LED_PORT GPIOB
//#define LED_PIN 1

// delay 1ms at 8MHz
void delay_ms(uint16_t ms)
{
  uint32_t count = 2000;
  // loop is 4c on M0, * 2000 = 8000 cycles
  asm volatile (
  ".syntax unified\n"
  "   muls r0, %0, r0 \n"
  "1: subs r0, #1     \n"
  "   bne 1b          \n"
  : "+l" (count) :: );
}

#define TOGGLE(GPIO, PIN) GPIO->ODR ^= (1 << PIN);

int main(void) {
  // Enable the GPIO A, B & F peripherals in 'RCC_AHBENR'.
  RCC->AHBENR   |= 
    (RCC_AHBENR_GPIOAEN | RCC_AHBENR_GPIOBEN | RCC_AHBENR_GPIOFEN);

  // LED pin should be set to push-pull mode
  LED_PORT->MODER  |=  (0x1 << (LED_PIN*2));

  while (1) {
    TOGGLE(LED_PORT, LED_PIN);

    /*
    uint32_t gpios = 1 << LED_PIN;
    uint32_t port = LED_PORT->ODR;
    // pseudo-atomic toggle
    LED_PORT->BSRR = (~port & gpios); 
    LED_PORT->BRR = (port &  gpios);
    */

    delay_ms(DELAY);
  }
}

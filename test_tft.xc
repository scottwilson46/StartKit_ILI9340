/*
 * test_led.xc
 *
 *  Created on: Apr 6, 2014
 *      Author: scott
 */

#include <xs1.h>
#include <timer.h>
#include <math.h>
#include "spi.h"


int8_t sin_vals[] = {0,
        10,
        20,
        30,
        40,
        49,
        58,
        66,
        74,
        80,
        86,
        91,
        95,
        97,
        99,
        100,
        99,
        97,
        95,
        91,
        86,
        80,
        74,
        66,
        58,
        49,
        40,
        30,
        20,
        10,
        0,
        -10,
        -20,
        -30,
        -40,
        -50,
        -58,
        -66,
        -74,
        -80,
        -86,
        -91,
        -95,
        -97,
        -99,
        -100,
        -99,
        -97,
        -95,
        -91,
        -86,
        -80,
        -74,
        -66,
        -58,
        -50,
        -40,
        -30,
        -20,
        -10};


int8_t cos_vals[] = {100,
        99,
        97,
        95,
        91,
        86,
        80,
        74,
        66,
        58,
        50,
        40,
        30,
        20,
        10,
        0,
        -10,
        -20,
        -30,
        -40,
        -49,
        -58,
        -66,
        -74,
        -80,
        -86,
        -91,
        -95,
        -97,
        -99,
        -100,
        -99,
        -97,
        -95,
        -91,
        -86,
        -80,
        -74,
        -66,
        -58,
        -50,
        -40,
        -30,
        -20,
        -10,
        0,
        10,
        20,
        30,
        40,
        50,
        58,
        66,
        74,
        80,
        86,
        91,
        95,
        97,
        99};


int main() {

  reset_display();

  fillScreen(ILI9340_BLACK);

  int i=15;
/*
  while(1) {

      drawCircle(120,160,100,ILI9340_WHITE);
      drawLine(120,160,120+sin_vals[i],160+cos_vals[i],ILI9340_WHITE);
      delay_milliseconds(1000);
      drawLine(120,160,120+sin_vals[i],160+cos_vals[i],ILI9340_BLACK);
      if (i==0) {
          i=59;
      } else {
          i--;
      }


  }
*/
  while(1) {

      drawCircle(120,160,100,ILI9340_WHITE);
      drawLineOld(120,160,120+sin_vals[i],160+cos_vals[i],ILI9340_WHITE);
      //delay_milliseconds(1000);
      //drawLine(120,160,120+sin_vals[i],160+cos_vals[i],ILI9340_BLACK);
      if (i==0) {
          i=59;
      } else {
          i--;
      }


  }




  while (1) {

  }
  return 0;
}

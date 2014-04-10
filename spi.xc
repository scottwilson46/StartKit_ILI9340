

#include "spi.h"
#include "math.h"
#include <stdint.h>
#include <xs1.h>
#include <xclib.h>

#define DELAY 0x80

uint32_t colstart;
uint32_t rowstart;
uint32_t _width = ILI9340_TFTWIDTH;
uint32_t _height = ILI9340_TFTHEIGHT;

port p = XS1_PORT_32A;

void writecommand(uint8_t c) {
  uint32_t port_data;
  p :> port_data;

  port_data = port_data &~(0x1<<RSPOS);
  p <: port_data;
  port_data = port_data &~(0x1<<CSPOS);
  p <: port_data;

  spi_write(c);
 
  p :> port_data;
  port_data = port_data | (0x1<<CSPOS);
  p <: port_data;

}

void writedata(uint8_t c) {
  uint32_t port_data;
  p :> port_data;

  port_data = port_data | (0x1<<RSPOS);
  p <: port_data;
  port_data = port_data &~(0x1<<CSPOS);
  p <: port_data;

  spi_write(c);

  p :> port_data;
  port_data = port_data | (0x1<<CSPOS);
  p <: port_data;
}

void spi_write(uint8_t c) {
  uint32_t port_data;
  p :> port_data;

  for (uint8_t bit = 0x80; bit; bit >>=1) {
    if (c&bit) port_data = port_data | (0x1<<DATAPOS);
    else       port_data = port_data &~(0x1<<DATAPOS);
    p <: port_data;

    // rising edge clk:
    port_data = port_data | (0x1<<CLKPOS);
    p <: port_data;
    port_data = port_data &~(0x1<<CLKPOS);
    //delay_microseconds(1);
    p <: port_data;
  }

}

void setAddrWindow(uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1) {

  writecommand(ILI9340_CASET); // Column addr set
  writedata(x0 >> 8);
  writedata(x0 & 0xFF); // XSTART
  writedata(x1 >> 8);
  writedata(x1 & 0xFF); // XEND

  writecommand(ILI9340_PASET); // Row addr set
  writedata(y0>>8);
  writedata(y0);     // YSTART
  writedata(y1>>8);
  writedata(y1);     // YEND

  writecommand(ILI9340_RAMWR); // write to RAM
}

void fillRect(int16_t x, int16_t y, int16_t w, int16_t h,
  uint16_t color) {
  uint32_t port_data;

  // rudimentary clipping (drawChar w/big text requires this)
  if((x >= _width) || (y >= _height)) return;
  if((x + w - 1) >= _width)  w = _width  - x;
  if((y + h - 1) >= _height) h = _height - y;

  setAddrWindow(x, y, x+w-1, y+h-1);

  uint8_t hi = color >> 8, lo = color;
  p :> port_data;

  port_data = port_data | (0x1<<RSPOS);
  p <: port_data;
  port_data = port_data &~(0x1<<CSPOS);
  p <: port_data;

  for(y=h; y>0; y--) {
    for(x=w; x>0; x--) {
      spi_write(hi);
      spi_write(lo);
    }
  }

  p :> port_data;
  port_data = port_data | (0x1<<CSPOS);
  p <: port_data;
}


void drawPixel(int16_t x, int16_t y, uint16_t color) {

  uint32_t port_data;
  if((x < 0) ||(x >= _width) || (y < 0) || (y >= _height)) return;

  setAddrWindow(x, y, x+1, y+1);

  uint8_t hi = color >> 8, lo = color;
  p :> port_data;

  port_data = port_data | (0x1<<RSPOS);
  p <: port_data;
  port_data = port_data &~(0x1<<CSPOS);
  p <: port_data;

      spi_write(hi);
      spi_write(lo);

  p :> port_data;
  port_data = port_data | (0x1<<CSPOS);
  p <: port_data;
}


void drawLineOld(int16_t startx, int16_t starty, int16_t endx, int16_t endy, uint16_t color) {
int16_t x,y;
int num_points = 128;
int i;
int _sx, _sy, _ex, _ey;


if (endx>startx) {
_sx = startx;
_ex = endx;
} else {
_sx = endx;
_ex = startx;
}

if (endy>starty) {
_sy = starty;
_ey = endy;
} else {
_sy = endy;
_ey = starty;
}

for (i=0; i<num_points; i++) {
x = _sx + ((_ex-_sx)*i)/128;
y = _sy + ((_ey-_sy)*i)/128;
        drawPixel(x,y,color);
}
}




void drawLine(int16_t startx, int16_t starty, int16_t endx, int16_t endy, uint16_t color) {
    int16_t x,y;
    int num_points = 128;
    int i;


    for (i=0; i<num_points; i++) {

        if (startx>endx)
            x = startx - ((startx-endx)*i)/128;
        else
            x = startx + ((endx-startx)*i)/128;

        if (starty>endy)
            y = starty - ((starty-endy)*i)/128;
        else
            y = starty + ((endy-starty)*i)/128;


//        x = _sx + (((_ex-_sx)/num_points)*i);
//        y = _sy + (((_ey-_sy)/num_points)*i);
        drawPixel(x,y,color);
    }
}



void fillScreen(uint16_t color) {
  fillRect(0, 0, _width, _height, color);
}  

void reset_display() {

  uint32_t port_data;

  port_data = port_data | (0x1<<BLPOS);
  p <: port_data;
  port_data = port_data | (0x1<<VDDPOS);
  p <: port_data;

  colstart = 2;
  rowstart = 1;

  port_data = port_data &~(0x1<<CSPOS);
  p <: port_data;
  port_data = port_data | (0x1<<RSTPOS);
  p <: port_data;
  delay_milliseconds(500);
  port_data = port_data &~(0x1<<RSTPOS);
  p <: port_data;
  delay_milliseconds(500);
  port_data = port_data | (0x1<<RSTPOS);
  p <: port_data;
  delay_milliseconds(500);

  
  writecommand(0xEF);
  writedata(0x03);
  writedata(0x80);
  writedata(0x02);

  writecommand(0xCF);  
  writedata(0x00); 
  writedata(0XC1); 
  writedata(0X30); 

  writecommand(0xED);  
  writedata(0x64); 
  writedata(0x03); 
  writedata(0X12); 
  writedata(0X81); 
 
  writecommand(0xE8);  
  writedata(0x85); 
  writedata(0x00); 
  writedata(0x78); 

  writecommand(0xCB);  
  writedata(0x39); 
  writedata(0x2C); 
  writedata(0x00); 
  writedata(0x34); 
  writedata(0x02); 
 
  writecommand(0xF7);  
  writedata(0x20); 

  writecommand(0xEA);  
  writedata(0x00); 
  writedata(0x00); 
 
  writecommand(ILI9340_PWCTR1);    //Power control 
  writedata(0x23);   //VRH[5:0] 
 
  writecommand(ILI9340_PWCTR2);    //Power control 
  writedata(0x10);   //SAP[2:0];BT[3:0] 
 
  writecommand(ILI9340_VMCTR1);    //VCM control 
  writedata(0x3e); //�Աȶȵ���
  writedata(0x28); 
  
  writecommand(ILI9340_VMCTR2);    //VCM control2 
  writedata(0x86);  //--
 
  writecommand(ILI9340_MADCTL);    // Memory Access Control 
  writedata(ILI9340_MADCTL_MX | ILI9340_MADCTL_BGR);

  writecommand(ILI9340_PIXFMT);    
  writedata(0x55); 
  
  writecommand(ILI9340_FRMCTR1);    
  writedata(0x00);  
  writedata(0x18); 
 
  writecommand(ILI9340_DFUNCTR);    // Display Function Control 
  writedata(0x08); 
  writedata(0x82);
  writedata(0x27);  
 
  writecommand(0xF2);    // 3Gamma Function Disable 
  writedata(0x00); 
 
  writecommand(ILI9340_GAMMASET);    //Gamma curve selected 
  writedata(0x01); 
 
  writecommand(ILI9340_GMCTRP1);    //Set Gamma 
  writedata(0x0F); 
  writedata(0x31); 
  writedata(0x2B); 
  writedata(0x0C); 
  writedata(0x0E); 
  writedata(0x08); 
  writedata(0x4E); 
  writedata(0xF1); 
  writedata(0x37); 
  writedata(0x07); 
  writedata(0x10); 
  writedata(0x03); 
  writedata(0x0E); 
  writedata(0x09); 
  writedata(0x00); 
  
  writecommand(ILI9340_GMCTRN1);    //Set Gamma 
  writedata(0x00); 
  writedata(0x0E); 
  writedata(0x14); 
  writedata(0x03); 
  writedata(0x11); 
  writedata(0x07); 
  writedata(0x31); 
  writedata(0xC1); 
  writedata(0x48); 
  writedata(0x08); 
  writedata(0x0F); 
  writedata(0x0C); 
  writedata(0x31); 
  writedata(0x36); 
  writedata(0x0F); 

  writecommand(ILI9340_SLPOUT);    //Exit Sleep 
  delay_milliseconds(120); 		
  writecommand(ILI9340_DISPON);    //Display on 


}



unsigned int sqrtuint(unsigned int x) {
    int zeroes;
    int approx;
    int corr;

    if (x < 2) {
        return x;
    }
    zeroes = clz(x);
    
    zeroes = zeroes & ~1;
    zeroes = (32-zeroes) >> 1;
    approx = x >> zeroes;
    for(int i = 0; i < 4; i++) {
        corr = ((((approx*approx) - (int)x) / approx)+1) >> 1;
        approx -= corr;
    }
    return approx;
}
/*
void circlePoints(int cx, int cy, int x, int y, int pix)
    {
        int act = Color.red.getRGB();

        if (x == 0) {
            drawPixel(act, cx, cy + y,color);
            drawPixel(pix, cx, cy - y,color);
            drawPixel(pix, cx + y, cy,color);
            drawPixel(pix, cx - y, cy,color);
        } else
        if (x == y) {
            drawPixel(act, cx + x, cy + y,color);
            drawPixel(pix, cx - x, cy + y,color);
            drawPixel(pix, cx + x, cy - y,color);
            drawPixel(pix, cx - x, cy - y,color);
        } else
        if (x < y) {
            drawPixel(act, cx + x, cy + y,color);
            drawPixel(pix, cx - x, cy + y,color);
            drawPixel(pix, cx + x, cy - y,color);
            drawPixel(pix, cx - x, cy - y,color);
            drawPixel(pix, cx + y, cy + x,color);
            drawPixel(pix, cx - y, cy + x,color);
            drawPixel(pix, cx + y, cy - x,color);
            drawPixel(pix, cx - y, cy - x,color);
        }
    }

    public void circleMidpoint(int xCenter, int yCenter, int radius, Color c)
    {
        int pix = c.getRGB();
        int x = 0;
        int y = radius;
        int p = (5 - radius*4)/4;

        circlePoints(xCenter, yCenter, x, y, pix);
        while (x < y) {
            x++;
            if (p < 0) {
                p += 2*x+1;
            } else {
                y--;
                p += 2*(x-y)+1;
            }
            circlePoints(xCenter, yCenter, x, y, pix);
        }
    }

    */

void drawCircle(int xCenter, int yCenter, int radius, uint16_t c) {
int x;
int y;
int px = radius;
int s;
int cx = xCenter;
int cy = yCenter;

  for(int i=0;i<=radius;i++) {
    y=i;
    s=(int) sqrtuint(radius*radius-i*i);
    for(x=s;x<=px;x++) {
      drawPixel(cx+x,cy+y,c);
      drawPixel(cx-x,cy-y,c);
      drawPixel(cx+x,cy-y,c);
      drawPixel(cx-x,cy+y,c);
    }
  px=s;
  }
}
/*
void DrawCircle(int x, int y, int r, int color)
{
   int pos_x,
   pos_y = -r,
   tx = 0,
   ty = 4*r,
   a = 0,
   b = 2*ty+9,
   x1 = int(r*0.707010678 + 0.5);

   DrawPixel(x+r,y,color);
   DrawPixel(x-r,y,color);
   DrawPixel(x,y+r,color);
   DrawPixel(x,y-r,color);
   DrawPixel(x+x1,y+x1,color);
   DrawPixel(x+x1,y-x1,color);
   DrawPixel(x-x1,y+x1,color);
   DrawPixel(x-x1,y-x1,color);

   for(pos_x = 1;pos_x < x1;pos_x++)
   {
 a += 8;
 tx += a;
 if(tx > ty)
 {
    pos_y++;
    b -= 8;
    ty += b;
 }

 DrawPixel(x+pos_x,y+pos_y,coulor);
 DrawPixel(x-pos_x,y+pos_y,coulor);

 DrawPixel(x+pos_x,y-pos_y,coulor);
 DrawPixel(x-pos_x,y-pos_y,coulor);

 DrawPixel(x+pos_y,y+pos_x,coulor);
 DrawPixel(x-pos_y,y+pos_x,coulor);

 DrawPixel(x+pos_y,y-pos_x,coulor);
 DrawPixel(x-pos_y,y-pos_x,coulor);
   }
}
*/

#ifndef __OSX_DRAW_RGB_BUFFER__
#define __OSX_DRAW_RGB_BUFFER__

#include "Adt.h"

namespace OSX
{
  // 24bits 3 byte rgb buffer
  void drawRGBBuffer(unsigned char* pRGBBuffer, int width, int height, Adt::Rectangle<int> r, bool bStretch);
}

#endif
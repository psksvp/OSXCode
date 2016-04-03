#include "OSXDrawRGBBuffer.h"
#include "OSXAutoReleasePool.h"


namespace OSX
{
  void drawRGBBuffer(unsigned char* pRGBBuffer, int width, int height, Adt::Rectangle<int> r, bool bStretch)
  {
    OSX::AutoReleasePool pool;  
    unsigned char* imageData[1];
    imageData[0] = pRGBBuffer;
    NSBitmapImageRep* myBitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:imageData
                                                                            pixelsWide:width
                                                                            pixelsHigh:height
                                                                         bitsPerSample:8
                                                                       samplesPerPixel:3
                                                                              hasAlpha:NO 
                                                                              isPlanar:NO 
                                                                        colorSpaceName:NSCalibratedRGBColorSpace 
                                                                           bytesPerRow:width * 3 
                                                                          bitsPerPixel:24];
    
    if(true == bStretch)
      [myBitmapRep drawInRect:NSMakeRect((float)r.TopLeft().X(), (float)r.TopLeft().Y(), (float)r.Width(), (float)r.Height())];
    else
    {
      NSSize bs = [myBitmapRep size];
      if(bs.width < r.Width() && bs.height < r.Height())
        [myBitmapRep drawAtPoint:NSMakePoint(r.TopLeft().X(), r.TopLeft().Y())];
      else
        [myBitmapRep drawInRect:NSMakeRect((float)r.TopLeft().X(), (float)r.TopLeft().Y(), (float)r.Width(), (float)r.Height())];
    } 
    
    [myBitmapRep release];
  }
}
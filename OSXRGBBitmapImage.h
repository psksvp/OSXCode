#ifndef __OSX_LIBRARY__
#define __OSX_LIBRARY__

#import <Cocoa/Cocoa.h>

namespace OSX
{
  ////////////////////////////
  class RGBBitmapImage
  {
    int myWidth, myHeight;
    NSBitmapImageRep* myBitmapRep;
  public:
    RGBBitmapImage(void)
    {
      myBitmapRep = nil;
      myWidth = myHeight = 0;
    }
    
    ~RGBBitmapImage(void)
    {
      if(nil != myBitmapRep)
        [myBitmapRep release];
    }
    
    bool allocate(const char* szFileName)
    {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithCString:szFileName encoding:NSASCIIStringEncoding]];
      if(nil != image)
      {
        if(nil != myBitmapRep)
          [myBitmapRep release];
        
        myBitmapRep = [[image representations] objectAtIndex:0];
        [myBitmapRep retain];
        NSSize s = [image size];
        myWidth = s.width;
        myHeight = s.height;
        [image release];
        return true;
      }
      else 
      {
        return false;
      }

    }
    
    bool allocate(int width, int height, unsigned char* pRGBBuffer=NULL)
    {
      unsigned char* imageData[1];
      imageData[0] = pRGBBuffer;
      if(nil == myBitmapRep)
      {
        myBitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:imageData
                                                                pixelsWide:width
                                                                pixelsHigh:height
                                                             bitsPerSample:8
                                                           samplesPerPixel:3
                                                                  hasAlpha:NO 
                                                                  isPlanar:NO 
                                                            colorSpaceName:NSCalibratedRGBColorSpace 
                                                               bytesPerRow:width * 3 
                                                              bitsPerPixel:24];
      }
      else
      {
        NSSize bs = [myBitmapRep size];
        if(width != (int)bs.width || height != (int)bs.height)
        {
          [myBitmapRep release];
          myBitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:imageData
                                                                  pixelsWide:width
                                                                  pixelsHigh:height 
                                                               bitsPerSample:8
                                                             samplesPerPixel:3
                                                                    hasAlpha:NO 
                                                                    isPlanar:NO 
                                                              colorSpaceName:NSCalibratedRGBColorSpace 
                                                                 bytesPerRow:width * 3 
                                                                bitsPerPixel:24];
        }
      }
      myWidth = width;
      myHeight = height;
      return myBitmapRep != nil ? true : false;
    }
    
    unsigned char* memoryPtr(void)
    {
      if(nil != myBitmapRep)
        return [myBitmapRep bitmapData];
      else
        return NULL;
    }
    
    int width()
    {
      return myWidth;
    }
    
    int height()
    {
      return myWidth;
    }
    
    void draw(NSRect r, bool bStretch = true)
    {
      if(nil == myBitmapRep)
        return;
      if(true == bStretch)
        [myBitmapRep drawInRect:r];
      else
      {
        NSSize bs = [myBitmapRep size];
        if(bs.width < r.size.width && bs.height < r.size.height)
          [myBitmapRep drawAtPoint:r.origin];
        else
          [myBitmapRep drawInRect:r];
      }  
    }
  };
 
  
    
} //namespace Cocoa

#endif


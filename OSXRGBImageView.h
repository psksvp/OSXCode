#ifndef __OSX_DISPLAY_WINDOW__
#define __OSX_DISPLAY_WINDOW__

#import <Cocoa/Cocoa.h>

namespace OSX
{
  class RGBImageView
  {
    NSWindow* myWindow;
  public:
    RGBImageView(const char* szTitle="OSXImageView");
    ~RGBImageView();
    
    void setImage(unsigned char* pRGBBuffer, int width, int height);
  };
} //namespace OSX
#endif
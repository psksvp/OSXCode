#include "OSXRGBImageView.h"
#include "OSXAutoReleasePool.h"
#include "OSXRGBBitmapImage.h"

////////////////////////////////////////////////////
@interface OSXRGBImageView :NSView
{
  OSX::RGBBitmapImage* myBitmap;
};
@end

//------------------------------
@implementation OSXRGBImageView

-(id)init
{
  [super init];
  myBitmap = new OSX::RGBBitmapImage;
  return self;
}

-(void)dealloc
{
  delete myBitmap;
  [super dealloc];
}

-(void)setImageRGBBuffer:(unsigned char*)pRGBBuffer width:(int)width height:(int)height
{
  @synchronized (self) 
  {
    [self lockFocus];
    myBitmap->allocate(width, height, pRGBBuffer);
    myBitmap->draw([self bounds], true);
    [self unlockFocus];
    [[self window] flushWindow];
  }
}

-(void)drawRect:(NSRect)rect
{
  @synchronized (self) 
  {
    myBitmap->draw([self bounds], true);
  }
}


@end

///////////////////////////////////////////////////
namespace OSX
{
  RGBImageView::RGBImageView(const char* szTitle)
  {
    myWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,200,200)
                                           styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
                                             backing:NSBackingStoreBuffered  
                                               defer:NO];
    
    [myWindow setContentView:[[OSXRGBImageView alloc] init]];
    
    [myWindow setHasShadow:YES];
    [myWindow setAcceptsMouseMovedEvents:YES];
    [myWindow useOptimizedDrawing:YES];
    [myWindow setTitle:[NSString stringWithCString:szTitle encoding:NSASCIIStringEncoding]];
    [myWindow makeKeyAndOrderFront:nil];
    [myWindow display];
  }
  
  RGBImageView::~RGBImageView()
  {
    [myWindow performClose:nil];
    [myWindow release];
  }
  
  void RGBImageView::setImage(unsigned char* pRGBBuffer, int width, int height)
  {
    OSXRGBImageView* view = [myWindow contentView];
    [view setImageRGBBuffer:pRGBBuffer width:width height:height]; 
  }
}
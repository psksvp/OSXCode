#ifndef __COCOA_AUTO_RELEASE_POOL__
#define __COCOA_AUTO_RELEASE_POOL__
#import <Cocoa/Cocoa.h>

namespace OSX
{
  class AutoReleasePool
  {
    NSAutoreleasePool* myPool;
  public:
    AutoReleasePool(void)
    {
      myPool = [[NSAutoreleasePool alloc] init];
    }
    
    ~AutoReleasePool(void)
    {
      [myPool release];
    }
  };
}
#endif

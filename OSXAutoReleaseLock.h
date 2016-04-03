#import <Cocoa/Cocoa.h>

namespace OSX
{
  class AutoReleaseLock;
  class Lock
  {
    friend class AutoReleaseLock;
    bool bIsLocked;
    NSLock* myLock;
  public:
    Lock()
    {
      myLock = [[NSLock alloc] init];
      bIsLocked = false;
    }
    ~Lock()
    {
      if(true == bIsLocked)
        unlock();
      [myLock release];
    }
    
    void lock()
    {
      [myLock lock];
      bIsLocked = true;
    }
    
    void unlock()
    {
      [myLock unlock];
      bIsLocked = false;
    }
    
    bool isLocked()
    {
      return bIsLocked;
    }
  };
  
  ///////////////////
  class AutoReleaseLock
  {
    NSLock* myLock;
  public:
    AutoReleaseLock(NSLock* lock)
    {
      myLock = lock;
      [myLock lock];
    }
    
    AutoReleaseLock(OSX::Lock* osxLock)
    {
      myLock = osxLock->myLock;
      [myLock lock];
    }
    
    AutoReleaseLock(void)
    {
      [myLock unlock];
    }
  };
}


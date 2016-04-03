#include "OSXGlobalKeyboardCapture.h"
#include "conio.h"
#import <Cocoa/Cocoa.h>


@interface OSXKeyboardHandlerInstaller : NSObject
{
  int myKeyCode;
  BOOL myFlagIfKeyPressed;
  id myEventKeyDownMonitor;
  id myEventKeyUpMonitor;
  char myASCIIChar;
}

-(void) installKeyboardHandler;
-(void) removeKeyboardHandler;

@end
  
@implementation OSXKeyboardHandlerInstaller

-(id) init
{
  myFlagIfKeyPressed = NO;
  myEventKeyDownMonitor = nil;
  myEventKeyUpMonitor = nil;
  myKeyCode = -1;
  return [super init];
}

-(void) installKeyboardHandler
{
  myEventKeyDownMonitor = 
  [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event)
   {
     //NSString *chars = [[event characters] lowercaseString];
     //unichar character = [chars characterAtIndex:0];
     
     NSString *chars = [event characters];
     const char *cStr = [chars cStringUsingEncoding:NSASCIIStringEncoding];
     if(NULL != cStr)
       myASCIIChar = cStr[0];
     
     //NSLog(@"keydown globally! Which key? This key: %c", character);
     
     myKeyCode = [event keyCode];
     myFlagIfKeyPressed = YES;
     return event;
   }];
  
  if(nil == myEventKeyDownMonitor)
    NSLog(@"myEventMonitor is nil");
  else
    NSLog(@"keyboard handler installed");
  
  myEventKeyUpMonitor = 
  [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyUpMask handler:^(NSEvent *event)
   {
     myFlagIfKeyPressed = NO;
     return event;
   }];
  /*
  myEventKeyDownMonitor = 
  [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(struct NSEvent *event)
  {
    NSString *chars = [[event characters] lowercaseString];
    unichar character = [chars characterAtIndex:0];
    
    NSLog(@"keydown globally! Which key? This key: %c", character);
    
    myKeyCode = [event keyCode];
    myFlagIfKeyPressed = YES;
  }];
   
  if(nil == myEventKeyDownMonitor)
    NSLog(@"myEventMonitor is nil");
  else
    NSLog(@"keyboard handler installed");
  
  myEventKeyUpMonitor = 
  [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyUpMask handler:^(struct NSEvent *event)
   {
     myFlagIfKeyPressed = NO;
   }]; */
}

-(void) removeKeyboardHandler
{
  if(nil != myEventKeyDownMonitor)
  {
    [NSEvent removeMonitor:myEventKeyDownMonitor];
    myEventKeyDownMonitor = nil;
  }
  
  if(nil != myEventKeyUpMonitor)
  {
    [NSEvent removeMonitor:myEventKeyUpMonitor];
    myEventKeyUpMonitor = nil;
  }
}

-(BOOL) isKeyPressed
{
  return myFlagIfKeyPressed;
}

-(int) keyCode
{
  return myKeyCode;
}

-(char) character
{
  return myASCIIChar;
}

@end


namespace OSX
{
  OSXKeyboardHandlerInstaller* keyboardHandler = nil;
  void installKeyboardHandler()
  {
    if(nil == keyboardHandler)
    {
      keyboardHandler = [[OSXKeyboardHandlerInstaller alloc] init];
      [keyboardHandler installKeyboardHandler];
    }
  }
  
  void removeKeyboardHandler()
  {
    if(nil != keyboardHandler)
    {
      [keyboardHandler removeKeyboardHandler];
      [keyboardHandler release];
      keyboardHandler = nil;
    }
  }
  
  int waitForKeyPress()
  {
    if(nil == keyboardHandler)
    {
      NSLog(@"keyboard handler is not installed");
      return -1;
    }
        
    if(YES == [keyboardHandler isKeyPressed])
      return [keyboardHandler keyCode];
    else
      return -1; 
  }
  
  KeyboardInfo waitForKeyboard()
  {
    OSX::KeyboardInfo k;
    k.code = waitForKeyPress();
    k.character = [keyboardHandler character];
    return k;
  }
}
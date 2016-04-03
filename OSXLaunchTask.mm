/* Copyright (c) 1994-2004 Pongsak Suvanpong (psksvp@ccs.neu.edu).  
* All Rights Reserved.
*
* This computer software is owned by Pongsak Suvanpong, and is
* protected by U.S. copyright laws and other laws and by international
* treaties.  This computer software is furnished by Pongsak Suvanpong 
* pursuant to a written license agreement and may be used, copied,
* transmitted, and stored only in accordance with the terms of such
* license and with the inclusion of the above copyright notice.  This
* computer software or any other copies thereof may not be provided or
* otherwise made available to any other person.
*/



#import <Cocoa/Cocoa.h>
#import "OSXLaunchTask.h"
#import "OSXAutoReleaseLock.h"


/*
@interface RunloopDriver :NSObject
{
  NSTimer* myTimer;
}

-(void)start;
-(void)stop;

-(void)onTimerTick:(NSTimer *)timer;
@end

@implementation RunloopDriver

-(id)init
{
  [super init];
  myTimer = [NSTimer scheduledTimerWithTimeInterval: 0.6
                                             target: self
                                           selector: @selector(onTimerTick:)
                                           userInfo: nil 
                                            repeats: YES];
  
  [myTimer retain];
  return self;
}

-(void)dealloc
{
  [myTimer release];
  [super dealloc];
}

-(void)start
{
  [myTimer fire];
}

-(void)stop
{
  [myTimer invalidate];
}

-(void)onTimerTick:(NSTimer *)timer
{
  NSLog(@"TiK ToK..");
}

@end */

namespace OSX
{
  ////////////////////
  static NSApplication *application = nil;
  static NSAutoreleasePool *pool = nil;
  static bool wasInitialized = false;
  static int globalRefCountForStartAndStop = 0;
  
  //OSX::Lock globalLock;
  
  int startSystemUsingCocoa( int argc, char** argv) 
  {
    
    ++globalRefCountForStartAndStop;
    if(true == wasInitialized)
      return 0;
    wasInitialized = true;
    
    pool = [[NSAutoreleasePool alloc] init];
    application = [NSApplication sharedApplication];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
    
#ifndef NSAppKitVersionNumber10_5
#define NSAppKitVersionNumber10_5 949
#endif
    if( floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5 )
      [application setActivationPolicy:0/*NSApplicationActivationPolicyRegular*/];
#endif
    [application finishLaunching];
    atexit(exitSystemUsingCocoa);
    
    return 0;
  }
  
  void exitSystemUsingCocoa(void)
  {
    --globalRefCountForStartAndStop;
    if(application && globalRefCountForStartAndStop <= 0)
    {
      [application terminate:nil];
      application = nil;
      [pool release];
    }
  }
  
  int runCocoaEventLoop(int nLoop)
  {
    int returnCode = -1;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int cnt = 0;
    while(cnt < nLoop) 
    {
      [pool release];
      pool = [[NSAutoreleasePool alloc] init];
      
      NSEvent *event =
      [application nextEventMatchingMask:NSAnyEventMask
                               untilDate:[NSDate distantPast]
                                  inMode:NSDefaultRunLoopMode
                                dequeue:YES];
      
      [application sendEvent:event];
      [application updateWindows];
      
      [NSThread sleepForTimeInterval:1/100.];
      cnt++;
    }
    [pool release];
    
    return returnCode;
  }
  
  
}




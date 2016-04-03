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

#ifndef WIN32
#include "NixMessageBox.h"
#import <Cocoa/Cocoa.h>


@interface CocoaSheetMessageBox :NSObject
{
  NSWindow* myWindow;
  int iRetCode;
}

-(void)setAttachWithWindowNumber:(int)iWinNo;
-(void)setAttachWithWindow:(NSWindow *)w;

-(void)showMessage:(NSString *)strTitle AndMessage:(NSString *)strMessage;
-(void)askYesNoWithTitle:(NSString *)strTitle AndMessage:(NSString *)strMessage;
-(void)askYesNoAndCancelWithTitle:(NSString *)strTitle AndMessage:(NSString *)strMessage;
-(void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

-(int)returnCode;


@end

@implementation CocoaSheetMessageBox

-(id)init
{
  [super init];
  return self;
}

-(void)dealloc
{
  [super dealloc];
}
  
-(void)setAttachWithWindow:(NSWindow *)w
{
  myWindow = w;
}

-(void)setAttachWithWindowNumber:(int)iWinNo
{
  [self setAttachWithWindow:[NSApp windowWithWindowNumber: iWinNo]];
}

-(void)showMessage:(NSString *)strTitle AndMessage:(NSString *)strMessage
{
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:@"Ok"];
  [alert setMessageText:strMessage];
  [alert setInformativeText:strTitle];
  [alert setAlertStyle:NSInformationalAlertStyle];
  [alert beginSheetModalForWindow:myWindow 
                    modalDelegate:self 
                   didEndSelector:@selector(alertDidEnd: returnCode: contextInfo:) 
                      contextInfo:nil];
  
  [NSApp runModalForWindow:[alert window]]; // run event loop, for sheet window only
                                            // unless this function return rightaway
}

-(void)askYesNoWithTitle:(NSString *)strTitle AndMessage:(NSString *)strMessage
{
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];
  [alert setMessageText:strMessage];
  [alert setInformativeText:strTitle];
  [alert setAlertStyle:NSInformationalAlertStyle];
  [alert beginSheetModalForWindow:myWindow 
                    modalDelegate:self 
                   didEndSelector:@selector(alertDidEnd: returnCode: contextInfo:) 
                      contextInfo:nil];
 
  [NSApp runModalForWindow:[alert window]]; // run event loop, for sheet window only
                                            // unless this function return rightaway
}

-(void)askYesNoAndCancelWithTitle:(NSString *)strTitle AndMessage:(NSString *)strMessage
{
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:strMessage];
  [alert setInformativeText:strTitle];
  [alert setAlertStyle:NSInformationalAlertStyle];
  [alert beginSheetModalForWindow:myWindow 
                    modalDelegate:self 
                   didEndSelector:@selector(alertDidEnd: returnCode: contextInfo:) 
                      contextInfo:nil];
  
  [NSApp runModalForWindow:[alert window]]; // run event loop, for sheet window only
                                            // unless this function return rightaway
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  [NSApp stopModalWithCode:returnCode];
  NSLog(@"alert did end --> %d", returnCode);
  switch(returnCode)
  {
    case NSAlertFirstButtonReturn: iRetCode = NixMessageBox::eYES; break;
    case NSAlertSecondButtonReturn: iRetCode = NixMessageBox::eNO; break;
    case NSAlertThirdButtonReturn: iRetCode = NixMessageBox::eCANCEL; break;
    default: iRetCode = NixMessageBox::eUNKNOWN;
  }
}

-(int)returnCode
{
  return iRetCode;
}



@end

////////////////////////////////////////////////////////////////////////////
namespace NixMessageBox
{
  bool bUsingSheet = false;
  int iDocWindowNo = -1;
  
  void SetDocumentWindowNumber(int iWinNo)
  {
    iDocWindowNo = iWinNo;
    bUsingSheet = true;
  }
  
  void SetHandlerPath(const char* szPath)
  {
  }
  
  int AskYesNo(const char* szMessageText, const char* szCaptionText)
  {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    NSString* nsCaptionText = [NSString stringWithUTF8String:szCaptionText];
    NSString* nsMessageText = [NSString stringWithUTF8String:szMessageText];
    int c;
    if(false == bUsingSheet)
    {
      NSWindow* w = [NSApp keyWindow];
      if(nil == w)
      {
        NSApplicationLoad();
        c = NSRunAlertPanel(nsCaptionText, nsMessageText, @"Yes", @"No", nil);
      }
      else
      {
        CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
        [cmb setAttachWithWindow:w];
        [cmb askYesNoWithTitle:nsCaptionText AndMessage:nsMessageText];
        c = [cmb returnCode];
      }
    }
    else
    {
      CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
      [cmb setAttachWithWindowNumber:iDocWindowNo];
      [cmb askYesNoWithTitle:nsCaptionText AndMessage:nsMessageText];
      c = [cmb returnCode];
    }
    [pool release];
    return c;
  }
  
  int AskYesNoWithCancel(const char* szMessageText, const char* szCaptionText)
  {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* nsCaptionText = [NSString stringWithUTF8String:szCaptionText];
    NSString* nsMessageText = [NSString stringWithUTF8String:szMessageText];
    if(false == bUsingSheet)
    {
      NSWindow* w = [NSApp keyWindow];
      if(nil == w)
      {
        NSApplicationLoad();
        int c = NSRunAlertPanel(nsCaptionText, nsMessageText, @"Cancel", @"Yes", @"No");
        [pool release];
        switch(c)
        {
          case 0: return 1; // yes
          case -1: return 0; // no
          case 1: return 2; // cancel
          default: return 1; // Is this a good idea??????? 
        }
      }
      else
      {
        CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
        [cmb setAttachWithWindow:w];
        [cmb askYesNoAndCancelWithTitle:nsCaptionText AndMessage:nsMessageText];
        int c = [cmb returnCode];
        [pool release];
        return c;
      }
    }
    else
    {
      CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
      [cmb setAttachWithWindowNumber:iDocWindowNo];
      [cmb askYesNoAndCancelWithTitle:nsCaptionText AndMessage:nsMessageText];
      int c = [cmb returnCode];
      [pool release];
      return c;
    }
      
  }
  
  void ShowMessage(const char* szMessageText, const char* szCaptionText)
  {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* nsCaptionText = [NSString stringWithUTF8String:szCaptionText];
    NSString* nsMessageText = [NSString stringWithUTF8String:szMessageText];
    if(false == bUsingSheet)
    {
      NSWindow* w = [NSApp keyWindow];
      if(nil == w)
      {
        NSApplicationLoad();
        NSRunAlertPanel(nsCaptionText, nsMessageText, @"Ok", nil, nil);
      }
      else
      {
        CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
        [cmb setAttachWithWindow:w];
        [cmb showMessage:nsCaptionText AndMessage:nsMessageText];
      }
    }
    else
    {
      CocoaSheetMessageBox* cmb = [[[CocoaSheetMessageBox alloc] init] autorelease];
      [cmb setAttachWithWindowNumber:iDocWindowNo];
      [cmb showMessage:nsCaptionText AndMessage:nsMessageText];
    }
    [pool release];
  }
  
} // namespace NixMessageBox

#endif


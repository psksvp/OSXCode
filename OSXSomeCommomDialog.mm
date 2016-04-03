#import "OSXSomeCommonDialog.h"
#import "NixMessageBox.h"
#import <cocoa/cocoa.h>

#include "psksvp.h"
#include <iostream>
#include <sstream>

namespace OSX
{
  int ShowDialogToSelectListOfString(std::vector<std::string>& list, const char* szPrompt)
  {
    NSMutableString* strSrc = [[NSMutableString alloc] init];
    [strSrc appendString:@"choose from list{"];
    for(int i = 0; i < list.size(); i++)
    {
      [strSrc appendFormat:@"\"%@\"", [NSString stringWithCString:list[i].c_str() encoding:NSASCIIStringEncoding]];
      if(i != list.size() - 1)
        [strSrc appendString:@", "];
    }
    [strSrc appendString: [NSString stringWithFormat:@"} with prompt \" %@ \"", [NSString stringWithCString:szPrompt encoding:NSASCIIStringEncoding]]]; 
  
    NSAppleScript* showUIScript = [[NSAppleScript alloc] initWithSource:strSrc];
    NSAppleEventDescriptor* result = [showUIScript executeAndReturnError:nil];
    std::string strResult = [[result stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    int resultIdx = psksvp::SearchInVector<std::string>(strResult, list);
    if(resultIdx >= 0 && resultIdx < list.size())
      NSLog(@"user selected %@", [NSString stringWithCString:list[resultIdx].c_str() encoding:NSASCIIStringEncoding]);
    else
      NSLog(@"user cancel???");
    
                           
    [showUIScript release];
                           
    return resultIdx;
  }
  
  int ShowDialogToEnterText(std::string& strDefaultAndResult, const char* szPrompt, const char* szWindowTitle)
  {
    const char szScript[] = 
     "(display dialog " \
     "\"%s\" with title "\
     "\"%s\" with icon note "\
     "default answer "\
     "\"%s\" buttons {\"OK\"} "\
     "default button 1) ";
    
    char szWithParmScript[5000];
    
    ::sprintf(szWithParmScript, szScript, szPrompt, szWindowTitle, strDefaultAndResult.c_str()); 
    NSString* strScript = [NSString stringWithCString:szWithParmScript encoding:NSASCIIStringEncoding];
    
    NSAppleScript* showUIScript = [[NSAppleScript alloc] initWithSource:strScript];
    NSAppleEventDescriptor* result = [showUIScript executeAndReturnError:nil];
    strDefaultAndResult = [[[result descriptorForKeyword:'ttxt'] stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog (@"%@", [[result descriptorForKeyword:'ttxt'] stringValue]);
    
    int resultIdx = [result int32Value];
    
    [showUIScript release];
    
    return resultIdx;
  }
  
  int ShowDialogToEnterNumber(double& numberDefaultAndResult, double min, double max, const char* szPrompt)
  {
    std::string strBuffer;
    bool bOK = false;
    while(!bOK)
    {
      std::stringstream ss0;
      ss0 << numberDefaultAndResult;
      strBuffer = ss0.str();
      
      std::stringstream ss1;
      ss1 << "Pleace enter number between " << min << " and " << max;
      
      OSX::ShowDialogToEnterText(strBuffer, szPrompt, ss1.str().c_str());
      numberDefaultAndResult = ::atof(strBuffer.c_str());
      NSLog(@"-->%f", numberDefaultAndResult);
      if(numberDefaultAndResult < min || numberDefaultAndResult > max)
      {
        NixMessageBox::ShowMessage(ss1.str().c_str(), "error");
      }
      else 
      {
        bOK = true;
      }
    }
    return 0;
  }
  
  /*
  NSString* ShowDialogToSelectOneDirectory()
  {
    
  } */
}



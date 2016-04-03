


#import "OSXPowerState.h"

@implementation OSXPowerState

- (id)init
{
	self = [super init];
	[self registerForPowerStateChangeNotifications];
	return self;
}

- (void)dealloc
{
	[self deregisterForPowerStateChangeNotifications];
}

- (void)registerForPowerStateChangeNotifications
{
	CFrls = (CFRunLoopSourceRef) IOPSNotificationCreateRunLoopSource(PowerSourcesHaveChanged, NULL);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), CFrls, kCFRunLoopDefaultMode);	
}

void PowerSourcesHaveChanged(void *context)
{	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"powerAdapterStateChanged" object:nil];
}

- (void)deregisterForPowerStateChangeNotifications
{
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), CFrls, kCFRunLoopDefaultMode);
	CFRelease(CFrls);
}

- (BOOL)isBatteryPresent
{
	CFTypeRef	powerBlob =  (CFTypeRef) IOPSCopyPowerSourcesInfo();
	CFArrayRef	powerSourcesList = (CFArrayRef ) IOPSCopyPowerSourcesList(powerBlob);
	
	unsigned	count = CFArrayGetCount(powerSourcesList);
	unsigned i; 
	for ( i = 0U; i < count; ++i) {
		CFTypeRef		powerSource;
		CFDictionaryRef description;
		powerSource = CFArrayGetValueAtIndex(powerSourcesList, i);
		description = IOPSGetPowerSourceDescription(powerBlob, powerSource);
		CFBooleanRef isBatteryPresent =  CFDictionaryGetValue(description, CFSTR(kIOPSIsPresentKey));
		
		if(isBatteryPresent == kCFBooleanTrue) {
			status = TRUE;
		}else{
			status = FALSE;
		}		
	}
	
	CFRelease(powerSourcesList);
	CFRelease(powerBlob);
	
	return status;
}


- (BOOL)isACPowered
{
	CFTypeRef	powerBlob =  (CFTypeRef) IOPSCopyPowerSourcesInfo();
	CFArrayRef	powerSourcesList = (CFArrayRef ) IOPSCopyPowerSourcesList(powerBlob);
	
	unsigned	count = CFArrayGetCount(powerSourcesList);
	unsigned i; 
	for ( i = 0U; i < count; ++i) {
		CFTypeRef		powerSource;
		CFDictionaryRef description;

		powerSource = CFArrayGetValueAtIndex(powerSourcesList, i);
		description = IOPSGetPowerSourceDescription(powerBlob, powerSource);
			
	   if (stringsAreEqual(CFDictionaryGetValue(description, CFSTR(kIOPSTransportTypeKey)), CFSTR(kIOPSInternalType))) {
			
		   CFStringRef currentState = CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey));
		   if (stringsAreEqual(currentState, CFSTR(kIOPSACPowerValue)))
		   {
			   status =  TRUE;
		   } else if (stringsAreEqual(currentState, CFSTR(kIOPSBatteryPowerValue))) {
			   status =  FALSE;
		   }else {
		   }
	   }
	}
 
	CFRelease(powerSourcesList);
	CFRelease(powerBlob);
	
	return status;
}

- (int)currentBatteryPowerLevel
{
	CFTypeRef	powerBlob =  (CFTypeRef) IOPSCopyPowerSourcesInfo();
	CFArrayRef	powerSourcesList = (CFArrayRef ) IOPSCopyPowerSourcesList(powerBlob);
	
	unsigned	count = CFArrayGetCount(powerSourcesList);
	unsigned i; 
  int level;
	for ( i = 0U; i < count; ++i) 
  {
		CFTypeRef		powerSource;
		CFDictionaryRef description;
    
		powerSource = CFArrayGetValueAtIndex(powerSourcesList, i);
		description = IOPSGetPowerSourceDescription(powerBlob, powerSource);
    
    if (stringsAreEqual(CFDictionaryGetValue(description, CFSTR(kIOPSTransportTypeKey)),CFSTR(kIOPSInternalType))) 
    {
			CFNumberRef val = CFDictionaryGetValue(description, CFSTR(kIOPSCurrentCapacityKey));
     
      CFNumberGetValue(val, kCFNumberIntType, &level);
    }
	}
  
	CFRelease(powerSourcesList);
	CFRelease(powerBlob);
	
	return level;
}

static bool stringsAreEqual(CFStringRef a, CFStringRef b)
{
	if (!a || !b) return 0;
	
	return (CFStringCompare(a, b, 0) == kCFCompareEqualTo);
}
@end


#ifdef __TEST_WITH_MAIN__


int main(int argc, char** argv)
{  
  PowerState* ps = [[PowerState alloc] init];
  
  NSLog(@"isACPowered %d", [ps isACPowered]);
  NSLog(@"isBatteryPresent %d", [ps isBatteryPresent]);
  NSLog(@"currentBatteryLevel %d", [ps currentBatteryPowerLevel]);
  [ps release];
  
  return 0;
}

#endif


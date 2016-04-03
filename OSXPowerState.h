
 

#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>

typedef enum {
	HGUnknownPower = -1,
	HGACPower = 0,
	HGBatteryPower,
	HGUPSPower
}  HGPowerSource;

@interface OSXPowerState : NSObject {
	CFRunLoopSourceRef	CFrls;
	CFTypeRef sourceRef;
	CFTypeRef sourceRef2;	
	NSArray *powerSources;
	NSDictionary *sourceData;
	NSEnumerator *enumerator;
	BOOL status;
}

- (void)registerForPowerStateChangeNotifications;
- (void)deregisterForPowerStateChangeNotifications;
- (BOOL)isACPowered;
- (BOOL)isBatteryPresent;
- (int)currentBatteryPowerLevel;

void PowerSourcesHaveChanged(void *context);
static bool stringsAreEqual(CFStringRef a, CFStringRef b);

@end


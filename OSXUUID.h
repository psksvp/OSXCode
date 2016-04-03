#import <Cocoa/Cocoa.h>


@interface OSXUUID : NSObject <NSCoding,NSCopying> 
{
	unsigned char uu[16];
}

+ (OSXUUID*)uuid;
+ (OSXUUID*)uuidWithStringValue:(NSString*)string;

- (id)init;
- (id)initWithStringValue:(NSString*)string;

- (NSString*)stringValue;

- (NSComparisonResult)compare:(OSXUUID*)uuid;
- (BOOL)isEqualToOSXUUID:(OSXUUID*)uuid;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end


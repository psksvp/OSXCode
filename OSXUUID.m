#include <uuid/uuid.h>
#import "OSXUUID.h"

@interface OSXUUID (priv)
- (id)_initWithUUIDData:(char*)data;
- (unsigned char*)_uu;
@end

@implementation OSXUUID

+(OSXUUID*)uuid
{ 
  return [[[self class] alloc] init]; 
}

+(OSXUUID*)uuidWithStringValue:(NSString*)string
{ 
  return [[[self class] alloc] initWithStringValue:string]; 
}

-(id)init 
{
	if ((self = [super init])) 
  {
		uuid_generate(uu);
	}
	return self;
}

- (id)initWithStringValue:(NSString*)string 
{
	if ((self = [super init])) 
  {
		if (uuid_parse([string UTF8String], uu) != 0) 
    {
			return nil;
		}
	}
	return self;
}

- (id)_initWithUUIDData:(char*)data 
{
	if ((self = [super init])) 
  {
		strncpy((char*)uu,data,sizeof(uuid_t));
	}
	return self;
}

- (NSString*)stringValue
{
	char str[37];
	uuid_unparse_upper(uu, str);
	return [[NSString alloc] initWithUTF8String:str];
}

- (NSComparisonResult)compare:(OSXUUID*)uuid 
{
	return uuid_compare(uu, [uuid _uu]);
}

- (BOOL)isEqualToOSXUUID:(OSXUUID*)uuid 
{
	return ([self compare:uuid] == NSOrderedSame);
}

- (NSString*)description 
{
	return [self stringValue];
}

- (unsigned char*)_uu 
{
	return uu;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    if ([coder allowsKeyedCoding]) 
    {
        [coder encodeObject:[NSData dataWithBytes:uu length:sizeof(uuid_t)] forKey:@"uuid"];
    } 
    else 
    {
        [coder encodeObject:[NSData dataWithBytes:uu length:sizeof(uuid_t)]];
    }
    return;
}

- (id)initWithCoder:(NSCoder *)coder 
{
    if ((self = [super init])) 
    {
		if ( [coder allowsKeyedCoding] ) 
    {
			NSData* data = [coder decodeObjectForKey:@"uuid"];
			[data getBytes:uu length:sizeof(uuid_t)];
		} 
    else 
    {
			NSData* data = [coder decodeObject];
			[data getBytes:uu length:sizeof(uuid_t)];
		}
	}
    return self;
}

- (id)copyWithZone:(NSZone *)zone 
{
	return [[OSXUUID allocWithZone:zone] _initWithUUIDData:(char*)uu];
}

@end

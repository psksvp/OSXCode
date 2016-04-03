//
//  OSXBOOLString.h
//  Common
//
//  Created by Pongsak Suvanpong on 30/05/12.
//  Copyright (c) 2012 RobotVision2. All rights reserved.
//
 
#define NSStringToObjcBool(s)  (NSOrderedSame == [s compare:@"YES"] ? YES : NO)
#define ObjcBoolToNSString(b)  (YES == b ? @"YES" : @"NO")



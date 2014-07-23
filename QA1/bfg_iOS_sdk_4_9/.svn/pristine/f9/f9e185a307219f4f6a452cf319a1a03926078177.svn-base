//
//  bfgLog.h
//  BFGUIKitExample
//
//  Created by John Starin on 4/12/13.
//  Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// bfgLog notes:
//  - prepends '[className methodName] ' before whatever is being logged. Works for both class and instance methods.
//  -  presumes self to be either an NSObject or a Class
//  -  BFGUIKitExampleLog creates a private namespace and treats 'self' as an id to avoid compiler warnings.
//  -- BFGUIKitExampleBlockLog must be used insides blocks and refer to a __block version of self called blockSelf.
#ifdef BFGLIB_DEBUG
BOOL BFGUIKitExampleShouldLog(id entity);
#define BFGUIKitExampleLog(format, ...) { id s = self; if (BFGUIKitExampleShouldLog(s)) { NSString * fmt = [NSString stringWithFormat:format, ##__VA_ARGS__]; NSString * str = [s isKindOfClass:[NSObject class]] ? NSStringFromClass([s class]) : NSStringFromClass(s); NSLog(@"%@ %@ %@", str, NSStringFromSelector(_cmd), fmt); }}
#define BFGUIKitExampleBlockLog(format, ...) { id s = weakSelf; if (BFGUIKitExampleShouldLog(s)) { NSString * fmt = [NSString stringWithFormat:format, ##__VA_ARGS__]; NSString * str = [s isKindOfClass:[NSObject class]] ? NSStringFromClass([s class]) : NSStringFromClass(s); NSLog(@"%@ %@ %@", str, NSStringFromSelector(_cmd), fmt); }}
#else
#define BFGUIKitExampleLog(...)
#define BFGUIKitExampleBlockLog(...)
#endif
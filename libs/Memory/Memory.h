//
//  Memory.h
//
//  Created by Andrew Romanov on 30.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Memory : NSObject 
{
  
}
+ (void)setRetain:(NSObject**)currObj newObj:(NSObject*)newObj;
+ (void)assignCurrObj:(NSObject**)currObj newObj:(NSObject*)newObj;
+ (void)releaseWithNil:(NSObject**)obj;
@end


#if ! __has_feature(objc_arc)
#define MAutorelease(__v) ([__v autorelease])
#define MReturnAutoreleased(__v) ([__v autorelease])

#define MRetain(__v) ([__v retain])
#define MReturnRetained MRetain

#define MRelease(__v) ([__v release])
#define MSafeRelease(__v) ([__v release], __v = nil)
#define MSuperDealloc ([super dealloc])

#define MWeak
#define MStrong

#define MASSIGN_RETAIN(dst, src) [Memory setRetain:&dst newObj:src]
#define MRELEASE_NIL(obj) [Memory releaseWithNil:&obj]

#define MStartAutoreleasePoll NSAutoreleasePool* _autoreleasePoolStarted = [[NSAutoreleasePool alloc] init];
#define MEndAutoreleasePoll [_autoreleasePoolStarted drain];

#define MWeakProperty assign

#else
// -fobjc-arc
#define MAutorelease(__v)
#define MReturnAutoreleased(__v) (__v)

#define MRetain(__v)
#define MReturnRetained(__v) (__v)

#define MRelease(__v)
#define MSafeRelease(__v) (__v = nil)
#define MSuperDealloc

#define MWeak __weak
#define MStrong __strong

#define MASSIGN_RETAIN(dst, src) (dst = src)
#define MRELEASE_NIL(obj) obj = nil

#define MStartAutoreleasePoll @autoreleasepool {
#define MEndAutoreleasePoll }

#define MWeakProperty strong

#endif



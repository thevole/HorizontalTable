//
//  Memory.h
//
//  Created by Andrew Romanov on 30.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Memory.h"


@implementation Memory
//----------------------------------------------------------
+ (void)setRetain:(NSObject**)currObj newObj:(NSObject*)newObj
{
  if(*currObj != newObj)
  {
    if(*currObj)
    {
		 MRelease(*currObj);
    }
	  
	  *currObj = MReturnRetained(newObj);
  }
}
//---------------------------------------------------------
+ (void)releaseWithNil:(NSObject**)obj
{
  if(*obj)
  {
	  MRelease(*obj);
    *obj = nil;
  }
}
//----------------------------------------------------------
+ (void)assignCurrObj:(NSObject**)currObj newObj:(NSObject*)newObj
{
  if(*currObj != newObj)
  {
    #ifndef __OPTIMIZE__
    if((*currObj != nil) && (newObj == nil))
    {
      NSLog(@"WARNING:assign nil object to not nil poiner");
    }
    #endif
    *currObj = newObj;
  }
}

@end

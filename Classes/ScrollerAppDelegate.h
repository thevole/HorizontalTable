//
//  ScrollerAppDelegate.h
//  Scroller
//
//  Created by Martin Volerich on 5/21/10.
//  Copyright Bill Bear Technologies 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageLoopViewController;

@interface ScrollerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PageLoopViewController *viewController;
}



@end


//
//  ScrollerAppDelegate.m
//  Scroller
//
//  Created by Martin Volerich on 5/21/10.
//  Copyright Bill Bear Technologies 2010. All rights reserved.
//

#import "ScrollerAppDelegate.h"
#import "PageLoopViewController.h"

@implementation ScrollerAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    viewController = [[PageLoopViewController alloc] init];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

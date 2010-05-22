//
//  PageLoopViewController.h
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Bill Bear Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageLoopView;

@interface PageLoopViewController : UIViewController {
    PageLoopView *pageLoopView;
}

@property (nonatomic, retain) IBOutlet PageLoopView *pageLoopView;

@end

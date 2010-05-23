//
//  PageLoopViewController.h
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Bill Bear Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalTableView.h"

@interface PageLoopViewController : UIViewController <HorizontalTableViewDelegate> {
    HorizontalTableView *tableView;
    
    NSArray *colors;
    
    UIView *columnView;
}

@property (nonatomic, retain) IBOutlet HorizontalTableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *columnView;

@end

    //
//  PageLoopViewController.m
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Bill Bear Technologies. All rights reserved.
//

#import "PageLoopViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PageLoopViewController

@synthesize tableView;

#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
}


- (void)dealloc {
    [tableView release], tableView = nil;
    [super dealloc];
}

#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *layer = [self.tableView layer];
    [layer setCornerRadius:15.0f];
    
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    NSInteger step = 10;
    for (NSInteger i = 0; i < 255; i += step) {
        CGFloat f = (float)i/255.0f;
        UIColor *clr = [UIColor colorWithRed:f green:f blue:f alpha:1.0f];
        [colorArray addObject:clr];
    }
    colors = colorArray;
    [self.tableView refreshData];    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark HorizontalTableViewDelegate methods

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView {
    return [colors count];
}

- (UIView *)tableView:(HorizontalTableView *)aTableView viewForIndex:(NSInteger)index {
    
    CGFloat height = aTableView.bounds.size.height;
    CGFloat width = 150.0f;
    UIView *pageView = [[UIView alloc] init];
    pageView.frame = CGRectMake(0.0f, 0.0f, width, height);
    [pageView setBackgroundColor:[colors objectAtIndex:index]];
	pageView.contentMode = UIViewContentModeScaleToFill;
    
    CGPoint centerPt = pageView.center;
    UILabel *lbl = [[UILabel alloc] initWithFrame:pageView.bounds];
    lbl.text = [NSString stringWithFormat:@"%d", index];
    lbl.textColor = [UIColor redColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.font = [UIFont boldSystemFontOfSize:24.0f];
    [pageView addSubview:lbl];
    [lbl release];
    
	return [pageView autorelease];
}





@end

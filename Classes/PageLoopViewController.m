    //
//  PageLoopViewController.m
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Bill Bear Technologies. All rights reserved.
//

#import "PageLoopViewController.h"


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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark HorizontalTableViewDelegate methods

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView {
    return 3;
}

- (UIView *)tableView:(HorizontalTableView *)aTableView viewForIndex:(NSInteger)index {
    UIImage *image = nil;
	switch(index) {
		case 0: image = [UIImage imageNamed:@"image1.png"]; break;
		case 1: image = [UIImage imageNamed:@"image2.png"]; break;
		case 2: image = [UIImage imageNamed:@"image3.png"]; break;
	}
	UIImageView *pageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    CGRect rect = aTableView.bounds;
    pageView.frame = rect;
	pageView.contentMode = UIViewContentModeScaleToFill;
	return pageView;
}




@end

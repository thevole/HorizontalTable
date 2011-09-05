//
//  PageLoopViewController.m
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Martin Volerich - Bill Bear Technologies. All rights reserved.
//

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>

#import "PageLoopViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PageLoopViewController

@synthesize tableView;
@synthesize columnView;

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
    self.columnView = nil;
}


- (void)dealloc {
    [tableView release], tableView = nil;
    [columnView release], columnView = nil;
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
    NSInteger step = 5;
    for (NSInteger i = 0; i < 255; i += step) {
        CGFloat f = (float)i/255.0f;
        UIColor *clr = [UIColor colorWithRed:f green:f blue:f alpha:1.0f];
        [colorArray addObject:clr];
    }
    colors = colorArray;
   // [self.tableView refreshData];    
    [self.tableView performSelector:@selector(refreshData) withObject:nil afterDelay:0.3f];
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
    
    UIView *vw = [aTableView dequeueColumnView];
    if (!vw) {
        DLog(@"Constructing new view");
        
        [[NSBundle mainBundle] loadNibNamed:@"ColumnView" owner:self options:nil];
        vw = self.columnView;
        self.columnView = nil;
        
    }
    [vw setBackgroundColor:[colors objectAtIndex:index]];

    
    UILabel *lbl = (UILabel *)[vw viewWithTag:1234];
    lbl.text = [NSString stringWithFormat:@"%d", index];
    
	return vw;
}

- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView {
    return 150.0f;
}

@end

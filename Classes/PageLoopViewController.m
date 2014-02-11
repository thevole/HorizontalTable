//
//  PageLoopViewController.m
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Martin Volerich - Bill Bear Technologies. All rights reserved.
//

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
// AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

#import "PageLoopViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Memory.h"


@implementation PageLoopViewController

@synthesize tableView;
@synthesize columnView;

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
    self.columnView = nil;
}


- (void)dealloc
{
	tableView.delegate = nil;
	MRELEASE_NIL(tableView);
	MRELEASE_NIL(columnView);
	MSuperDealloc;
}

#pragma mark -
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *layer = [self.tableView layer];
    [layer setCornerRadius:15.0f];
    
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    NSInteger step = 5;
    for (NSInteger i = 0; i < 255; i += step)
	 {
        CGFloat f = (float)i/255.0f;
        UIColor *clr = [UIColor colorWithRed:f green:f blue:f alpha:1.0f];
        [colorArray addObject:clr];
    }
	
    colors = colorArray;
    [self.tableView performSelector:@selector(refreshData) withObject:nil afterDelay:0.3f];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark HorizontalTableViewDelegate methods

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView
{
    return [colors count];
}


- (UIView *)tableView:(HorizontalTableView *)aTableView viewForIndex:(NSInteger)index
{
   UIView *vw = [aTableView dequeueColumnView];
    if (!vw)
	 {
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


- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView
{
    return 150.0f;
}

@end

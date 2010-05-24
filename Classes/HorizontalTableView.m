
#import "HorizontalTableView.h"

#define kColumnPoolSize 3

@interface HorizontalTableView() <UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger physicalPageIndex;
@property (nonatomic, retain) NSMutableArray *columnPool;

- (void)prepareView;
- (void)layoutPages;
- (void)currentPageIndexDidChange;
- (NSUInteger)numberOfPages;
- (void)layoutPhysicalPage:(NSUInteger)pageIndex;
- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex;
- (void)removeColumn:(NSInteger)index;

@end


@implementation HorizontalTableView

@synthesize pageViews=_pageViews;
@synthesize scrollView=_scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize delegate=_delegate;
@synthesize columnPool=_columnPool;



- (void)refreshData {
    self.pageViews = [NSMutableArray array];
	// to save time and memory, we won't load the page views immediately
	NSUInteger numberOfPhysicalPages = [self numberOfPages];
	for (NSUInteger i = 0; i < numberOfPhysicalPages; ++i)
		[self.pageViews addObject:[NSNull null]];
    
    [self setNeedsLayout];
}

- (NSUInteger)numberOfPages {
	NSInteger numPages = 0;
    if (_delegate)
        numPages = [_delegate numberOfColumnsForTableView:self];
    return numPages;
}

- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex {
	NSParameterAssert(pageIndex >= 0);
	NSParameterAssert(pageIndex < [self.pageViews count]);
	
	UIView *pageView;
	if ([self.pageViews objectAtIndex:pageIndex] == [NSNull null]) {
        
        if (_delegate) {
            pageView = [_delegate tableView:self viewForIndex:pageIndex];
            [self.pageViews replaceObjectAtIndex:pageIndex withObject:pageView];
            [self.scrollView addSubview:pageView];
            DLog(@"View loaded for page %d", pageIndex);
        }
	} else {
		pageView = [self.pageViews objectAtIndex:pageIndex];
	}
	return pageView;
}

- (CGSize)pageSize {
    CGRect rect = self.scrollView.bounds;
	return rect.size;
}

- (CGFloat)columnWidth {
    if (!_columnWidth) {
        if (_delegate) {
            CGFloat width = [_delegate columnWidthForTableView:self];
            _columnWidth = [[NSNumber numberWithFloat:width] retain];
        }
    }
    return [_columnWidth floatValue];

}

- (BOOL)isPhysicalPageLoaded:(NSUInteger)pageIndex {
	return [self.pageViews objectAtIndex:pageIndex] != [NSNull null];
}

- (void)layoutPhysicalPage:(NSUInteger)pageIndex {
	UIView *pageView = [self viewForPhysicalPage:pageIndex];
    CGFloat viewWidth = pageView.bounds.size.width;
	CGSize pageSize = [self pageSize];
    
    CGRect rect = CGRectMake(viewWidth * pageIndex, 0, viewWidth, pageSize.height);
	pageView.frame = rect;
}

- (void) awakeFromNib {
    [self prepareView];
}

- (void)queueColumnView:(UIView *)vw {
    if ([self.columnPool count] >= kColumnPoolSize) {
        return;
    }
    [self.columnPool addObject:vw];
}

- (UIView *)dequeueColumnView {
    UIView *vw = [[self.columnPool lastObject] retain];
    if (vw) {
        [self.columnPool removeLastObject];
        DLog(@"Supply from reuse pool");
    }
    return [vw autorelease];
}

- (void)removeColumn:(NSInteger)index {
    if ([self.pageViews objectAtIndex:index] != [NSNull null]) {
        DLog(@"Removing view at position %d", index);
        UIView *vw = [self.pageViews objectAtIndex:index];
        [self queueColumnView:vw];
        [vw removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)currentPageIndexDidChange {
    CGSize pageSize = [self pageSize];
    CGFloat columnWidth = [self columnWidth];
    _visibleColumnCount = pageSize.width / columnWidth + 2;
    
    NSInteger leftMostPageIndex = -1;
    NSInteger rightMostPageIndex = 0;
    
    for (NSInteger i = -2; i < _visibleColumnCount; i++) {
        NSInteger index = _currentPhysicalPageIndex + i;
        if (index < [self.pageViews count] && (index >= 0)) {
            [self layoutPhysicalPage:index];
            if (leftMostPageIndex < 0)
                leftMostPageIndex = index;
            rightMostPageIndex = index;
        }
    }
    
    // clear out views to the left
    for (NSInteger i = 0; i < leftMostPageIndex; i++) {
        [self removeColumn:i];
    }
    
    // clear out views to the right
    for (NSInteger i = rightMostPageIndex + 1; i < [self.pageViews count]; i++) {
        [self removeColumn:i];
    }

 
}

- (void)layoutPages {
	//CGSize pageSize = [self pageSize];
    CGSize pageSize = self.bounds.size;
	self.scrollView.contentSize = CGSizeMake([self.pageViews count] * [self columnWidth], pageSize.height);
	// move all visible pages to their places, because otherwise they may overlap
//	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
//		if ([self isPhysicalPageLoaded:pageIndex])
//			[self layoutPhysicalPage:pageIndex];
}

- (id)init {
    self = [super init];
    if (self) {
        [self prepareView];
    }
    return self;
}

- (void)prepareView {
	_columnPool = [[NSMutableArray alloc] initWithCapacity:kColumnPoolSize];
    _columnWidth = nil;
    [self setClipsToBounds:YES];
    
    self.autoresizesSubviews = YES;
    
    UIScrollView *scroller = [[UIScrollView alloc] init];
    CGRect rect = self.bounds;
    scroller.frame = rect;
    scroller.backgroundColor = [UIColor blackColor];
	scroller.delegate = self;
    scroller.autoresizesSubviews = YES;
    scroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	//self.scrollView.pagingEnabled = YES;
	scroller.showsHorizontalScrollIndicator = YES;
	scroller.showsVerticalScrollIndicator = NO;
    scroller.alwaysBounceVertical = NO;
    self.scrollView = scroller;
	[self addSubview:scroller];
    [scroller release], scroller = nil;
}


- (NSUInteger)physicalPageIndex {
    NSUInteger page = self.scrollView.contentOffset.x / [self columnWidth];
    return page;
}

- (void)setPhysicalPageIndex:(NSUInteger)newIndex {
	self.scrollView.contentOffset = CGPointMake(newIndex * [self pageSize].width, 0);
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //DLog(@"Did Scroll");
	if (_rotationInProgress)
		return; // UIScrollView layoutSubviews code adjusts contentOffset, breaking our logic
	
	NSUInteger newPageIndex = self.physicalPageIndex;
	if (newPageIndex == _currentPhysicalPageIndex) return;
	_currentPhysicalPageIndex = newPageIndex;
	_currentPageIndex = newPageIndex;
	
	[self currentPageIndexDidChange];
    
    CGSize rect = [self.scrollView contentSize];
    DLog(@"CSize = %@", NSStringFromCGSize(rect));
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	DLog(@"scrollViewDidEndDecelerating");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	_rotationInProgress = YES;
	
	// hide other page views because they may overlap the current page during animation
	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self viewForPhysicalPage:pageIndex].hidden = (pageIndex != _currentPhysicalPageIndex);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	// resize and reposition the page view, but use the current contentOffset as page origin
	// (note that the scrollview has already been resized by the time this method is called)
	//CGSize pageSize = [self pageSize];
	//UIView *pageView = [self viewForPhysicalPage:_currentPhysicalPageIndex];
	//pageView.frame = [self alignView:pageView forPage:_currentPageIndex inRect:CGRectMake(self.scrollView.contentOffset.x, 0, pageSize.width, pageSize.height)];
}

- (void)layoutSubviews {
    [self layoutPages];
    [self currentPageIndexDidChange];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// adjust frames according to the new page size - this does not cause any visible changes
	[self layoutPages];
	self.physicalPageIndex = _currentPhysicalPageIndex;
	
	// unhide
	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self viewForPhysicalPage:pageIndex].hidden = NO;
	
	_rotationInProgress = NO;
    self.scrollView.contentSize = CGSizeMake([self.pageViews count] * [self columnWidth], [self pageSize].height);

    [self currentPageIndexDidChange];
}


- (void)dealloc {
    [_columnPool release], _columnPool = nil;
    [_columnWidth release], _columnWidth = nil;
    [_pageViews release], _pageViews = nil;
    [_scrollView release], _scrollView = nil;
    [super dealloc];
}

@end

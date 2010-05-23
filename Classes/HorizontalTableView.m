
#import "HorizontalTableView.h"


@interface HorizontalTableView() <UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger physicalPageIndex;

- (NSUInteger)physicalPageForPage:(NSUInteger)page;
- (NSUInteger)pageForPhysicalPage:(NSUInteger)physicalPage;
- (void)prepareView;
- (void)layoutPages;
- (void)currentPageIndexDidChange;
- (NSUInteger)numberOfPages;

@end


@implementation HorizontalTableView

@synthesize pageViews=_pageViews;
@synthesize scrollView=_scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize delegate=_delegate;


- (void)refreshData {
    self.pageViews = [NSMutableArray array];
	// to save time and memory, we won't load the page views immediately
	NSUInteger numberOfPhysicalPages = [self numberOfPages];
	for (NSUInteger i = 0; i < numberOfPhysicalPages; ++i)
		[self.pageViews addObject:[NSNull null]];
    
    if ([self.pageViews count] > 0) {
        [self layoutPages];
        [self currentPageIndexDidChange];
        [self setPhysicalPageIndex:[self physicalPageForPage:_currentPageIndex]];
    }
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
	return self.scrollView.frame.size;
}

- (BOOL)isPhysicalPageLoaded:(NSUInteger)pageIndex {
	return [self.pageViews objectAtIndex:pageIndex] != [NSNull null];
}

- (void)layoutPhysicalPage:(NSUInteger)pageIndex {
	UIView *pageView = [self viewForPhysicalPage:pageIndex];
    CGFloat viewWidth = pageView.bounds.size.width;
	CGSize pageSize = [self pageSize];
    
    _visibleColumnCount = pageSize.width / viewWidth + 1;
    
    CGRect rect = CGRectMake(viewWidth * pageIndex, 0, viewWidth, pageSize.height);
	pageView.frame = rect;
}

- (void) awakeFromNib {
    [self prepareView];
}

- (void)currentPageIndexDidChange {
	[self layoutPhysicalPage:_currentPhysicalPageIndex];
    
    for (NSInteger i = 0; i < _visibleColumnCount; i++) {
        NSUInteger index = _currentPhysicalPageIndex + i;
        if (index < [self.pageViews count])
            [self layoutPhysicalPage:_currentPhysicalPageIndex + i];
    }
 
	if (_currentPhysicalPageIndex > 0)
		[self layoutPhysicalPage:_currentPhysicalPageIndex-1];
}

- (void)layoutPages {
	CGSize pageSize = [self pageSize];
	self.scrollView.contentSize = CGSizeMake([self.pageViews count] * pageSize.width, pageSize.height);
	// move all visible pages to their places, because otherwise they may overlap
	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self layoutPhysicalPage:pageIndex];
}

- (void)prepareView {
	
    [self setClipsToBounds:YES];
    
	self.scrollView = [[[UIScrollView alloc] init] autorelease];
    CGRect rect = self.bounds;
    self.scrollView.frame = rect;
	self.scrollView.delegate = self;
	//self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	[self addSubview:self.scrollView];
    
	[self refreshData];
}



- (void)layyoutSubviews {
    [self layoutPages];
	[self currentPageIndexDidChange];
	[self setPhysicalPageIndex:[self physicalPageForPage:_currentPageIndex]];
}

- (NSUInteger)physicalPageIndex {
	CGSize pageSize = [self pageSize];
	return (self.scrollView.contentOffset.x + pageSize.width / 2) / pageSize.width;
}

- (void)setPhysicalPageIndex:(NSUInteger)newIndex {
	self.scrollView.contentOffset = CGPointMake(newIndex * [self pageSize].width, 0);
}

- (NSUInteger)physicalPageForPage:(NSUInteger)page {
	NSParameterAssert(page < [self numberOfPages]);
	return page;
}

- (NSUInteger)pageForPhysicalPage:(NSUInteger)physicalPage {
    NSParameterAssert(physicalPage < [self numberOfPages]);
    return physicalPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_rotationInProgress)
		return; // UIScrollView layoutSubviews code adjusts contentOffset, breaking our logic
	
	NSUInteger newPageIndex = self.physicalPageIndex;
	if (newPageIndex == _currentPhysicalPageIndex) return;
	_currentPhysicalPageIndex = newPageIndex;
	_currentPageIndex = [self pageForPhysicalPage:_currentPhysicalPageIndex];
	
	[self currentPageIndexDidChange];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	DLog(@"scrollViewDidEndDecelerating");
	NSUInteger physicalPage = self.physicalPageIndex;
	NSUInteger properPage = [self physicalPageForPage:[self pageForPhysicalPage:physicalPage]];
	if (physicalPage != properPage)
		self.physicalPageIndex = properPage;
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// adjust frames according to the new page size - this does not cause any visible changes
	[self layoutPages];
	self.physicalPageIndex = _currentPhysicalPageIndex;
	
	// unhide
	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self viewForPhysicalPage:pageIndex].hidden = NO;
	
	_rotationInProgress = NO;
}


- (void)dealloc {
    [_pageViews release], _pageViews = nil;
    [_scrollView release], _scrollView = nil;
    [super dealloc];
}

@end


#import "HorizontalTableView.h"


@interface HorizontalTableView() <UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger physicalPageIndex;

- (NSUInteger)physicalPageForPage:(NSUInteger)page;
- (NSUInteger)pageForPhysicalPage:(NSUInteger)physicalPage;
- (void)prepareView;

@end


@implementation HorizontalTableView

@synthesize pageViews=_pageViews, scrollView=_scrollView, currentPageIndex=_currentPageIndex;



- (UIView *)loadViewForPage:(NSUInteger)pageIndex {
	UIImage *image = nil;
	switch(pageIndex % 3) {
		case 0: image = [UIImage imageNamed:@"image1.png"]; break;
		case 1: image = [UIImage imageNamed:@"image2.png"]; break;
		case 2: image = [UIImage imageNamed:@"image3.png"]; break;
	}
	UIImageView *pageView = [[[UIImageView alloc] initWithImage:image] autorelease];
	pageView.contentMode = UIViewContentModeScaleToFill;
	return pageView;
}

- (CGRect)alignView:(UIView *)view forPage:(NSUInteger)pageIndex inRect:(CGRect)rect {
	UIImageView *imageView = (UIImageView *)view;
	CGSize imageSize = imageView.image.size;
	CGFloat ratioX = rect.size.width / imageSize.width, ratioY = rect.size.height / imageSize.height;
	CGSize size = (ratioX < ratioY ?
				   CGSizeMake(rect.size.width, ratioX * imageSize.height) :
				   CGSizeMake(ratioY * imageSize.width, rect.size.height));
	return CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2,
					  rect.origin.y + (rect.size.height - size.height) / 2,
					  size.width, size.height);
}

- (NSUInteger)numberOfPages {
	return 3;
}

- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex {
	NSParameterAssert(pageIndex >= 0);
	NSParameterAssert(pageIndex < [self.pageViews count]);
	
	UIView *pageView;
	if ([self.pageViews objectAtIndex:pageIndex] == [NSNull null]) {
		pageView = [self loadViewForPage:pageIndex];
		[self.pageViews replaceObjectAtIndex:pageIndex withObject:pageView];
		[self.scrollView addSubview:pageView];
		DLog(@"View loaded for page %d", pageIndex);
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
	CGSize pageSize = [self pageSize];
	pageView.frame = [self alignView:pageView forPage:[self pageForPhysicalPage:pageIndex] inRect:CGRectMake(pageIndex * pageSize.width, 0, pageSize.width, pageSize.height)];
}

- (void) awakeFromNib {
    [self prepareView];
}

- (void)currentPageIndexDidChange {
	[self layoutPhysicalPage:_currentPhysicalPageIndex];
	if (_currentPhysicalPageIndex+1 < [self.pageViews count])
		[self layoutPhysicalPage:_currentPhysicalPageIndex+1];
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
	_pageLoopEnabled = YES;
	
	self.scrollView = [[[UIScrollView alloc] init] autorelease];
    CGRect rect = self.bounds;
    self.scrollView.frame = rect;
	self.scrollView.delegate = self;
	//self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	[self addSubview:self.scrollView];
    
	self.pageViews = [NSMutableArray array];
	// to save time and memory, we won't load the page views immediately
	NSUInteger numberOfPhysicalPages = (_pageLoopEnabled ? 3 * [self numberOfPages] : [self numberOfPages]);
	for (NSUInteger i = 0; i < numberOfPhysicalPages; ++i)
		[self.pageViews addObject:[NSNull null]];
    
    [self layoutPages];
	[self currentPageIndexDidChange];
	[self setPhysicalPageIndex:[self physicalPageForPage:_currentPageIndex]];
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
	return (_pageLoopEnabled ? page + [self numberOfPages] : page);
}

- (NSUInteger)pageForPhysicalPage:(NSUInteger)physicalPage {
	if (_pageLoopEnabled) {
		NSParameterAssert(physicalPage < 3 * [self numberOfPages]);
		return physicalPage % [self numberOfPages];
	} else {
		NSParameterAssert(physicalPage < [self numberOfPages]);
		return physicalPage;
	} 
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
	CGSize pageSize = [self pageSize];
	UIView *pageView = [self viewForPhysicalPage:_currentPhysicalPageIndex];
	pageView.frame = [self alignView:pageView forPage:_currentPageIndex inRect:CGRectMake(self.scrollView.contentOffset.x, 0, pageSize.width, pageSize.height)];
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

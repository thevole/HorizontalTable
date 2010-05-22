
#import <UIKit/UIKit.h>

@interface PageLoopView : UIView {
	NSMutableArray *_pageViews;
	UIScrollView *_scrollView;
	NSUInteger _currentPageIndex;
	NSUInteger _currentPhysicalPageIndex;
	BOOL _pageLoopEnabled;
	BOOL _rotationInProgress;
}

@end

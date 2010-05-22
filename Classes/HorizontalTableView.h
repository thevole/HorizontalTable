
#import <UIKit/UIKit.h>

@class HorizontalTableView;

@protocol HorizontalTableViewDelegate



@end



@interface HorizontalTableView : UIView {
	NSMutableArray *_pageViews;
	UIScrollView *_scrollView;
	NSUInteger _currentPageIndex;
	NSUInteger _currentPhysicalPageIndex;
	BOOL _pageLoopEnabled;
	BOOL _rotationInProgress;
}

@end


#import <UIKit/UIKit.h>

@class HorizontalTableView;

@protocol HorizontalTableViewDelegate

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView;
- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index;

@end



@interface HorizontalTableView : UIView {
	NSMutableArray *_pageViews;
	UIScrollView *_scrollView;
	NSUInteger _currentPageIndex;
	NSUInteger _currentPhysicalPageIndex;
	BOOL _rotationInProgress;
    
    NSUInteger _visibleColumnCount;
    
    id _delegate;
}

@property (assign) IBOutlet id<HorizontalTableViewDelegate> delegate;

- (void)refreshData;

@end

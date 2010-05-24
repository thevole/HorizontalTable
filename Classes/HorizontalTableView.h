
#import <UIKit/UIKit.h>

@class HorizontalTableView;

@protocol HorizontalTableViewDelegate

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView;
- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index;
- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView;

@end



@interface HorizontalTableView : UIView {
	NSMutableArray *_pageViews;
	UIScrollView *_scrollView;
	NSUInteger _currentPageIndex;
	NSUInteger _currentPhysicalPageIndex;
    
    NSInteger _visibleColumnCount;
    NSNumber *_columnWidth;
    
    id _delegate;
    
    NSMutableArray *_columnPool;
}

@property (assign) IBOutlet id<HorizontalTableViewDelegate> delegate;

- (void)refreshData;
- (UIView *)dequeueColumnView;

@end

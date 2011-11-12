//
//  FilteredAppListTableView.h
//  
//
//  Created by  on 11. 11. 12..
//  Copyright (c) 2011 deVbug. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilteredAppListCell.h"


@protocol FilteredAppListDelegate <NSObject>
- (FilteredListType)filteredListTypeWithIdentifier:(NSString *)identifier;
- (void)didSelectRowAtCell:(FilteredAppListCell *)cell;
@end


@interface FilteredAppListTableView : NSObject <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *_list;
	UIWindow *window;
}

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic) BOOL enableForceType;
@property (nonatomic) FilteredAppType filteredAppType;
@property (nonatomic, assign) id<FilteredAppListDelegate> delegate;
@property (nonatomic, copy) NSString *hudLabelText;
@property (nonatomic, copy) NSString *hudDetailsLabelText;

- (id)initForContentSize:(CGSize)size delegate:(id<FilteredAppListDelegate>)delegate filteredAppType:(FilteredAppType)type enableForce:(BOOL)enableForce;
- (UIView *)view;
- (void)loadFilteredList;
- (void)dealloc;

@end

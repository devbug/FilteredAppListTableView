//
//  FilteredAppListTableView.h
//  
//  
//  Copyright (c) 2011-2013 deVbug
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "FilteredAppListCell.h"


@protocol FilteredAppListDelegate <NSObject>
- (FilteredListType)filteredListTypeForIdentifier:(NSString *)identifier;
- (void)didSelectRowAtCell:(FilteredAppListCell *)cell;
@optional
- (BOOL)isOtherFilteredForIdentifier:(NSString *)identifier;
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
@property (nonatomic, retain) UIColor *noneTextColor;
@property (nonatomic, retain) UIColor *normalTextColor;
@property (nonatomic, retain) UIColor *forceTextColor;
@property (nonatomic) float iconMargin;

- (id)initForContentSize:(CGSize)size delegate:(id<FilteredAppListDelegate>)delegate filteredAppType:(FilteredAppType)type enableForce:(BOOL)enableForce;
- (UIView *)view;
- (void)loadFilteredList;
- (void)setDefaultTextColor;
- (void)setTextColors:(UIColor *)noneColor normalTextColor:(UIColor *)normalColor forceTextColor:(UIColor *)forceColor;
- (void)dealloc;

@end

//
//  PSFilteredAppListCell.h
//  
//  
//  Copyright (c) 2014 deVbug
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
#import <Preferences/Preferences.h>


typedef NSUInteger FilteredAppType;
enum {
	FilteredAppUsers			= 1 << 0,
	FilteredAppSystem			= 1 << 1,
	FilteredAppWebapp			= 1 << 2,
	FilteredAppAll				= 0xFFFFFFFF
};

typedef NSInteger FilteredListType;
enum {
	FilteredListNone			= 0,
	FilteredListNormal			= 1,
	FilteredListForce			= 2,
	FilteredListUserDefine		= 3
};

@interface PSFilteredAppListCell : PSTableCell

@property (nonatomic) FilteredListType filteredListType;
@property (nonatomic) BOOL enableForceType;
@property (nonatomic, retain) UIColor *noneTextColor;
@property (nonatomic, retain) UIColor *normalTextColor;
@property (nonatomic, retain) UIColor *forceTextColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)id specifier:(PSSpecifier *)specifier;
- (FilteredListType)toggle;
- (void)setDefaultTextColor;
- (void)setTextColors:(UIColor *)noneColor normalTextColor:(UIColor *)normalColor forceTextColor:(UIColor *)forceColor;
- (NSString *)displayId;

@end


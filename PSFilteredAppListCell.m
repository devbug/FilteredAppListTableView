//
//  PSFilteredAppListCell.m
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

#import "Preferences.h"
#import "PSFilteredAppListCell.h"


@implementation PSFilteredAppListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)id specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:@"PSFilteredListCell" specifier:specifier];
	
	if (self) {
		NSNumber *n = [specifier propertyForKey:@"enableForceType"];
		if (n) {
			_enableForceType = [n boolValue];
		}
		else {
			_enableForceType = NO;
		}
		n = [specifier propertyForKey:@"filteredListType"];
		if (n) {
			_filteredListType = [n intValue];
		}
		else {
			_filteredListType = FilteredListNone;
		}
		
		UIColor *noneTextColor = [specifier propertyForKey:@"noneTextColor"];
		UIColor *normalTextColor = [specifier propertyForKey:@"normalTextColor"];
		UIColor *forceTextColor = [specifier propertyForKey:@"forceTextColor"];
		
		if (noneTextColor == nil || normalTextColor == nil || forceTextColor == nil)
			[self setDefaultTextColor];
		
		if (noneTextColor) self.noneTextColor = noneTextColor;
		if (normalTextColor) self.normalTextColor = normalTextColor;
		if (forceTextColor) self.forceTextColor = forceTextColor;
	}
	
	return self;
}

- (FilteredListType)toggle {
	switch (_filteredListType) {
		case FilteredListNone:
			_filteredListType = FilteredListNormal;
			break;
		case FilteredListForce:
			_filteredListType = (_enableForceType ? FilteredListNone : FilteredListForce);
			break;
		case FilteredListNormal:
		default:
			_filteredListType = (_enableForceType ? FilteredListForce : FilteredListNone);
			break;
	}
	
	return _filteredListType;
}

- (void)setDefaultTextColor {
	self.noneTextColor = [UIColor blackColor];
	self.normalTextColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];
	self.forceTextColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1];
}

- (void)setTextColors:(UIColor *)noneColor normalTextColor:(UIColor *)normalColor forceTextColor:(UIColor *)forceColor {
	self.noneTextColor = noneColor;
	self.normalTextColor = normalColor;
	self.forceTextColor = forceColor;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (_noneTextColor == nil || _normalTextColor == nil || _forceTextColor == nil)
		[self setDefaultTextColor];
	
	switch (_filteredListType) {
		case FilteredListNormal:
			self.accessoryType = UITableViewCellAccessoryCheckmark;
			self.textLabel.textColor = _normalTextColor;
			break;
		case FilteredListForce:
			self.accessoryType = UITableViewCellAccessoryNone;
			self.textLabel.textColor = _forceTextColor;
			break;
		case FilteredListNone:
			self.accessoryType = UITableViewCellAccessoryNone;
			self.textLabel.textColor = _noneTextColor;
		default:
			break;
	}
}

- (NSString *)displayId {
	return [self.specifier propertyForKey:@"displayIdentifier"];
}

- (void)dealloc {
	self.noneTextColor = nil;
	self.normalTextColor = nil;
	self.forceTextColor = nil;
	
	[super dealloc];
}

@end



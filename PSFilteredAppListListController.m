//
//  PSFilteredAppListListController.m
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
#import "PSFilteredAppListListController.h"
#import "_UIBackdropView.h"

#import <dlfcn.h>
#import <objc/runtime.h>



@interface UITableViewHeaderFooterView (private_api)
@property(retain, nonatomic) UIImage *backgroundImage;
@end


/**
 * Backgrounder
 * 
 * Copyright (C) 2008-2010  Lance Fetters (aka. ashikase)
 * All rights reserved.
 * 
 * edited by deVbug
 */
//{{{
extern NSArray * SBSCopyApplicationDisplayIdentifiers(BOOL activeOnly, BOOL unknown);
extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
static CFSetRef (*pSBSCopyDisplayIdentifiers)() = NULL;

NSInteger compareDisplayNames(NSString *a, NSString *b, void *context) {
	NSInteger ret;
	
	NSString *name_a = SBSCopyLocalizedApplicationNameForDisplayIdentifier(a);
	NSString *name_b = SBSCopyLocalizedApplicationNameForDisplayIdentifier(b);
	ret = [name_a caseInsensitiveCompare:name_b];
	[name_a release];
	[name_b release];
	
	return ret;
}

NSArray *applicationDisplayIdentifiersForType(FilteredAppType type) {
	if (pSBSCopyDisplayIdentifiers == NULL)
		pSBSCopyDisplayIdentifiers = dlsym(RTLD_DEFAULT, "SBSCopyDisplayIdentifiers");
	
	// Get list of non-hidden applications
	NSArray *nonhidden = (pSBSCopyDisplayIdentifiers != NULL ? (NSArray *)(*pSBSCopyDisplayIdentifiers)() : SBSCopyApplicationDisplayIdentifiers(NO, NO));
	
	// Get list of hidden applications (assuming LibHide is installed)
	NSArray *hidden = nil;
	NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/LibHide/hidden.plist"];
	id value = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:@"Hidden"];
	if ([value isKindOfClass:[NSArray class]])
		hidden = (NSArray *)value;
	
	NSString *path = @"/var/mobile/Library/Caches/com.apple.mobile.installation.plist";
	NSDictionary *cacheDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSDictionary *systemApp = [cacheDict objectForKey:@"System"];
	NSArray *systemAppArr = [systemApp allKeys];
	
	// Record list of valid identifiers
	NSMutableArray *identifiers = [NSMutableArray array];
	for (NSArray *array in [NSArray arrayWithObjects:nonhidden, hidden, nil]) {
		for (NSString *identifier in array) {
			FilteredAppType isType = FilteredAppUsers;
			
			if ([identifier hasPrefix:@"com.apple.webapp"])
				isType = FilteredAppWebapp;
			else {
				for (NSString *systemIdentifier in systemAppArr) {
					 if ([identifier hasPrefix:systemIdentifier]) {
						isType = FilteredAppSystem;
						break;
					}
				}
			}
			
			if ((isType & type) == 0) continue;
			
			// Filter out non-apps and apps that are not executed directly
			// FIXME: Should Categories folders be in this list? Categories
			//        folders are apps, but when used with CategoriesSB they are
			//        non-apps.
			if (identifier
				&& ![identifier hasPrefix:@"jp.ashikase.springjumps."])
				//&& ![identifier isEqualToString:@"com.iptm.bigboss.sbsettings"]
				//&& ![identifier isEqualToString:@"com.apple.webapp"])
				[identifiers addObject:identifier];
		}
	}
	
	// Clean-up
	[nonhidden release];
	
	return identifiers;
}
//}}}

NSArray *applicationDisplayIdentifiers() {
	return applicationDisplayIdentifiersForType(FilteredAppAll);
}



@interface PSFilteredAppListTableView : UITableView
@end

@implementation PSFilteredAppListTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:UITableViewStylePlain];
	
	return self;
}

@end



@interface PSFilteredAppListListController ()
@property (nonatomic, retain) NSMutableArray *indexes;
@property (nonatomic) BOOL isNeedsToReload;
@end


@implementation PSFilteredAppListListController

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

- (void)dealloc {
	self.noneTextColor = nil;
	self.normalTextColor = nil;
	self.forceTextColor = nil;
	self.indexes = nil;
	
	[super dealloc];
}

- (void)setNeedsToReload {
	_isNeedsToReload = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_isNeedsToReload) {
		self.specifiers = [[self newAppSpecifiers] autorelease];
		_isNeedsToReload = NO;
	}
}


- (Class)tableViewClass {
	return [PSFilteredAppListTableView class];
}


- (NSMutableArray *)newAppSpecifiers {
	@autoreleasepool{
		NSMutableArray *__specifiers = [[NSMutableArray alloc] init];
		[_indexes release], _indexes = nil;
		_indexes = [[NSMutableArray alloc] init];
		
		NSSet *set = [NSSet setWithArray:applicationDisplayIdentifiersForType(_filteredAppType)];
		NSArray *sortedArray = [[set allObjects] sortedArrayUsingFunction:compareDisplayNames context:NULL];
		
		/**
		 * 0x3131 = 'ㄱ'    0x1100 = 'ᄀ'
		 * 0x3132 = 'ㄲ'    0x1101 = 'ᄁ'
		 * 0x3134 = 'ㄴ'    0x1102 = 'ᄂ'
		 * 0x3137 = 'ㄷ'    0x1103 = 'ᄃ'
		 * 0x3138 = 'ㄸ'    0x1104 = 'ᄄ'
		 * 0x3139 = 'ㄹ'    0x1105 = 'ᄅ'
		 * 0x3141 = 'ㅁ'    0x1106 = 'ᄆ'
		 * 0x3142 = 'ㅂ'    0x1107 = 'ᄇ'
		 * 0x3143 = 'ㅃ'    0x1108 = 'ᄈ'
		 * 0x3145 = 'ㅅ'    0x1109 = 'ᄉ'
		 * 0x3146 = 'ㅆ'    0x110A = 'ᄊ'
		 * 0x3147 = 'ㅇ'    0x110B = 'ᄋ'
		 * 0x3148 = 'ㅈ'    0x110C = 'ᄌ'
		 * 0x3149 = 'ㅉ'    0x110D = 'ᄍ'
		 * 0x314A = 'ㅊ'    0x110E = 'ᄎ'
		 * 0x314B = 'ㅋ'    0x110F = 'ᄏ'
		 * 0x314C = 'ㅌ'    0x1110 = 'ᄐ'
		 * 0x314D = 'ㅍ'    0x1111 = 'ᄑ'
		 * 0x314E = 'ㅎ'    0x1112 = 'ᄒ'
		 * 
		 * 0x3131 : ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ
		 * 0x1100 : ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄋᄌᄍᄎᄏᄐᄑᄒ
		 **/
		
		// http://pastebin.com/7YkT4dbk
		// 한글 로마자 변환 프로그램 by 동성
		NSString *choCharset = @"ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄋᄌᄍᄎᄏᄐᄑᄒ";
		
		unichar header = ' ', temp;
		for (NSString *displayId in sortedArray) {
			if ([_delegate respondsToSelector:@selector(isOtherFilteredForIdentifier:)])
				if ([_delegate isOtherFilteredForIdentifier:displayId])
					continue;
			
			NSString *name = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayId);
			
			if (name && name.length > 0 && strlen([name UTF8String]) > 0) {
				@try {
					temp = [[name uppercaseString] characterAtIndex:0];
					[name release];
					
					if(0xAC00 <= temp && temp <= 0xD7AF) {
						unsigned int choSung = (temp - 0xAC00) / (21*28);
						temp = [[choCharset substringWithRange:NSMakeRange(choSung, 1)] characterAtIndex:0];
					}
					
					if (header != temp) {
						header = temp;
						NSString *index = [NSString stringWithCharacters:&header length:1];
						[_indexes addObject:index];
						[__specifiers addObject:[PSSpecifier groupSpecifierWithName:index]];
					}
				}
				@catch (NSException *e) {
					//
				}
				@finally {
					//
				}
			}
			
			if ([_indexes count] > 0) {
				[__specifiers addObject:[self getSpecifierForDisplayIdentifier:displayId]];
			}
		}
		
		return __specifiers;
	}
}

- (PSSpecifier *)getSpecifierForDisplayIdentifier:(NSString *)displayId {
	NSString *name = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayId);
	PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:(name && name.length != 0 ? name : displayId)
															target:self
															   set:nil
															   get:nil
															detail:Nil
															  cell:PSButtonCell
															  edit:nil];
	[specifier setProperty:[PSFilteredAppListCell class] forKey:PSCellClassKey];
	[specifier setProperty:@(YES) forKey:PSLazyIconLoading];
	[specifier setProperty:displayId forKey:PSLazyIconAppID];
	[specifier setProperty:@(YES) forKey:@"enabled"];
	[specifier setProperty:@(1) forKey:PSAlignmentKey];
	specifier.buttonAction = @selector(selectAppItem:);
	
	[specifier setProperty:displayId forKey:@"displayIdentifier"];
	[specifier setProperty:@(_enableForceType) forKey:@"enableForceType"];
	[specifier setProperty:_noneTextColor forKey:@"noneTextColor"];
	[specifier setProperty:_normalTextColor forKey:@"normalTextColor"];
	[specifier setProperty:_forceTextColor forKey:@"forceTextColor"];
	if (_delegate)
		[specifier setProperty:@([_delegate filteredListTypeForIdentifier:displayId]) forKey:@"filteredListType"];
	
	return specifier;
}

- (id)specifiers {
	if (!_specifiers) {
		NSNumber *n = [self.specifier propertyForKey:@"enableForceType"];
		if (n) {
			_enableForceType = [n boolValue];
		}
		n = [self.specifier propertyForKey:@"filteredAppType"];
		if (n) {
			_filteredAppType = [n intValue];
		}
		
		if (_noneTextColor == nil || _normalTextColor == nil || _forceTextColor == nil)
			[self setDefaultTextColor];
		
		_specifiers = [self newAppSpecifiers];
		
		n = [self.specifier propertyForKey:@"isPopover"];
		if (n) {
			_isPopover = [n boolValue];
		}
		
		if (_isPopover) {
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:_delegate action:@selector(closeAppListView)] autorelease];
		}
	}
	
	return _specifiers;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return _indexes;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	Class UIBackdropView = objc_getClass("_UIBackdropView");
	Class HeaderFooterView = objc_getClass("UITableViewHeaderFooterView");
	if (HeaderFooterView != Nil && [view isKindOfClass:HeaderFooterView] && UIBackdropView != Nil) {
		UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
		if (![tableViewHeaderFooterView.backgroundView isKindOfClass:UIBackdropView]) {
			tableViewHeaderFooterView.contentView.backgroundColor = [UIColor clearColor];
			tableViewHeaderFooterView.tintColor = nil;
			if ([tableViewHeaderFooterView respondsToSelector:@selector(setBackgroundImage:)])
				tableViewHeaderFooterView.backgroundImage = nil;
			
			_UIBackdropViewSettings *settings = [objc_getClass("_UIBackdropViewSettings") settingsForStyle:2020 graphicsQuality:100];
			settings.blurRadius = 5.0f;
			_UIBackdropView *backdropView = [[UIBackdropView alloc] initWithSettings:settings];
			backdropView.appliesOutputSettingsAnimationDuration = 0.0f;
			backdropView.computesColorSettings = NO;
			backdropView.simulatesMasks = YES;
			tableViewHeaderFooterView.backgroundView = backdropView;
			[backdropView release];
		}
	}
}

- (BOOL)selectAppItem:(PSSpecifier *)specifier {
	NSIndexPath *indexPath = [self indexPathForSpecifier:specifier];
	PSFilteredAppListCell *cell = (PSFilteredAppListCell *)[self.table cellForRowAtIndexPath:indexPath];
	
	[cell toggle];
	
	if (_enableForceType == NO && cell.filteredListType == FilteredListForce) return NO;
	
	[_delegate didSelectRowAtCell:cell];
	
	return YES;
}


@end

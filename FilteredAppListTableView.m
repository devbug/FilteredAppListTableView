//
//  FilteredAppListTableView.m
//  
//
//  Created by  on 11. 11. 12..
//  Copyright (c) 2011 deVbug. All rights reserved.
//

#import "FilteredAppListTableView.h"
#import "../MBProgressHUD/MBProgressHUD.h"


#define HUD_TAG		998


extern NSInteger compareDisplayNames(NSString *a, NSString *b, void *context);
extern NSArray *applicationDisplayIdentifiersForMode(FilteredAppType type);
extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);



@interface FilteredAppListTableView ()
- (void)loadInstalledAppData;
- (id)makeCell:(NSString *)identifier;

- (int)numberOfSectionsInTableView:(UITableView *)tableView;
- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section;
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
@end


@implementation FilteredAppListTableView

@synthesize tableView, delegate, filteredAppType, enableForceType;
@synthesize hudLabelText, hudDetailsLabelText;

- (id)initForContentSize:(CGSize)size delegate:(id<FilteredAppListDelegate>)_delegate filteredAppType:(FilteredAppType)type enableForce:(BOOL)enableForce {
	if ((self = [super init]) != nil) {
		self.delegate = _delegate;
		self.filteredAppType = type;
		self.enableForceType = enableForce;
		_list = nil;
		self.hudLabelText = @"Loading Data";
		self.hudDetailsLabelText = @"Please wait...";
		
		window = [[UIApplication sharedApplication] keyWindow];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height-64) style:UITableViewStylePlain];
		[tableView setDelegate:self];
		[tableView setDataSource:self];
	}
	
	return self;
}

- (UIView *)view {
	return tableView;
}

- (void)dealloc {
	MBProgressHUD *HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG];
	[HUD removeFromSuperview];
	
	[tableView release];
	self.hudLabelText = nil;
	self.hudDetailsLabelText = nil;
	[_list release];
	
	[super dealloc];
}



- (void)loadFilteredList {
	MBProgressHUD *HUD = nil;
	if ((HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG]) == nil) {
		HUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:HUD];
	}
	HUD.labelText = hudLabelText;
	HUD.detailsLabelText = hudDetailsLabelText;
	HUD.labelFont = [UIFont fontWithName:@"Helvetica" size:24];
	HUD.detailsLabelFont = [UIFont fontWithName:@"Helvetica" size:18];
	HUD.tag = HUD_TAG;
	[HUD show:YES];
	[HUD release];
	
	[self performSelector:@selector(loadInstalledAppData) withObject:nil afterDelay:0.1f];
}


- (void)loadInstalledAppData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[tableView setDataSource:nil];
	[_list release];
	_list = [[NSMutableArray alloc] init];
	
	NSSet *set = [NSSet setWithArray:applicationDisplayIdentifiersForMode(filteredAppType)];
	NSArray *sortedArray = [[set allObjects] sortedArrayUsingFunction:compareDisplayNames context:NULL];
	
	// http://pastebin.com/7YkT4dbk
	// 한글 로마자 변환 프로그램 by 동성
	NSString *choCharset = @"ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ";
	
	unichar header = ' ', temp;
	for (NSString *displayId in sortedArray) {
		NSString *name = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayId);
		
		if (name) {
			temp = [[name uppercaseString] characterAtIndex:0];
			[name release];
			
			if(0xAC00 <= temp && temp <= 0xD7AF) {
				unsigned int choSung = (temp - 0xAC00) / (21*28);
				temp = [[choCharset substringWithRange:NSMakeRange(choSung, 1)] characterAtIndex:0];
			}
			
			if (header != temp) {
				header = temp;
				[_list addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCharacters:&header length:1], @"section", nil]];
			}
		}
		
		if ([_list count] > 0) {
			NSMutableArray *arr = [[_list objectAtIndex:[_list count]-1] objectForKey:@"data"];
			if (arr == nil)
				arr = [NSMutableArray array];
			[arr addObject:[self makeCell:displayId]];
			
			[[_list objectAtIndex:[_list count]-1] setObject:arr forKey:@"data"];
		}
	}
	
	[tableView setDataSource:self];
	[tableView reloadData];
	
	MBProgressHUD *HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG];
	[HUD hide:YES];
	
	[pool release];
}

- (id)makeCell:(NSString *)identifier {
	FilteredAppListCell *cell = [[[FilteredAppListCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"FilteredListCell"] autorelease];
	
	cell.enableForceType = enableForceType;
	cell.displayId = identifier;
	
	cell.filteredListType = [delegate filteredListTypeWithIdentifier:identifier];
	
	return cell;
}


- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!_list) return 1;
	return ([_list count] == 0 ? 1: [_list count]);
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	if (!_list || [_list count] == 0)
		return nil;
	
	return [[_list objectAtIndex:section] objectForKey:@"section"];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	if (!_list || [_list count] == 0)
		return 0;
	
	return [[[_list objectAtIndex:section] objectForKey:@"data"] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *arr = [NSMutableArray array];
	for (int i = 0; i < [_list count]; i++) {
		[arr addObject:[[_list objectAtIndex:i] objectForKey:@"section"]];
	}
	return arr;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FilteredAppListCell *cell = (FilteredAppListCell *)[[[_list objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row];
	
	[cell loadIcon];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FilteredAppListCell *cell = (FilteredAppListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	[cell toggle];
	
	[self.tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];
	
	if (enableForceType == NO && cell.filteredListType == FilteredListForce) return;
	
	[delegate didSelectRowAtCell:cell];
}


@end

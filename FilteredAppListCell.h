/**
 * Name: Backgrounder
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: allow applications to run in the background
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2010-06-21 00:16:38
 */
/**
 * Copyright (C) 2008-2010  Lance Fetters (aka. ashikase)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * FilteredAppListCell.h
 * 
 * edited by deVbug
 */

#import <UIKit/UIKit.h>

#include <dlfcn.h>


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

@interface FilteredAppListCell : UITableViewCell

@property (nonatomic, copy) NSString *displayId;
@property (nonatomic) FilteredListType filteredListType;
@property (nonatomic) BOOL isIconLoaded;
@property (nonatomic) BOOL enableForceType;
@property (nonatomic, retain) UIColor *noneTextColor;
@property (nonatomic, retain) UIColor *normalTextColor;
@property (nonatomic, retain) UIColor *forceTextColor;
@property (nonatomic) float iconMargin;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDisplayId:(NSString *)displayIdentifier;
- (void)loadIcon;
- (void)setIcon:(UIImage *)icon;
- (FilteredListType)toggle;
- (void)setDefaultTextColor;
- (void)setTextColors:(UIColor *)noneColor normalTextColor:(UIColor *)normalColor forceTextColor:(UIColor *)forceColor;

@end


//
//  TTPageControlModel.h
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTPageControlModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL dot_status;

@end

static CGFloat  TTPageControldefaultTitleWidth = 40.0f;
@interface TTPageControlLayout : NSObject

@property (nonatomic, strong) TTPageControlModel *model;
@property (nonatomic, assign, readonly) CGFloat titleWidth;

@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *highlightFont;
@property (nonatomic, assign) CGFloat normalFontSize;
@property (nonatomic, assign) CGFloat highlightFontSize;

@property (nonatomic, assign) CGFloat highlightScale;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;

@property (nonatomic, strong) UIFont *maxFont;
@property (nonatomic, assign) CGFloat scale;

- (instancetype)initWithModel:(TTPageControlModel *)model
                   normalFont:(UIFont *)normalFont
               highlightScale:(CGFloat)highlightScale
                  normalColor:(UIColor *)normalColor
               highlightColor:(UIColor *)highlightColor;

@end

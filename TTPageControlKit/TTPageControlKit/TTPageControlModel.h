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

@end

static CGFloat  TTPageControldefaultTitleWidth = 40.0f;
@interface TTPageControlLayout : NSObject

@property (nonatomic, strong) TTPageControlModel *model;
@property (nonatomic, assign, readonly) CGFloat titleWidth;

@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *highlightFont;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;

- (instancetype)initWithModel:(TTPageControlModel *)model
                   normalFont:(UIFont *)normalFont
                highlightFont:(UIFont *)highlightFont
                  normalColor:(UIColor *)normalColor
               highlightColor:(UIColor *)highlightColor;

@end

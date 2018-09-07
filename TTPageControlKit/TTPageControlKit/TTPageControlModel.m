//
//  TTPageControlModel.m
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTPageControlModel.h"

@implementation TTPageControlModel

@end


@interface TTPageControlLayout ()

@property (nonatomic, assign) CGFloat titleWidth;

@end
@implementation TTPageControlLayout

- (instancetype)initWithModel:(TTPageControlModel *)model
                   normalFont:(UIFont *)normalFont
                highlightFont:(UIFont *)highlightFont
                  normalColor:(UIColor *)normalColor
               highlightColor:(UIColor *)highlightColor{
    self = [super init];
    if (self) {
        _model = model;
        _normalFont = normalFont;
        _highlightFont = highlightFont;
        _normalColor = normalColor;
        _highlightColor = highlightColor;
    }
    return self;
}

- (CGFloat)titleWidth{
    if (!_titleWidth) {
        if (_model.title) {
            @try {
                // +4个像素防止加载文字显示不全
                _normalAttStr = [[NSMutableAttributedString alloc] initWithString:_model.title attributes:@{NSFontAttributeName:_normalFont, NSForegroundColorAttributeName:_normalColor}];
                _highlightAttStr = [[NSMutableAttributedString alloc] initWithString:_model.title attributes:@{NSFontAttributeName:_highlightFont, NSForegroundColorAttributeName:_highlightColor}];
                _titleWidth = MAX(_normalAttStr.size.width, _highlightAttStr.size.width) + 4;
            } @catch (NSException *exception) {
                _titleWidth = TTPageControldefaultTitleWidth;
            } @finally {
            }
        }else{
            _titleWidth = TTPageControldefaultTitleWidth;
        }
    }
    return _titleWidth;
}

@end

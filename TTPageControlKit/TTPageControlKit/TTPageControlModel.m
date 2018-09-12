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
               highlightScale:(CGFloat)highlightScale
                  normalColor:(UIColor *)normalColor
               highlightColor:(UIColor *)highlightColor{
    self = [super init];
    if (self) {
        _model = model;
        _normalFont = normalFont;
        _highlightScale = highlightScale;
        _normalColor = normalColor;
        _highlightColor = highlightColor;
        
        _normalFontSize = _normalFont.pointSize;
        _highlightFontSize = _normalFontSize*_highlightScale;
        _highlightFont = [UIFont fontWithName:_normalFont.fontName size:_highlightFontSize];
        
        _maxFont = _normalFontSize > _highlightFontSize ? _normalFont:_highlightFont;
        _scale = _normalFontSize > _highlightFontSize ? 1:(1.0/highlightScale);
    }
    return self;
}

- (CGFloat)titleWidth{
    if (!_titleWidth) {
        if (_model.title) {
            @try {
                // +4个像素防止加载文字显示不全
                NSAttributedString *att = [[NSMutableAttributedString alloc] initWithString:_model.title attributes:@{NSFontAttributeName:_maxFont, NSForegroundColorAttributeName:_normalColor}];
                _titleWidth = att.size.width + 4;
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

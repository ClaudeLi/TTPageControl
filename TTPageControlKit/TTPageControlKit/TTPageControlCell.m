//
//  TTPageControlCell.m
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTPageControlCell.h"
#import "TTPageControlModel.h"

@implementation TTPageControlCell

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = _layout.normalColor;
        _titleLabel.font = _layout.normalFont;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

- (void)setLayout:(TTPageControlLayout *)layout{
    if (_layout == layout) {
        return;
    }
    _layout = layout;
    self.titleLabel.text = _layout.model.title;
}

- (void)setIsSelect:(BOOL)isSelect{
    if (isSelect) {
        _titleLabel.textColor = _layout.highlightColor;
        _titleLabel.font = _layout.highlightFont;
    }else{
        _titleLabel.textColor = _layout.normalColor;
        _titleLabel.font = _layout.normalFont;
    }
}

@end

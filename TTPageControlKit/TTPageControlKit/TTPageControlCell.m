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
        _titleLabel.font = _layout.maxFont;  // 以大字体为默认字体，避免缩放模糊
        _titleLabel.transform = CGAffineTransformMakeScale(_layout.scale, _layout.scale);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)dotView{
    if (!_dotView) {
        _dotView = [UIImageView new];
        _dotView.frame = CGRectMake(self.bounds.size.width-4, 0, 6, 6);
        _dotView.image = [UIImage imageNamed:@"icon_tabbar_news_red"];
        [self.contentView addSubview:_dotView];
    }
    return _dotView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
    _dotView.frame = CGRectMake(self.bounds.size.width-4, 0, 6, 6);
}

- (void)setLayout:(TTPageControlLayout *)layout{
    if (_layout == layout) {
        return;
    }
    _layout = layout;
    self.titleLabel.text = _layout.model.title;
    if (_layout.model.dot_status) {
        self.dotView.hidden = NO;
    }else{
        _dotView.hidden = YES;
    }
}

- (void)setIsSelect:(BOOL)isSelect{
    if (isSelect) {
        _titleLabel.textColor = _layout.highlightColor;
        _titleLabel.transform = CGAffineTransformMakeScale(1, 1);
    }else{
        _titleLabel.textColor = _layout.normalColor;
        _titleLabel.transform = CGAffineTransformMakeScale(_layout.scale, _layout.scale);
    }
}

- (void)setScale:(CGFloat)scale{
    if (_scale != scale) {
        _scale = scale;
        _titleLabel.transform = CGAffineTransformMakeScale(_layout.scale*_scale, _layout.scale*_scale);
    }
}

@end

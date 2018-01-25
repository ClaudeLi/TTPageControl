//
//  TTPageControlCell.h
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTPageControlLayout;
@interface TTPageControlCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) TTPageControlLayout *layout;

@property (nonatomic, assign) BOOL isSelect;

@end

//
//  TTPageControlBar.h
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTPageControlModel;
@interface TTPageControlBar : UICollectionView

@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger defaultIndex;
@property (nonatomic, strong) NSArray <TTPageControlModel *>*modelArray;

/**
 default [UIFont systemFontOfSize:16]
 */
@property (nonatomic, strong) UIFont    *normalFont;

/**
 default 16.0f
 */
@property (nonatomic, assign) CGFloat    highlightFontSize;

/**
 default [UIColor lightGrayColor]
 */
@property (nonatomic, strong) UIColor   *normalColor;

/**
 default [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor   *highlightColor;

/**
 allow scroll to the bar's center, default YES
 */
@property (nonatomic, assign) BOOL      allowScrollToCenter;

/**
 if  lineSize.width == 0, width is equal to the title width
 default : CGSizeMake(8, 3)
 */
@property (nonatomic, strong) UIView    *lineView;
@property (nonatomic, assign) CGSize    lineSize;
@property (nonatomic, assign) BOOL      allowShowLineView;      // default YES

@property (nonatomic, assign) NSInteger scrollingPage;
@property (nonatomic, assign) CGFloat   scrollScale;            //  rang (-1, 1)

@property (nonatomic, copy) void(^didSelectedItemBlock)(NSInteger index, TTPageControlModel *model);
@property (nonatomic, copy) void(^scrollDidScroll)(UIScrollView *scrollView);

- (void)scrollToIndex:(NSInteger)index;

@end

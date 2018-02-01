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

@property (nonatomic, strong) UIFont    *normalFont;
@property (nonatomic, strong) UIFont    *highlightFont;
@property (nonatomic, strong) UIColor   *normalColor;
@property (nonatomic, strong) UIColor   *highlightColor;

@property (nonatomic, assign) BOOL      allowScrollToCenter;    // default YES

/**
 if  lineSize.width == 0, width is equal to the title width
 default : CGSizeMake(8, 3)
 */
@property (nonatomic, strong) UIView    *lineView;
@property (nonatomic, assign) CGSize    lineSize;

@property (nonatomic, assign) NSInteger scrollingPage;
@property (nonatomic, assign) CGFloat   scrollScale;            //  rang (-1, 1)

@property (nonatomic, copy) void(^didSelectedItemBlock)(NSInteger index, TTPageControlModel *model);
@property (nonatomic, copy) void(^scrollDidScroll)(UIScrollView *scrollView);

- (void)scrollToIndex:(NSInteger)index;

@end

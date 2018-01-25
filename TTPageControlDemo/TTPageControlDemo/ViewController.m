//
//  ViewController.m
//  TTPageControlDemo
//
//  Created by ClaudeLi on 2018/1/25.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "ViewController.h"
#import <TTPageControlKit/TTPageControlKit.h>
#import "UIColor+CLExt.h"

@interface ViewController ()<UIScrollViewDelegate>{
    BOOL _isDrag;
}

@property (nonatomic, strong) TTPageControlBar *pageBar;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (TTPageControlBar *)pageBar{
    if (!_pageBar) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 20.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, 120, 0, 10);
        _pageBar = [[TTPageControlBar alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 40) collectionViewLayout:layout];
        _pageBar.backgroundColor = [UIColor redColor];
        __weak __typeof(&*self)weakSelf = self;
        [_pageBar setDidSelectedItemBlock:^(NSInteger index, TTPageControlModel *model) {
            [weakSelf scrollToPage:index model:model];
        }];
        [self.view addSubview:_pageBar];
    }
    return _pageBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@"推荐", @"MV", @"收费课程", @"Hello World", @"街舞", @"绝世", @"MMP", @"神曲", @"还有谁", @"TEXT Demo"];
    NSMutableArray *titleArray = [NSMutableArray array];
    for (int i = 0; i<arr.count; i++) {
        TTPageControlModel *m = [[TTPageControlModel alloc] init];
        m.title = arr[i];
        [titleArray addObject:m];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        v.backgroundColor = [UIColor randomColor];
        [self.scrollView addSubview:v];
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width * titleArray.count, 0)];
    self.pageBar.modelArray = titleArray;
}

- (void)scrollToPage:(NSInteger)page model:(TTPageControlModel *)model{
    _isDrag = NO;
    [_scrollView setContentOffset:CGPointMake(page * self.scrollView.bounds.size.width, 0) animated:NO];
}

#pragma mark -
#pragma mark -- UIScrollViewDelegate --
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isDrag) {
        _pageBar.scrollingPage = (scrollView.contentOffset.x + (scrollView.bounds.size.width / 2.0)) / scrollView.bounds.size.width;
        _pageBar.scrollScale = (scrollView.contentOffset.x - scrollView.bounds.size.width *_pageBar.currentIndex)/scrollView.bounds.size.width;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isDrag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _isDrag = NO;
    [_pageBar scrollToIndex:_pageBar.scrollingPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

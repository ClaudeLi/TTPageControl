//
//  TTPageControlBar.m
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTPageControlBar.h"
#import "TTPageControlCell.h"
#import "TTPageControlModel.h"

static NSString *itemIdentifier = @"TTPageControlCellIdentifier";
@interface TTPageControlBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    UICollectionViewFlowLayout *_flowLayout;
    BOOL                        _isScrolled;
    CGPoint                     _lineCenter;
    NSArray                     *_normalRGBA;
    NSArray                     *_highlightRGBA;
}

@property (nonatomic, strong) NSMutableArray *layoutArray;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSArray *changedHighlight;
@property (nonatomic, strong) NSArray *changedNormal;

@end

@implementation TTPageControlBar

#pragma mark -
#pragma mark -- Initial Methods --
- (instancetype)initWithFrame:(CGRect)frame{
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:_flowLayout];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    _flowLayout = (UICollectionViewFlowLayout *)layout;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:_flowLayout];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (void)_setUp{
    self.delegate = self;
    self.dataSource = self;
    self.showsHorizontalScrollIndicator = NO;
    [self registerClass:[TTPageControlCell class] forCellWithReuseIdentifier:itemIdentifier];
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.normalFont = self.highlightFont = [UIFont systemFontOfSize:16];
    self.normalColor = [UIColor lightGrayColor];
    self.highlightColor = [UIColor blackColor];
    self.lineSize = CGSizeMake(8, 3);
    self.allowScrollToCenter = YES;
    _currentIndex = -1;
}

#pragma mark -
#pragma mark -- set --
- (void)setModelArray:(NSArray<TTPageControlModel *> *)modelArray{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_layoutArray removeAllObjects];
        for (TTPageControlModel *m in modelArray) {
            TTPageControlLayout *layout = [[TTPageControlLayout alloc] initWithModel:m
                                                                          normalFont:_normalFont highlightFont:_highlightFont normalColor:_normalColor highlightColor:_highlightColor];
            [self.layoutArray addObject:layout];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            if (_layoutArray.count > _defaultIndex) {
                [self scrollToIndex:_defaultIndex];
            }
        });
    });
}

- (void)setScrollingPage:(NSInteger)scrollingPage{
    _scrollingPage = scrollingPage;
}

- (void)setHighlightColor:(UIColor *)highlightColor{
    _highlightColor = highlightColor;
    _highlightRGBA = [self getRGBWithColor:_highlightColor];
}

- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    _normalRGBA = [self getRGBWithColor:_normalColor];
}

#pragma mark -
#pragma mark -- Lazy Loads --
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _lineSize.width, _lineSize.height)];
        _lineView.backgroundColor = [UIColor blackColor];
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (NSMutableArray *)layoutArray{
    if (!_layoutArray) {
        _layoutArray = [NSMutableArray array];
    }
    return _layoutArray;
}

- (NSArray *)changedHighlight{
    if (!_changedHighlight) {
        _changedHighlight = [self getChangedRGBAWithSource:_normalRGBA changed:_highlightRGBA];
    }
    return _changedHighlight;
}

- (NSArray *)changedNormal{
    if (!_changedNormal) {
        _changedNormal = [self getChangedRGBAWithSource:_highlightRGBA changed:_normalRGBA];
    }
    return _changedNormal;
}

#pragma mark -
#pragma mark -- UICollectionViewDataSource & UICollectionViewDelegate --
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _layoutArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TTPageControlCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    if (indexPath.row < _layoutArray.count) {
        cell.layout = _layoutArray[indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    TTPageControlCell *cell = (TTPageControlCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelect = NO;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    TTPageControlCell *item = (TTPageControlCell *)cell;
    if (indexPath.row == _currentIndex) {
        item.isSelect = YES;
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        if (!_isScrolled) {
            if (_allowScrollToCenter) {
                [self scrollToCenterWithCell:item];
            }
        }
    }else{
        item.isSelect = NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _layoutArray.count) {
        [self scrollToIndex:indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _layoutArray.count) {
        TTPageControlLayout *layout = _layoutArray[indexPath.row];
        return CGSizeMake(layout.titleWidth, self.bounds.size.height-_flowLayout.sectionInset.top - _flowLayout.sectionInset.bottom - self.contentInset.top- self.contentInset.bottom);
    }
    return CGSizeZero;
}

- (void)setScrollScale:(CGFloat)scrollScale{
    _scrollScale = scrollScale;
    if (_scrollScale >= 1.0 || _scrollScale <=-1.0) {
        CGRect f = self.lineView.frame;
        f.size = _lineSize;
        self.lineView.frame = f;
        [self scrollToIndex:_scrollingPage];
    }else if (_scrollScale > 0) {
        if (_currentIndex>=_layoutArray.count-1) {
            return;
        }
        TTPageControlCell *cell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if (!cell) {
            return;
        }
        cell.titleLabel.textColor = [self getColorWithScale:_scrollScale
                                                       base:_highlightRGBA
                                                    changed:self.changedNormal];
        TTPageControlCell *nextCell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex+1 inSection:0]];
        if (!nextCell) {
            return;
        }
        nextCell.titleLabel.textColor = [self getColorWithScale:_scrollScale
                                                           base:_normalRGBA
                                                        changed:self.changedHighlight];
        CGFloat maxWidth = nextCell.center.x - cell.center.x;
        CGFloat showWidth = _scrollScale* 2.0 * (maxWidth-_lineSize.width)+_lineSize.width;
        if (_scrollScale > 0.5) {
            showWidth = (1 -_scrollScale)* 2.0 * (maxWidth-_lineSize.width)+_lineSize.width;
        }
        CGRect f = self.lineView.frame;
        f.size = CGSizeMake(showWidth, _lineSize.height);
        self.lineView.frame = f;
        self.lineView.center = CGPointMake(cell.center.x + maxWidth*_scrollScale, _lineCenter.y);
    }else if (_scrollScale < 0){
        if (_currentIndex<=0) {
            return;
        }
        TTPageControlCell *cell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if (!cell) {
            return;
        }
        cell.titleLabel.textColor = [self getColorWithScale:-_scrollScale
                                                       base:_highlightRGBA
                                                    changed:self.changedNormal];
        TTPageControlCell *nextCell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex-1 inSection:0]];
        if (!nextCell) {
            return;
        }
        nextCell.titleLabel.textColor = [self getColorWithScale:-_scrollScale
                                                           base:_normalRGBA
                                                        changed:self.changedHighlight];
        CGFloat maxWidth = cell.center.x - nextCell.center.x;
        CGFloat showWidth = _scrollScale *-2.0 * (maxWidth-_lineSize.width)+_lineSize.width;
        if (_scrollScale < -0.5) {
            showWidth = (1 +_scrollScale)* 2.0 * (maxWidth-_lineSize.width)+_lineSize.width;
        }
        CGRect f = self.lineView.frame;
        f.size = CGSizeMake(showWidth, _lineSize.height);
        self.lineView.frame = f;
        self.lineView.center = CGPointMake(cell.center.x + maxWidth*_scrollScale, _lineCenter.y);
    }else{
        CGRect f = self.lineView.frame;
        f.size = _lineSize;
        self.lineView.frame = f;
        _lineCenter = self.lineView.center;
    }
}

- (void)scrollToIndex:(NSInteger)index{
    @autoreleasepool {
        if (_currentIndex == index) {
            NSLog(@"current Row Not Changed");
            return;
        }else{
            TTPageControlCell *lastItem = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
            if (lastItem) {
                lastItem.isSelect = NO;
            }
            _currentIndex = index;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        TTPageControlCell *item = (TTPageControlCell *)[self cellForItemAtIndexPath:indexPath];
        if (item) {
            item.isSelect = YES;
            [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        if (self.didSelectedItemBlock) {
            self.didSelectedItemBlock(index, _modelArray[index]);
        }
        if (_allowScrollToCenter) {
            if (item) {
                [self scrollToCenterWithCell:item];
            }else{
                _isScrolled = NO;
                [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
        }
    }
}

- (void)scrollToCenterWithCell:(TTPageControlCell *)cell{
    _isScrolled = YES;
    CGFloat x =  cell.frame.origin.x;
    CGFloat width = self.bounds.size.width;
    CGFloat contentWidth = self.contentSize.width;
    if (x < width/2.0) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if ((contentWidth - x - self.contentInset.right - _flowLayout.sectionInset.right) < width/2.0){
        [self setContentOffset:CGPointMake((contentWidth - width), 0) animated:YES];
    }else{
        CGFloat offset = x - width/2.0 + cell.frame.size.width/2.0;
        [self setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
    _lineCenter = CGPointMake(cell.center.x, self.bounds.size.height - self.contentInset.bottom-self.lineSize.height/2.0);
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.center = _lineCenter;
    }];
}

- (NSArray *)getRGBWithColor:(UIColor *)color{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}

- (NSArray *)getChangedRGBAWithSource:(NSArray *)source changed:(NSArray *)changed{
    return @[@([changed[0] floatValue] - [source[0] floatValue]),
             @([changed[1] floatValue] - [source[1] floatValue]),
             @([changed[2] floatValue] - [source[2] floatValue]),
             @([changed[3] floatValue] - [source[3] floatValue])];
}

- (UIColor *)getColorWithScale:(CGFloat)scale base:(NSArray *)base changed:(NSArray *)changed{
    return [UIColor colorWithRed:([base[0] floatValue]+[changed[0] floatValue]*scale)
                           green:([base[1] floatValue]+[changed[1] floatValue]*scale)
                            blue:([base[2] floatValue]+[changed[2] floatValue]*scale)
                           alpha:([base[3] floatValue]+[changed[3] floatValue]*scale)];
}

@end

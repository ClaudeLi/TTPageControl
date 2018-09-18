//
//  TTPageControlBar.m
//  TTPageControlKit
//
//  Created by ClaudeLi on 2018/1/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTPageControlBar.h"
#import "TTPageControlModel.h"

static UIColor *dotColor;
@interface TTPageControlCell : UICollectionViewCell
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) CALayer       *dotLayer;

@property (nonatomic, assign) BOOL          isSelect;
@property (nonatomic, assign) CGFloat       scale;
@property (nonatomic, strong) TTPageControlLayout *layout;

@end
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

- (CALayer *)dotLayer{
    if (!_dotLayer) {
        _dotLayer = [CALayer new];
        _dotLayer.frame = CGRectMake(self.bounds.size.width - 4, 0, 6, 6);
        _dotLayer.masksToBounds = YES;
        _dotLayer.cornerRadius = 3.0f;
        _dotLayer.backgroundColor = (dotColor?:[UIColor redColor]).CGColor;
        [self.contentView.layer addSublayer:_dotLayer];
    }
    return _dotLayer;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
    _dotLayer.frame = CGRectMake(self.bounds.size.width-4, 0, 6, 6);
}

- (void)setLayout:(TTPageControlLayout *)layout{
    if (_layout == layout) {
        return;
    }
    _layout = layout;
    self.titleLabel.text = _layout.model.title;
    if (_layout.model.dot_status) {
        self.dotLayer.hidden = NO;
    }else{
        _dotLayer.hidden = YES;
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


static NSString *itemIdentifier = @"TTPageControlCellIdentifier";
@interface TTPageControlBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    UICollectionViewFlowLayout *_flowLayout;
    BOOL                        _isScrolled;
    CGPoint                     _lineCenter;
    NSArray                     *_normalRGBA;
    NSArray                     *_highlightRGBA;
    CGFloat                     _highlightScale;
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
    self.normalFont = [UIFont systemFontOfSize:16];
    self.highlightFontSize = 16.0f;
    self.normalColor = [UIColor lightGrayColor];
    self.highlightColor = [UIColor blackColor];
    self.lineSize = CGSizeMake(12, 3);
    self.allowScrollToCenter = YES;
    _currentIndex = -1;
    _allowShowLineView = YES;
}

- (void)setHighlightFontSize:(CGFloat)highlightFontSize{
    _highlightFontSize = highlightFontSize;
    if (_normalFont) {
        _highlightScale = _highlightFontSize/_normalFont.pointSize;
    }
}

- (void)setNormalFont:(UIFont *)normalFont{
    _normalFont = normalFont;
    _highlightScale = _highlightFontSize/_normalFont.pointSize;
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

- (void)setCellDotColor:(UIColor *)cellDotColor{
    _cellDotColor = cellDotColor;
    dotColor = _cellDotColor;
}
- (void)setDotColor:(UIColor *)dotColor{
    
}

#pragma mark -
#pragma mark -- set --
- (void)setModelArray:(NSArray<TTPageControlModel *> *)modelArray{
    _modelArray = modelArray;
    _currentIndex = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_layoutArray removeAllObjects];
        for (TTPageControlModel *m in modelArray) {
            TTPageControlLayout *layout = [[TTPageControlLayout alloc] initWithModel:m
                                                                          normalFont:_normalFont
                                                                      highlightScale:_highlightScale
                                                                         normalColor:_normalColor
                                                                      highlightColor:_highlightColor];
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

#pragma mark -
#pragma mark -- Lazy Loads --
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _lineSize.width, _lineSize.height)];
        _lineView.backgroundColor = [UIColor blackColor];
        _lineView.center = CGPointZero;
        _lineView.hidden = YES;
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
            [self scrollToCenterWithCell:item];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self) {
        if (self.scrollDidScroll) {
            self.scrollDidScroll(scrollView);
        }
    }
}

- (void)setScrollScale:(CGFloat)scrollScale{
    _scrollScale = scrollScale;
    @autoreleasepool {
        if (_scrollScale >= 1.0 || _scrollScale <=-1.0) {
            CGRect f = self.lineView.frame;
            f.size = _lineSize;
            self.lineView.frame = f;
            [self scrollToIndex:_scrollingPage];
        }else if (_scrollScale > 0) {
            if (_currentIndex>=_layoutArray.count-1) {
                return;
            }
            TTPageControlCell *cell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
            if (!cell) {
                return;
            }
            TTPageControlCell *nextCell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex+1 inSection:0]];
            if (!nextCell) {
                return;
            }
            // 颜色渐变处理
            cell.titleLabel.textColor = [self getColorWithScale:_scrollScale
                                                           base:_highlightRGBA
                                                        changed:self.changedNormal];
            nextCell.titleLabel.textColor = [self getColorWithScale:_scrollScale
                                                               base:_normalRGBA
                                                            changed:self.changedHighlight];

            CGFloat scale = (_highlightScale-1)*scrollScale;
            cell.scale= _highlightScale-scale;
            nextCell.scale = 1+scale;
            
            // line 渐变处理
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
            TTPageControlCell *cell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
            if (!cell) {
                return;
            }
            TTPageControlCell *nextCell = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex-1 inSection:0]];
            if (!nextCell) {
                return;
            }
            // 颜色渐变处理
            cell.titleLabel.textColor = [self getColorWithScale:-_scrollScale
                                                           base:_highlightRGBA
                                                        changed:self.changedNormal];
            nextCell.titleLabel.textColor = [self getColorWithScale:-_scrollScale
                                                               base:_normalRGBA
                                                            changed:self.changedHighlight];
            CGFloat scale = -(_highlightScale-1)*scrollScale;
            cell.scale = _highlightScale-scale;
            nextCell.scale= 1+scale;
            
            // line 渐变处理
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
}

- (void)scrollToIndex:(NSInteger)index{
    @autoreleasepool {
        if (_currentIndex == index) {
            NSLog(@"current Row Not Changed");
            return;
        }else{
            TTPageControlCell *lastItem = (TTPageControlCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
            if (lastItem) {
                lastItem.isSelect = NO;
            }
            _currentIndex = index;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        TTPageControlCell *item = (TTPageControlCell *)[self cellForItemAtIndexPath:indexPath];
        if (item) {
            if (item.layout.model.dot_status) {
                item.dotLayer.hidden = YES;
            }
            item.isSelect = YES;
            if (indexPath.row < [self numberOfItemsInSection:0]) {
                [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
        if (self.didSelectedItemBlock) {
            self.didSelectedItemBlock(index, _modelArray[index]);
        }
        if (item) {
            [self scrollToCenterWithCell:item];
        }else{
            if (_allowScrollToCenter) {
                _isScrolled = NO;
                if (indexPath.row < [self numberOfItemsInSection:0]) {
                    [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                }
            }
        }
    }
}

- (void)scrollToCenterWithCell:(TTPageControlCell *)cell{
    @autoreleasepool {
        _isScrolled = YES;
        if (_allowScrollToCenter) {
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
        }
        _lineCenter = CGPointMake(cell.center.x, self.bounds.size.height - _flowLayout.sectionInset.bottom-self.lineSize.height/2.0);
        if (CGPointEqualToPoint(CGPointZero, self.lineView.center)) {
            if (_allowShowLineView) {
                self.lineView.hidden = NO;
                self.lineView.center = _lineCenter;
            }
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                self.lineView.center = _lineCenter;
            }];
        }
    }
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

- (void)dealloc{
    dotColor = nil;
}

@end

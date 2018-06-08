//
//  ZSBannerView.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerView.h"

#import "ZSPagerViewLayout.h"
#import "ZSPagerViewCollectionView.h"

#define InfiniteSectionMax 100 // 无限滚动中，最大的section数量
@interface ZSPagerView ()<UICollectionViewDataSource,UICollectionViewDelegate>

/// 返回用户是否已触摸内容以启动滚动。
@property (nonatomic ,assign ,readwrite) BOOL isTracking;

/// 内容视图的原点与pagerView视图的原点偏移的x位置的百分比。
@property (nonatomic ,assign ,readwrite) CGFloat scrollOffset;

/// The underlying gesture recognizer for pan gestures.
@property (nonatomic ,strong ,readwrite) UIPanGestureRecognizer *panGestureRecognizer;


//MARK: Private properties
@property (nonatomic ,weak) ZSPagerViewLayout *collectionViewLayout;
@property (nonatomic ,weak) ZSPagerViewCollectionView *collectionView;
@property (nonatomic ,weak) UIView *contentView;

@property (nonatomic ,strong, nullable) NSTimer *timer;

@property (nonatomic ,assign) NSInteger dequeingSection;
@property (nonatomic ,strong ,nullable) NSIndexPath *centermostIndexPath;
@property (nonatomic ,strong ,nullable) NSIndexPath *possibleTargetingIndexPath;

@end

@implementation ZSPagerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.collectionView.frame = self.contentView.bounds;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow != nil) {
        [self startTimer];
    }else {
        [self cancelTimer];
    }
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = true;
    UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:25];
    label.text = @"ZSPagerView";
    [self.contentView addSubview:label];
}

- (void)dealloc {
    //NSLog(@"memory leak******%@",NSStringFromClass(self.class));
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

// MARK: - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.dataSource == nil) {
        return 1;
    }
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInPagerView:)]) {
        self.numberOfItems = [self.dataSource numberOfItemsInPagerView:self];
    }
    if (self.numberOfItems <= 0) {
        return 0;
    }
    // YES：无限滚动 且item大于1个 || 只有一个项则禁止无限循环为NO
    // NO: 禁止无限滚动 item<=1个 || 只有一个项则禁止无限循环为YES
    BOOL panduan = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem);
    self.numberOfSections = panduan ? InfiniteSectionMax : 1;//(INT16_MAX/self.numberOfItems)太大了，感觉用个100-500就可以了
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.dequeingSection = indexPath.section;
    ZSPagerViewCell *cell = [self.dataSource pagerView:self cellForItemAtIndex:indexPath.item];
    return cell;
}

// MARK: - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:shouldHighlightItemAtIndex:)]) {
        return YES;
    }
    NSInteger index = indexPath.item % self.numberOfItems;
    return [self.delegate pagerView:self shouldHighlightItemAtIndex:index];
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:didHighlightItemAtIndex:)]) {
        return;
    }
    NSInteger index = indexPath.item % self.numberOfItems;
    [self.delegate pagerView:self didHighlightItemAtIndex:index];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:shouldSelectItemAtIndex:)]) {
        return YES;
    }
    NSInteger index = indexPath.item % self.numberOfItems;
    return [self.delegate pagerView:self shouldSelectItemAtIndex:index];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:didSelectItemAtIndex:)]) {
        return;
    }
    self.possibleTargetingIndexPath = indexPath;
    NSInteger index = indexPath.item % self.numberOfItems;
    [self.delegate pagerView:self didSelectItemAtIndex:index];
    self.possibleTargetingIndexPath = nil; //defer？
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:willDisplayCell:forItemAtIndex:)]) {
        return;
    }
    NSInteger index = indexPath.item % self.numberOfItems;
    [self.delegate pagerView:self willDisplayCell:(ZSPagerViewCell *)cell forItemAtIndex:index];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(pagerView:didEndDisplayingCell:forItemAtIndex:)]) {
        return;
    }
    NSInteger index = indexPath.item % self.numberOfItems;
    [self.delegate pagerView:self didEndDisplayingCell:(ZSPagerViewCell *)cell forItemAtIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfItems > 0) {
        //以防有人在使用KVO
        NSInteger currentIndex = lround((double)self.scrollOffset) % self.numberOfItems;//lround四舍五入为整数
        if (currentIndex != self.currentIndex) {
            self.currentIndex = currentIndex;
        }
    }
    if ([self.delegate respondsToSelector:@selector(pagerViewDidScroll:)]) {
        [self.delegate pagerViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillBeginDragging:)]) {
        [self.delegate pagerViewWillBeginDragging:self];
    }
    if (self.automaticSlidingInterval > 0) {
        [self cancelTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillEndDragging:targetIndex:)]) {
        //
        CGFloat contentOffset = self.scrollDirection == ScrollHorizontal ? targetContentOffset->x : targetContentOffset->y;
        CGFloat targetFloat = contentOffset / self.collectionViewLayout.itemSpacing;
        NSInteger targetItem = lround((double)targetFloat);
        NSInteger targetIndex = targetItem % self.numberOfItems;
        [self.delegate pagerViewWillEndDragging:self targetIndex:targetIndex];
    }
    if (self.automaticSlidingInterval > 0) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndDecelerating:)]) {
        [self.delegate pagerViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndScrollAnimation:)]) {
        [self.delegate pagerViewDidEndScrollAnimation:self];
    }
}

//MARK: - Public functions

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (ZSPagerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier atIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.dequeingSection];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:ZSPagerViewCell.class]) {
        return (ZSPagerViewCell *)cell;
    }else {
        //fatalError("Cell class must be subclass of FSPagerViewCell");
        return nil;
    }
}

- (void)reloadData {
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    UICollectionViewScrollPosition scrollPosition = self.scrollDirection == ScrollHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index > self.numberOfItems) {
        return;
    }
    NSIndexPath *indexPath;
    if (self.possibleTargetingIndexPath && self.possibleTargetingIndexPath.item == index) {
        indexPath = self.possibleTargetingIndexPath;
    }else {
        indexPath = self.numberOfSections > 1 ? [self nearbyIndexPathForIndex:index] : [NSIndexPath indexPathForItem:index inSection:0];
    }
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:indexPath];
    [self.collectionView setContentOffset:contentOffset animated:animated];
    self.possibleTargetingIndexPath = nil;
}

- (NSInteger)indexForCell:(ZSPagerViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        return indexPath.item;
    }else {
        return NSNotFound;
    }
}
// MARK: - Private functions

- (void)commonInit {
    _scrollDirection = ScrollHorizontal;
    _automaticSlidingInterval = 0;
    _interitemSpacing = 0;
    _itemSize = CGSizeZero;
    _isInfinite = NO;
    _alwaysBounceHorizontal = NO;
    _alwaysBounceVertical = NO;
    _currentIndex = 0;
    _numberOfItems = 0;
    _numberOfSections = 0;
    _dequeingSection = 0;
    
    
    // Content View
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    // UICollectionView
    ZSPagerViewLayout *collectionViewLayout = [[ZSPagerViewLayout alloc] init];
    ZSPagerViewCollectionView *collectionView = [[ZSPagerViewCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
}

- (void)startTimer {
    if (self.automaticSlidingInterval > 0 && self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.automaticSlidingInterval target:self selector:@selector(flipNext:) userInfo:nil repeats:YES];
        [NSRunLoop.currentRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
- (void)cancelTimer {
    if (self.timer == nil) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
}
- (void)flipNext:(NSTimer *)sender {
    if (self.superview == nil || self.window == nil || self.numberOfItems <= 0 || self.isTracking) {
        return;
    }
    
    NSIndexPath *indexPath = self.centermostIndexPath;
    NSInteger section = self.numberOfSections > 1 ? (indexPath.section+(indexPath.item+1)/self.numberOfItems) : 0;
    NSInteger item = (indexPath.item+1) % self.numberOfItems;
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
    //NSLog(@"index - %zd, %zd",indexPath.section,indexPath.item);
    [self.collectionView setContentOffset:contentOffset animated:YES];
    if (indexPath.section == InfiniteSectionMax-1) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:indexPath];
        [self.collectionView setContentOffset:contentOffset animated:NO];
    }
}

- (NSIndexPath *)nearbyIndexPathForIndex: (NSInteger)index {
    NSInteger currentIndex = self.currentIndex;
    NSInteger currentSection = self.centermostIndexPath.section;
    if (labs(currentIndex-index) <= self.numberOfItems/2) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection];
    }else if (index-currentIndex >= 0) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection-1];
    }else {
        return [NSIndexPath indexPathForItem:index inSection:currentSection+1];
    }
}

- (NSIndexPath *)centermostIndexPath {
    if (self.numberOfItems <= 0 || CGSizeEqualToSize(self.collectionView.contentSize, CGSizeZero)) {
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    NSArray *arr = self.collectionView.indexPathsForVisibleItems;
    NSArray *sortedIndexPaths = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull l, id  _Nonnull r) {
        CGRect leftFrame = [self.collectionViewLayout frameForIndexPath:l];
        CGRect rightFrame = [self.collectionViewLayout frameForIndexPath:r];
        CGFloat leftCenter;
        CGFloat rightCenter;
        CGFloat ruler;
        if (self.scrollDirection == ScrollHorizontal) {
            leftCenter = CGRectGetMidX(leftFrame);
            rightCenter = CGRectGetMidX(rightFrame);
            ruler = CGRectGetMidX(self.collectionView.bounds);
        }else {
            leftCenter = CGRectGetMidY(leftFrame);
            rightCenter = CGRectGetMidY(rightFrame);
            ruler = CGRectGetMidY(self.collectionView.bounds);
        }
        
        NSNumber *numl = [NSNumber numberWithFloat:fabs(ruler-leftCenter)];
        NSNumber *numr = [NSNumber numberWithFloat:fabs(ruler-rightCenter)];
        return [numl compare:numr];
        //return fabs(ruler-leftCenter) < fabs(ruler-rightCenter);
    }];
    NSIndexPath *indexPath = sortedIndexPaths.firstObject;
    if (indexPath) {
        return indexPath;
    }
    return [NSIndexPath indexPathForItem:0 inSection:0];
}
// MARK: - set get

- (void)setScrollDirection:(ZSPagerViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setAutomaticSlidingInterval:(CGFloat)automaticSlidingInterval {
    _automaticSlidingInterval = automaticSlidingInterval;
    [self cancelTimer];
    if (_automaticSlidingInterval > 0) {
        [self startTimer];
    }
}


- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setIsInfinite:(BOOL)isInfinite {
    _isInfinite = isInfinite;
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical {
    _alwaysBounceVertical = alwaysBounceVertical;
    self.collectionView.alwaysBounceVertical = alwaysBounceVertical;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    if (_backgroundView) {
        if (_backgroundView.superview) {
            [_backgroundView removeFromSuperview];
        }
        [self insertSubview:_backgroundView atIndex:0];
        [self setNeedsLayout];
    }
}

- (void)setTransformer:(ZSPagerViewTransformer *)transformer {
    _transformer = transformer;
    _transformer.pagerView = self;
    [self.collectionViewLayout forceInvalidate];
}
- (BOOL)isTracking {
    return self.collectionView.isTracking;
}
- (void)setRemovesInfiniteLoopForSingleItem:(BOOL)removesInfiniteLoopForSingleItem {
    _removesInfiniteLoopForSingleItem = removesInfiniteLoopForSingleItem;
    [self reloadData];
}
- (CGFloat)scrollOffset {
    CGFloat contentOffset = MAX(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    CGFloat scrollOffset = contentOffset/self.collectionViewLayout.itemSpacing;
    return fmodf(scrollOffset, self.numberOfItems);
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.collectionView.panGestureRecognizer;
}


@end

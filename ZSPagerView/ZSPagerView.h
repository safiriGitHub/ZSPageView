//
//  ZSBannerView.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//
/*
 ZSPagerView是一个优雅的屏幕幻灯片库，主要以UICollectionView实现。它非常有助于制作横幅，产品展示，欢迎/引导页面，屏幕/视图控制器滑块。
 */

#import <UIKit/UIKit.h>
#import "ZSPagerConfig.h"
#import "ZSPagerViewTransformer.h"
#import "ZSPageControl.h"
#import "ZSPagerModel.h"
#import "ZSPagerViewCell.h"

IB_DESIGNABLE
@class ZSPagerViewTransformer;
@interface ZSPagerView : UIView

// MARK: - properties readwrite
@property (nonatomic ,weak ,nullable) id <ZSPagerViewDataSource>dataSource;
@property (nonatomic ,weak ,nullable) id <ZSPagerViewDelegate>delegate;

/// The scroll direction of the pager view. Default is horizontal.
@property (nonatomic ,assign) ZSPagerViewScrollDirection scrollDirection;

/// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0. 自动滑动的时间间隔，0意味着禁用自动滑动
@property (nonatomic, assign) IBInspectable CGFloat automaticSlidingInterval;

/// The spacing to use between items in the pager view. Default is 0.项目之间的间距
@property (nonatomic, assign) IBInspectable CGFloat interitemSpacing;

/// The item size of the pager view. .zero means always fill the bounds of the pager view. Default is .zero. 项目大小。 zero表示总是填充页导航视图的边界
@property (nonatomic, assign) IBInspectable CGSize itemSize;

/// A Boolean value indicates that whether the pager view has infinite items. Default is false. 是否无限滚动，默认否
@property (nonatomic, assign) IBInspectable BOOL isInfinite;

/// A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view. 是否有反弹效果
@property (nonatomic, assign) IBInspectable BOOL alwaysBounceHorizontal;

/// A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content view. 是否有反弹效果
@property (nonatomic, assign) IBInspectable BOOL alwaysBounceVertical;

/// Remove the infinite loop if there is only one item. default is NO 只有一个项则禁止无限循环
@property (nonatomic ,assign) IBInspectable BOOL removesInfiniteLoopForSingleItem;

/// The background view of the pager view.
@property (nonatomic, strong, nullable) IBInspectable UIView *backgroundView;

/// The transformer of the pager view. 切换动画
@property (nonatomic, strong, nullable) ZSPagerViewTransformer *transformer;

// MARK: - properties readonly

/// Returns whether the user has touched the content to initiate scrolling.返回用户是否已触摸内容以启动滚动。
@property (nonatomic ,assign ,readonly) BOOL isTracking;

/// The percentage of x position at which the origin of the content view is offset from the origin of the pagerView view.
@property (nonatomic ,assign ,readonly) CGFloat scrollOffset;

/// The underlying gesture recognizer for pan gestures.
@property (nonatomic ,strong ,readonly) UIPanGestureRecognizer *panGestureRecognizer;

/// 当前页数
@property (nonatomic ,assign) NSInteger currentIndex;
@property (nonatomic ,assign) NSInteger numberOfItems;
@property (nonatomic ,assign) NSInteger numberOfSections;

//MARK: - func

// MARK: - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// MARK: - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;


- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier atIndex:(NSInteger)index;

- (void)reloadData;

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (NSInteger)indexForCell:(UICollectionViewCell *)cell;
@end

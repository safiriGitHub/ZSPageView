//
//  ZSPagerConfig.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/22.
//  Copyright © 2018年 safiri. All rights reserved.
//

#ifndef ZSPagerConfig_h
#define ZSPagerConfig_h

@class ZSPagerView;
@protocol ZSPagerViewDataSource <NSObject>

/// 请求您的数据源对象，以查看分页视图中的项目数量。
- (NSInteger)numberOfItemsInPagerView:(ZSPagerView *)pagerView;

/// 根据指定index传入相应的cell
- (UICollectionViewCell *)pagerView:(ZSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

@end

@protocol ZSPagerViewDelegate <NSObject>

@optional
/// 询问委托是否在跟踪过程中高亮显示项目
- (BOOL)pagerView:(ZSPagerView *)pagerView shouldHighlightItemAtIndex:(NSInteger)index;

/// 告诉委托在指定索引处的项被突出显示
- (BOOL)pagerView:(ZSPagerView *)pagerView didHighlightItemAtIndex:(NSInteger)index;

/// 询问委托指定索引的项目是否应该被选中
- (BOOL)pagerView:(ZSPagerView *)pagerView shouldSelectItemAtIndex:(NSInteger)index;

/// 告诉委托在指定索引处的项被选中
- (void)pagerView:(ZSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index;

/// 告诉委托，指定的单元格将被显示
- (void)pagerView:(ZSPagerView *)pagerView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;

/// 告诉委托，指定的单元格将被删除
- (void)pagerView:(ZSPagerView *)pagerView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;

/// 当即将开始滚动时，告诉委托
- (void)pagerViewWillBeginDragging:(ZSPagerView *)pagerView;

/// 当完成滚动内容时，告诉委托
- (void)pagerViewWillEndDragging:(ZSPagerView *)pagerView targetIndex:(NSInteger)index;

/// 当滚动内容视图时，告诉委托
- (void)pagerViewDidScroll:(ZSPagerView *)pagerView;

/// 在滚动动画结束时，告诉委托
- (void)pagerViewDidEndScrollAnimation:(ZSPagerView *)pagerView;

/// 在滚动运动的减速完成时，告诉委托
- (void)pagerViewDidEndDecelerating:(ZSPagerView *)pagerView;

@end


typedef NS_ENUM(NSUInteger, ZSPagerViewScrollDirection) {
    ScrollHorizontal,
    ScrollVertical
};

#endif /* ZSPagerConfig_h */

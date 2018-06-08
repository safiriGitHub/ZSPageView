//
//  ZSPagerViewCollectionView.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSPagerView;
@interface ZSPagerViewCollectionView : UICollectionView

@property (nonatomic ,strong ,nullable) ZSPagerView *pagerView;

@property (nonatomic ,assign) UIEdgeInsets contentInset;
@end

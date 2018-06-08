//
//  ZSPagerViewLayout.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSPagerConfig.h"

@interface ZSPagerViewLayout : UICollectionViewLayout

@property (nonatomic ,assign) CGSize contentSize;

@property (nonatomic ,assign) CGFloat leadingSpacing;

@property (nonatomic ,assign) CGFloat itemSpacing;

@property (nonatomic ,assign) BOOL needsReprepare;

@property (nonatomic ,assign) ZSPagerViewScrollDirection scrollDirection;

@property (nonatomic ,assign) Class layoutAttributesClass;

- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath;
- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath;
- (void)forceInvalidate;
@end

//
//  ZSPagerViewTransformer.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZSPagerConfig.h"

typedef NS_ENUM(NSUInteger, ZSPagerViewTransformerType) {
    crossFading,
    zoomOut,
    depth,
    overlap,
    linear,
    coverFlow,
    ferrisWheel,
    invertedFerrisWheel,
    cubic
};

@class ZSPagerView,ZSPagerViewLayoutAttributes;
@interface ZSPagerViewTransformer : NSObject

@property (nonatomic ,weak) ZSPagerView *pagerView;

@property (nonatomic ,assign) ZSPagerViewTransformerType type;

@property (nonatomic ,assign) CGFloat minimumScale;

@property (nonatomic ,assign) CGFloat minimumAlpha;

- (void)applyTransformToAttributes:(ZSPagerViewLayoutAttributes *)attributes;

- (instancetype)initWithType:(ZSPagerViewTransformerType)type;
@end

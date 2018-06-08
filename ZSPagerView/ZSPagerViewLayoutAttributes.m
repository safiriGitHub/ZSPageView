//
//  ZSPagerViewLayoutAttributes.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/22.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerViewLayoutAttributes.h"

@implementation ZSPagerViewLayoutAttributes

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:ZSPagerViewLayoutAttributes.class]) {
        return NO;
    }
    ZSPagerViewLayoutAttributes *obj1 = (ZSPagerViewLayoutAttributes *)object;
    BOOL isEqual = [super isEqual:object];
    isEqual = isEqual && (self.position == obj1.position);
    return isEqual;
}

- (id)copyWithZone:(NSZone *)zone {
    ZSPagerViewLayoutAttributes *copy = (ZSPagerViewLayoutAttributes *)[super copyWithZone:zone];
    copy.position = self.position;
    return copy;
}

@end

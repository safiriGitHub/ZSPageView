//
//  ZSPageControl.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/23.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPageControl : UIControl

@property (nonatomic ,weak) UIView *contentView;

@property (nonatomic ,assign) IBInspectable NSInteger numberOfPages;

@property (nonatomic ,assign) IBInspectable NSInteger currentPage;

@property (nonatomic ,assign) IBInspectable CGFloat itemSpacing;

@property (nonatomic ,assign) IBInspectable CGFloat interitemSpacing;

@property (nonatomic ,assign) IBInspectable UIEdgeInsets contentInsets;

//@property (nonatomic ,assign) IBInspectable UIControlContentHorizontalAlignment contentHorizontalAlignment;

@property (nonatomic ,assign) IBInspectable BOOL hidesForSinglePage;

- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state;
- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;
- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state;
@end

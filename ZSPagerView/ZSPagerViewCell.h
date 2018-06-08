//
//  ZSPagerViewCell.h
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPagerViewCell : UICollectionViewCell

/// 是否隐藏文字信息模块 默认NO
@property (nonatomic ,assign, getter=isHideTextLable) BOOL hideTextLable;
@property (nonatomic ,strong) UIColor *textLableBackgroundColor;
@property (nonatomic ,strong) UILabel *textLabel;

@property (nonatomic ,strong) UIImageView *imageView;

@property (nonatomic ,strong) UIView *selectedForegroundView;

@end

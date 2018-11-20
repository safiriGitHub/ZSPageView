//
//  ZSPagerModel.h
//  CheFu365
//
//  Created by safiri on 2018/5/23.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import <Foundation/Foundation.h>

/// general for banner
@interface ZSPagerModel : NSObject

/// 本地的imageName
@property (nonatomic ,copy) NSString *imageName;
/// 图片url
@property (nonatomic ,strong) NSString *imageUrlString;
/// placeHolder imageName
@property (nonatomic ,copy) NSString *placeHolderImageName;
/// 点击某页page进入的web地址
@property (nonatomic ,copy) NSString *webUrlString;
/// 是否可以访问web地址: webUrlString
@property (nonatomic ,assign) BOOL canAccessWebUrl;
/// pager介绍
@property (nonatomic, copy) NSString *introduceString;

@end

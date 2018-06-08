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

/// 优先加载本地的imageName 未使用
//@property (nonatomic ,copy) NSString *imageName;
/// 若设置了imageName，不会加载url所指图片
@property (nonatomic ,strong) NSString *imageUrlString;
/// placeHolder imageName
@property (nonatomic ,copy) NSString *placeHolderImageName;
/// 点击某页page进入的web地址
@property (nonatomic ,copy) NSString *webUrlString;
/// 是否可以访问web地址: webUrlString
@property (nonatomic ,assign) BOOL canAccessWebUrl;

@end

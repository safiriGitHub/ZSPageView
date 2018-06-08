//
//  ZSPagerModel.m
//  CheFu365
//
//  Created by safiri on 2018/5/23.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerModel.h"

@implementation ZSPagerModel

- (void)setWebUrlString:(NSString *)webUrlString {
    _webUrlString = webUrlString;
    self.canAccessWebUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:webUrlString]];
}

@end

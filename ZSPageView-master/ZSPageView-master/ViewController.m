//
//  ViewController.m
//  ZSPageView-master
//
//  Created by safiri on 2018/10/16.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ViewController.h"
#import "ZSPagerView.h"
#import "CarNewWZRemindBannerCell.h"
#import "ZSPagerViewCell.h"

@interface ViewController ()<ZSPagerViewDataSource, ZSPagerViewDelegate>

@property (nonatomic ,strong) ZSPagerView *wzRemindBannerPagerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wzRemindBannerPagerView.frame = CGRectMake(0, 100, self.view.frame.size.width, 104);
    [self.view addSubview:self.wzRemindBannerPagerView];
    
}

//MARK: ZSPagerViewDataSource, ZSPagerViewDelegate
- (NSInteger)numberOfItemsInPagerView:(ZSPagerView *)pagerView {
    return 3;
}
- (UICollectionViewCell *)pagerView:(ZSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
//    CarNewWZRemindBannerCell *cell = (CarNewWZRemindBannerCell *)[pagerView dequeueReusableCellWithReuseIdentifier:@"wzRemindBannerCell" atIndex:index];
    ZSPagerViewCell *cell = (ZSPagerViewCell *)[pagerView dequeueReusableCellWithReuseIdentifier:@"wzRemindBannerCell" atIndex:index];
    cell.textLabel.text = @"ZSPagerViewCell";
    return cell;
}
- (void)pagerView:(ZSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index {
    [pagerView scrollToItemAtIndex:index animated:YES];
    [pagerView deselectItemAtIndex:index animated:YES];
    
}

#pragma mark - getters
- (ZSPagerView *)wzRemindBannerPagerView {
    if (!_wzRemindBannerPagerView) {
        _wzRemindBannerPagerView = [[ZSPagerView alloc] init];
        _wzRemindBannerPagerView.tag = 100;
        _wzRemindBannerPagerView.dataSource = self;
        _wzRemindBannerPagerView.delegate = self;
        _wzRemindBannerPagerView.isInfinite = YES;
        _wzRemindBannerPagerView.automaticSlidingInterval = 4.5;
        _wzRemindBannerPagerView.removesInfiniteLoopForSingleItem = YES;
        [_wzRemindBannerPagerView registerClass:ZSPagerViewCell.class forCellWithReuseIdentifier:@"wzRemindBannerCell"];
        
//        [_wzRemindBannerPagerView registerNib:[UINib nibWithNibName:@"CarNewWZRemindBannerCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"wzRemindBannerCell"];
        //_bannerPagerView.transformer = [[ZSPagerViewTransformer alloc] initWithType:crossFading];
    }
    return _wzRemindBannerPagerView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

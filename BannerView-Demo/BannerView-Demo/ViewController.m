//
//  ViewController.m
//  BannerView-Demo
//
//  Created by wjl on 2018/1/24.
//  Copyright © 2018年 ycan. All rights reserved.
//

#import "ViewController.h"

// bannerView header file
#import "BannerView.h"

@interface ViewController () <BannerViewDelegate>
@property (nonatomic) NSArray *images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _images = @[
                [UIImage imageNamed:@"1.jpg"],
                [UIImage imageNamed:@"2.jpg"],
                [UIImage imageNamed:@"3.jpg"],
                [UIImage imageNamed:@"4.jpg"],
                [UIImage imageNamed:@"5.jpg"],
                ];
    
    // 初始化轮播图
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.width*0.618;
    frame.origin.y += (self.view.bounds.size.height - frame.size.height)/2;
    BannerView *banner = [[BannerView alloc] initWithFrame:frame];
    banner.delegate = self;
    banner.changePageTimeInterval = 5;
    [self.view addSubview:banner];
    
    // 更新轮播图内容
    [banner reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - BannerView delegate

-(NSUInteger)numberOfPagesInBanner:(BannerView *)banner {
    return _images.count;
}

-(UIImage*)banner:(BannerView *)banner imageForPage:(NSUInteger)page {
    // 若是通过网络请求获取图片，在此请求/缓存图片
    return _images[page];
}

-(void)banner:(BannerView *)banner didSelectPage:(NSUInteger)page {
    NSLog(@"banner select page %d", (int)page);
}

@end

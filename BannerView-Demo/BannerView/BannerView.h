//
//  BannerView.h
//  ycanReader
//
//  Created by ycan-wjl on 2018/1/6.
//  Copyright © 2018年 ycan. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BannerView;
@protocol BannerViewDelegate <NSObject>

@required
// 轮播图数量
- (NSUInteger)numberOfPagesInBanner:(BannerView*)banner;

// 轮播图
- (UIImage*)banner:(BannerView*)banner imageForPage:(NSUInteger)page;

@optional

// 轮播图被点击
- (void)banner:(BannerView*)banner didSelectPage:(NSUInteger)page;

@end


@interface BannerView : UIView

@property (weak, nonatomic) id<BannerViewDelegate> delegate;

// 页面播放间隔时间（秒）
@property (assign, nonatomic) NSUInteger changePageTimeInterval; // sec

// 更新轮播图内容
-(void)reloadData;

// 开始播放
-(void)play;

// 停止播放
-(void)stop;

@end

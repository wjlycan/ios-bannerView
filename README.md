# ios-bannerView
由于项目的需要，网上找了一些轮播图的实现，但是用在项目中总会有这样那样的bug，最后自己实现了一个，可以无限轮番播放，希望能帮助到一些人

头文件：BannerView.h

实现协议：
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

初始化：

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

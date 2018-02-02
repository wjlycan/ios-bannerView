//
//  BannerView.m
//  ycanReader
//
//  Created by ycan-wjl on 2018/1/6.
//  Copyright © 2018年 ycan. All rights reserved.
//

#import "BannerView.h"

// 5 sec
#define default_changePageTimeInerval  5

#define my_MAX_PAGE_INDEX    200
#define my_MID_PAGE_INDEX    100

@interface BannerView() <UIScrollViewDelegate>
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;

@property (weak, nonatomic) UIImageView *left;
@property (weak, nonatomic) UIImageView *middle;
@property (weak, nonatomic) UIImageView *right;
@property (assign, nonatomic) NSUInteger pageIndex;
@property (assign, nonatomic) NSUInteger scrollPageIndex;
@property (assign, nonatomic) NSUInteger oldPage;

@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger timerInterval;

@property (assign, nonatomic) BOOL canStopToPlay;
@property (assign, nonatomic) BOOL needStopToPlay;
@end


@implementation BannerView

-(void)play {
    _canStopToPlay = NO;
}

-(void)stop {
    _canStopToPlay = YES;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ){
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder] ){
        [self setup];
    }
    return self;
}


-(void)setup {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    _pageControl = pageControl;
    pageControl.numberOfPages = 0;
    pageControl.currentPage = 0;
    pageControl.hidesForSinglePage = YES;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithDisplayP3Red:1 green:0.5 blue:0 alpha:1];
    [pageControl addTarget:self action:@selector(pageDidChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:pageControl];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opTap:)];
    [self addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView addSubview:imageView];
    _left = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView addSubview:imageView];
    _middle = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView addSubview:imageView];
    _right = imageView;
    
    _pageIndex = my_MID_PAGE_INDEX;
    _scrollPageIndex = my_MID_PAGE_INDEX;
    _oldPage = my_MAX_PAGE_INDEX;
    _canStopToPlay = NO;
    
    // 隐藏image view
    [self reloadData];
    
    // 自动播放定时器
    __weak BannerView *weakSelf = self;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 
                                            repeats:YES 
                                              block:^(NSTimer * timer) 
    {
        // 播放控制
        if( _needStopToPlay || // 外部控制
           _canStopToPlay ){  // 内部遇到特殊情况时的控制
            return;
        }
        
        // 异常处理
        if( _pageControl.numberOfPages <= 1 || !_delegate){
            return;
        }
        
        // 播放
        NSLog(@"%d-%d-%d", _timerInterval, _changePageTimeInterval, _pageIndex);
        if( --_timerInterval == 0 ){
            _timerInterval = _changePageTimeInterval;
            ++_pageIndex;
            NSLog(@"--%d-%d-%d", _timerInterval, _changePageTimeInterval, _pageIndex);
            [weakSelf adjustScrollViewOffsetAnimal:YES];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    _timer = timer;
}

- (void)dealloc {
    [_timer invalidate];
}

- (void)opTap:(UIGestureRecognizer*)tap {
    _timerInterval = _changePageTimeInterval;
    if( _delegate && 
        _pageControl.numberOfPages &&
        [_delegate respondsToSelector:@selector(banner:didSelectPage:)] ){
        [_delegate banner:self didSelectPage:[self pageNumWithPageIndex:_scrollPageIndex]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect layoutFrame = self.layoutMarginsGuide.layoutFrame;
    CGRect bounds = self.bounds;
    bounds.origin.x = layoutFrame.origin.x - 8;
    bounds.size.width = layoutFrame.size.width + 16;
    _scrollView.frame = bounds;
    
    CGSize contentSize = bounds.size;
    contentSize.width *= my_MAX_PAGE_INDEX;
    _scrollView.contentSize = contentSize;
    
    CGRect frame = bounds;
    frame.origin.y += frame.size.height-37;
    frame.size.height = 37;
    _pageControl.frame = frame;
    
    [self adjustPageFramesWithPageIndex:_pageIndex];
    [self adjustScrollViewOffsetAnimal:NO];
}

- (void)adjustScrollViewOffsetAnimal:(BOOL)animal {
    CGRect bounds = _scrollView.bounds;
    bounds.origin.x = _pageIndex * bounds.size.width;
    [_scrollView setContentOffset:bounds.origin animated:animal];
}

- (void)adjustPageFramesWithPageIndex:(NSUInteger)pageIndex {
    CGRect frame = _scrollView.bounds;
    frame.origin.x = (pageIndex-1) * frame.size.width;
    _left.frame = frame;
    
    frame.origin.x += frame.size.width;
    _middle.frame = frame;
    
    frame.origin.x += frame.size.width;
    _right.frame = frame;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)pageDidChange:(UIPageControl*)sender {
    if( _pageControl.numberOfPages > 1 ){
        NSUInteger curPage = [self pageNumWithPageIndex:_pageIndex];
        NSUInteger destPage = sender.currentPage;
        _timerInterval = _changePageTimeInterval;
        if( curPage != destPage ){
            _pageIndex += destPage - curPage;
            [self adjustScrollViewOffsetAnimal:YES];
        }
    }
}

- (NSUInteger)pageNumWithPageIndex:(NSUInteger)pageIndex{
    NSUInteger pageCount = _pageControl.numberOfPages;
    switch (pageCount) {
        case 0:
            return 0;
        
        case 1:
            return 0;
            
        default:{
            if( pageIndex < my_MID_PAGE_INDEX ){
                return pageCount - 1 - (my_MID_PAGE_INDEX - pageIndex - 1)%pageCount;
            } else {
                return (pageIndex - my_MID_PAGE_INDEX)%pageCount;
            }
        }
    }
}

- (void)reloadData {
    NSUInteger pageCount;
    if( _delegate ){
        pageCount = [_delegate numberOfPagesInBanner:self];
    } else {
        pageCount = 0;
    }
    
    _oldPage = my_MAX_PAGE_INDEX;
    
    switch (pageCount) {
        case 0:{
            [[NSRunLoop mainRunLoop] performInModes:@[NSDefaultRunLoopMode] block:^{
                _scrollView.scrollEnabled = NO;
                _pageControl.numberOfPages = 0;
                _pageControl.hidden = YES;
                _pageIndex = my_MID_PAGE_INDEX;
                _scrollPageIndex = my_MID_PAGE_INDEX;
                _middle.hidden = YES;
                _right.hidden = YES;
                _left.hidden = YES;
            }];
            return;
        }
        case 1:{
             __weak BannerView *weakSelf = self;
            [[NSRunLoop mainRunLoop] performInModes:@[NSDefaultRunLoopMode] block:^{
                _scrollView.scrollEnabled = NO;
                _pageIndex = my_MID_PAGE_INDEX;
                _scrollPageIndex = my_MID_PAGE_INDEX;
                _pageControl.numberOfPages = 1;
                _pageControl.currentPage = 0;
                _pageControl.hidden = NO;
                
                [weakSelf loadPage:0];
                [weakSelf adjustPageFramesWithPageIndex:_pageIndex];
                [weakSelf adjustScrollViewOffsetAnimal:NO];
                
                _middle.hidden = NO;
                _right.hidden = YES;
                _left.hidden = YES;
            }];
            return;
        }
        
        default:{
            __weak BannerView *weakSelf = self;
            [[NSRunLoop mainRunLoop] performInModes:@[NSDefaultRunLoopMode] block:^{
                _scrollView.scrollEnabled = YES;
                _pageControl.numberOfPages = pageCount;
                _pageControl.hidden = NO;
                
                NSUInteger page = _pageControl.currentPage;
                if( page >= pageCount ){
                    page = pageCount-1;
                }
                _pageControl.currentPage = page;
                _pageIndex = my_MID_PAGE_INDEX + page;
                _scrollPageIndex = my_MID_PAGE_INDEX;
                
                [weakSelf loadPage:page];
                [weakSelf adjustPageFramesWithPageIndex:_pageIndex];
                [weakSelf adjustScrollViewOffsetAnimal:NO];
                
                _middle.hidden = NO;
                _right.hidden = NO;
                _left.hidden = NO;
            }];
            return;
        }
    }
}

- (void)loadPage:(NSUInteger)page {
    if( !_delegate ||
        _oldPage == page ){
        return;
    }
    
    NSUInteger pageCount = _pageControl.numberOfPages;
    switch (pageCount) {
        case 0:{
            return;
        }
        case 1:{
            if( _oldPage == my_MAX_PAGE_INDEX ){
                _middle.image = [_delegate banner:self imageForPage:0];
            }
            break;
        }
        case 2:{
            UIImage *image = nil;
            if(_oldPage == my_MAX_PAGE_INDEX){
                _middle.image = [_delegate banner:self imageForPage:page&1];
                image = [_delegate banner:self imageForPage:(page+1)&1];
            } else {
                image = _middle.image;
                _middle.image = _left.image;
            }
            _right.image = image;
            _left.image = image;
            break;
        }
        default:{
            NSUInteger leftPage = (page==0 ? pageCount-1 : page-1);
            NSUInteger rightPage = (page==pageCount-1 ? 0 : page+1);
            if( _oldPage == my_MAX_PAGE_INDEX ){
                _left.image = [_delegate banner:self imageForPage:leftPage];
                _middle.image = [_delegate banner:self imageForPage:page];
                _right.image = [_delegate banner:self imageForPage:rightPage];
            } else {
                NSUInteger oldLeftPage = (_oldPage==0 ? pageCount-1 : _oldPage-1);
                NSUInteger oldRightPage = (_oldPage==pageCount-1 ? 0 : _oldPage+1);
                UIImage *oldLeftImage = _left.image;
                if(leftPage == _oldPage){
                    _left.image = _middle.image;
                } else if(leftPage == oldRightPage){
                    _left.image = _right.image;
                } else {
                    _left.image = [_delegate banner:self imageForPage:leftPage];
                }
                
                UIImage *oldMidImage = _middle.image;
                if(page == oldRightPage){
                    _middle.image = _right.image;
                } else if(page == oldLeftPage){
                    _middle.image = oldLeftImage;
                } else {
                    _middle.image = [_delegate banner:self imageForPage:page];
                }
                if(rightPage == _oldPage){
                    _right.image = oldMidImage;
                } else if(rightPage == oldLeftPage){
                    _right.image = oldLeftImage;
                } else {
                    _right.image = [_delegate banner:self imageForPage:rightPage];
                }
            }
            break;
        }
    }
    _oldPage = page;
}


#pragma mark - scroll view delegate


- (void)adjustPageIndex {
    NSUInteger page = [self pageNumWithPageIndex:_pageIndex];
    _pageControl.currentPage = page;
    NSUInteger pageIndex = my_MID_PAGE_INDEX + page;
    if( _pageIndex != pageIndex ){
        _pageIndex = pageIndex;
        _scrollPageIndex = pageIndex;
        [self loadPage:page];
        [self adjustPageFramesWithPageIndex:pageIndex];
        [self adjustScrollViewOffsetAnimal:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger pageIndex = (NSUInteger)(scrollView.contentOffset.x/scrollView.frame.size.width);
    if( _needStopToPlay ){
         if(pageIndex != _pageIndex){
             _pageIndex = pageIndex;
             _scrollPageIndex = pageIndex;
             NSUInteger page = [self pageNumWithPageIndex:pageIndex];
             [self loadPage:page];
             [self adjustPageFramesWithPageIndex:pageIndex];
         }
    } else if( pageIndex != _scrollPageIndex ){
        _scrollPageIndex = pageIndex;
        NSUInteger page = [self pageNumWithPageIndex:pageIndex];
        [self loadPage:page];
        [self adjustPageFramesWithPageIndex:pageIndex];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _needStopToPlay = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if( decelerate ){
        NSUInteger page = [self pageNumWithPageIndex:_scrollPageIndex];
        _pageControl.currentPage = page;
    } else {
        _needStopToPlay = NO;
        _timerInterval = _changePageTimeInterval;
        [self adjustPageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if( _needStopToPlay ){
        _needStopToPlay = NO;
        _timerInterval = _changePageTimeInterval;
    }
    [self adjustPageIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self adjustPageIndex];
}


- (void)setChangePageTimeInterval:(NSUInteger)changePageTimeInterval {
    if( changePageTimeInterval < default_changePageTimeInerval ){
        changePageTimeInterval = default_changePageTimeInerval;
    }
    
    if( _changePageTimeInterval != changePageTimeInterval ){
        _changePageTimeInterval = changePageTimeInterval;
        _timerInterval = changePageTimeInterval;
    }
}

@end

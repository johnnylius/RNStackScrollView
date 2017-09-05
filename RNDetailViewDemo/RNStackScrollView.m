//
//  RNStackScrollView.m
//  RNStackScrollView
//
//  Created by Johnny on 2017/8/21.
//  Copyright © 2017年 Sogou. All rights reserved.
//

#import "RNStackScrollView.h"
#import <WebKit/WebKit.h>

@interface RNStackScrollView ()

@property (nonatomic, strong) NSArray<UIView *> *viewArray;
@property (nonatomic, strong) NSMutableArray *frameBeginArray;

@end

@implementation RNStackScrollView

- (instancetype)initWithViewArray:(NSArray<UIView *> *)viewArray {
    self = [super init];
    if (self) {
        _viewArray = viewArray;
        _frameBeginArray = [NSMutableArray arrayWithCapacity:viewArray.count];
        [self setupStackViewsConfig];
    }
    return self;
}

- (void)dealloc {
    [self unloadStackViewsObserver];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self adjustStackViewsFrame];
}

#pragma mark - Public Method
- (void)scrollToViewBeginWithView:(UIView *)view animated:(BOOL)animated {
    [self scrollToViewOffsetWithView:view offset:0 animated:animated];
}

- (void)scrollToViewOffsetWithView:(UIView *)view offset:(CGFloat)offset animated:(BOOL)animated {
    NSInteger index = [self.viewArray indexOfObject:view];
    if (index == NSNotFound) {
        return;
    }
    
    CGFloat position = [self.frameBeginArray[index] floatValue];
    position += offset;
    if (position < 0) {
        position = 0;
    }
    // 如果automaticallyAdjustsScrollViewInsets为YES时，处理contentInset.top
    if (position > self.contentSize.height - self.frame.size.height + self.contentInset.top) {
        position = self.contentSize.height - self.frame.size.height + self.contentInset.top;
    }
    
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = position - self.contentInset.top;
    [self setContentOffset:contentOffset animated:animated];
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    NSValue *oldObj = change[NSKeyValueChangeOldKey];
    NSValue *newObj = change[NSKeyValueChangeNewKey];
    
    CGFloat oldValue = 0, newValue = 0;
    if ([keyPath isEqualToString:@"contentOffset"]) {
        oldValue = [oldObj CGPointValue].y;
        newValue = [newObj CGPointValue].y;
    } else if ([keyPath isEqualToString:@"scrollView.contentSize"] ||
        [keyPath isEqualToString:@"contentSize"]) {
        oldValue = [oldObj CGSizeValue].height;
        newValue = [newObj CGSizeValue].height;
    } else if ([keyPath isEqualToString:@"frame"]) {
        oldValue = [oldObj CGRectValue].size.height;
        newValue = [newObj CGRectValue].size.height;
    }
    
    if (oldValue != newValue) {
        [self adjustScrollViewHeight];
        [self layoutStackViews];
    }
}

#pragma mark - Private Method
// 修改View的设置，包括添加子View，修改滚动属性和添加KVO
- (void)setupStackViewsConfig {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
    for (UIView *view in self.viewArray) {
        [self addSubview:view];
        if ([view isKindOfClass:[UIWebView class]] ||
            [view isKindOfClass:[WKWebView class]]) {
            UIWebView *webView = (UIWebView *)view;
            webView.scrollView.scrollEnabled = NO;
            [webView addObserver:self forKeyPath:@"scrollView.contentSize" options:options context:nil];
        } else if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.scrollEnabled = NO;
            [scrollView addObserver:self forKeyPath:@"contentSize" options:options context:nil];
        } else if ([view isKindOfClass:[UIView class]]) {
            [view addObserver:self forKeyPath:@"frame" options:options context:nil];
        }
    }
}

- (void)unloadStackViewsObserver {
    [self removeObserver:self forKeyPath:@"contentOffset"];
    for (UIView *view in self.viewArray) {
        if ([view isKindOfClass:[UIWebView class]] ||
            [view isKindOfClass:[WKWebView class]]) {
            [view removeObserver:self forKeyPath:@"scrollView.contentSize"];
        } else if ([view isKindOfClass:[UIScrollView class]]) {
            [view removeObserver:self forKeyPath:@"contentSize"];
        } else if ([view isKindOfClass:[UIView class]]) {
            [view removeObserver:self forKeyPath:@"frame"];
        }
    }
}

- (void)adjustStackViewsFrame {
    for (UIView *view in self.viewArray) {
        CGSize size = view.frame.size;
        size.width = self.frame.size.width;
        if (size.height < CGFLOAT_MIN) {
            // ScrollView的高度必须大于0，否则contentSize高度变化不会触发KVO
            size.height = CGFLOAT_MIN;
        }
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
    }
}

- (void)adjustScrollViewHeight {
    // 计算每个View的起点y坐标
    __block CGFloat lastFrameBegin = 0;
    [self.viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        self.frameBeginArray[idx] = @(lastFrameBegin);
        
        if ([view isKindOfClass:[UIWebView class]] ||
            [view isKindOfClass:[WKWebView class]]) {
            UIWebView *webView = (UIWebView *)view;
            lastFrameBegin = lastFrameBegin + webView.scrollView.contentSize.height + webView.scrollView.contentInset.top + webView.scrollView.contentInset.bottom;
        } else if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            lastFrameBegin = lastFrameBegin + scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
        } else if ([view isKindOfClass:[UIView class]]) {
            lastFrameBegin = lastFrameBegin + view.frame.size.height;
        }
    }];
    
    // 设置滚动范围总高度
    CGSize contentSize = self.contentSize;
    contentSize.height = lastFrameBegin;
    self.contentSize = contentSize;
}

- (void)layoutStackViews {
    [self.viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat viewFrameBegin = [self.frameBeginArray[idx] floatValue];
        CGPoint offset = self.contentOffset;
        // 滚动偏移值
        offset.y = offset.y - viewFrameBegin;
        // 修正滚动偏移最小值
        if (offset.y < 0) {
            offset.y = 0;
        }
        
        if ([view isKindOfClass:[UIWebView class]] ||
            [view isKindOfClass:[WKWebView class]]) {
            UIWebView *webView = (UIWebView *)view;
            // 修正frame高度
            CGRect frame = webView.frame;
            frame.size.height = self.frame.size.height;
            if (frame.size.height > webView.scrollView.contentSize.height) {
                frame.size.height = webView.scrollView.contentSize.height;
            }
            
            // 修正滚动偏移最大值，content高度 - frame高度 + inset上下
            CGFloat maxContentOffsetY = webView.scrollView.contentSize.height - frame.size.height + webView.scrollView.contentInset.top + webView.scrollView.contentInset.bottom;
            if (offset.y > maxContentOffsetY) {
                offset.y = maxContentOffsetY;
            }
            
            // 修正frame坐标
            frame.origin.y = viewFrameBegin + offset.y;
            
            // 修正cotent滚动偏移
            offset.y -= webView.scrollView.contentInset.top;
            
            webView.frame = frame;
            webView.scrollView.contentOffset = offset;
        } else if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            // 修正frame高度
            CGRect frame = scrollView.frame;
            frame.size.height = self.frame.size.height;
            if (frame.size.height > scrollView.contentSize.height) {
                frame.size.height = scrollView.contentSize.height;
            }
            
            // 修正滚动偏移最大值，content高度 - frame高度 + inset上下
            CGFloat maxContentOffsetY = scrollView.contentSize.height - frame.size.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
            if (offset.y > maxContentOffsetY) {
                offset.y = maxContentOffsetY;
            }
            
            // 修正frame坐标
            frame.origin.y = viewFrameBegin + offset.y;
            
            // 修正cotent滚动偏移
            offset.y -= scrollView.contentInset.top;
            
            scrollView.frame = frame;
            scrollView.contentOffset = offset;
        } else if ([view isKindOfClass:[UIView class]]) {
            
        }
    }];
}

@end

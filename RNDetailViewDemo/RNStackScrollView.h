//
//  RNStackScrollView.h
//  RNStackScrollView
//
//  Created by Johnny on 2017/8/21.
//  Copyright © 2017年 Sogou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNStackScrollView : UIScrollView

- (instancetype)initWithViewArray:(NSArray<UIView *> *)viewArray;
- (void)scrollToViewBeginWithView:(UIView *)view animated:(BOOL)animated;
- (void)scrollToViewOffsetWithView:(UIView *)view offset:(CGFloat)offsetY animated:(BOOL)animated;

@end

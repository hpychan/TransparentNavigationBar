//
//  UINavigationBar+Transparent.h
//  TransparentNavigationBarDemo
//
//  Created by Henry Chan on 2015-12-04.
//  Copyright © 2015 APPSolute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Transparent)

- (void)bt_setBackgroundColor:(UIColor *)backgroundColor;
- (void)bt_setContentAlpha:(CGFloat)alpha;
- (void)bt_setTranslationY:(CGFloat)translationY;
- (void)bt_reset;
@end

//
//  BeautyNavigationBar.h
//
//  Created by Henry Chan on 2015-12-03.
//  Copyright © 2015 APPSolute. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransparentNavigationBar;

@protocol TransparentNavigationBarDelegate <NSObject>
- (void)navigationBar:(TransparentNavigationBar * __nonnull)navigationBar buttonAlphaUpdated:(float) alpha;
@end

@interface TransparentNavigationBar : UINavigationBar

@property (strong, nonatomic, nullable) UITableView *tableView;
@property (strong, nonatomic, nullable) UIImageView *imageView;
@property (nonatomic) NSInteger reappearanceOffset;
@property (assign, nonatomic) CGFloat scrollTolerance;
@property (assign, nonatomic) BOOL viewControllerIsAboutToBePresented;
@property (nullable,nonatomic,weak) id<TransparentNavigationBarDelegate> transparentNavigationBarDelegate;

@property (nonatomic) int mode;
@property (strong, nonatomic, nonnull) UIColor*  color;

- (void) resetToDefaultPosition:(BOOL)animated;
@end
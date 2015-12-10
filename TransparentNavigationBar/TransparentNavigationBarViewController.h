//
//  BeautyNavigationBarViewController.h
//
//  Created by Henry Chan on 2015-12-03.
//  Copyright © 2015 APPSolute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransparentNavigationBar.h"

@interface TransparentNavigationBarViewController : UIViewController

@property (nonatomic, assign) BOOL enableScrollableNavigationBar;

/**
 *  Call this method to bind the navigation bar to a scrollView.
 *  Need to provide a scrollView with the frame already set.
 *
 *  @param scrollView The scrollView to bind to the navigation bar.
 */
- (void)bindNavigationBarToTableView:(UITableView *)tableView withDelegate: (id<TransparentNavigationBarDelegate>) delegate;
- (void)bindNavigationBarToTableView:(UITableView *)tableView withDelegate: (id<TransparentNavigationBarDelegate>) delegate reappearanceOffset: (NSInteger) reappearanceOffset
                     enlargeableImage: (UIImageView*) imageView;

@end

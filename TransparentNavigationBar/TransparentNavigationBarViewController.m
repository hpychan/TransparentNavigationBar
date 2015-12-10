//
//  TransparentNavigationBarViewController.m
//
//  Created by Henry Chan on 2015-12-03.
//  Copyright © 2015 APPSolute. All rights reserved.
//


#import "TransparentNavigationBarViewController.h"
#import "TransparentNavigationBar.h"
#import "UINavigationBar+Transparent.h"

#import <objc/runtime.h>
#import <objc/message.h>

static const CGFloat kStatusBarPlusNavigationBarHeight = 64.0f;

@interface TransparentNavigationBarViewController ()

@property (nonatomic, weak) UITableView *trackedTableView;

- (TransparentNavigationBar *) transparentNavigationBar;

@end

@implementation TransparentNavigationBarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _enableScrollableNavigationBar = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _enableScrollableNavigationBar = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.enableScrollableNavigationBar) {
        [self transparentNavigationBar].tableView = self.trackedTableView;
        [self repositionNavigationBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.enableScrollableNavigationBar) {
        [self repositionNavigationBar];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.enableScrollableNavigationBar) {
        [self transparentNavigationBar].tableView = self.trackedTableView;
    }
}

#pragma mark - Public Methods

- (void)bindNavigationBarToTableView:(UITableView *)tableView withDelegate: (id<TransparentNavigationBarDelegate>) delegate {
    [self bindNavigationBarToTableView: tableView withDelegate:delegate reappearanceOffset:-1 enlargeableImage:nil];
}

- (void)bindNavigationBarToTableView:(UITableView *)tableView withDelegate: (id<TransparentNavigationBarDelegate>) delegate reappearanceOffset: (NSInteger) reappearanceOffset
                     enlargeableImage: (UIImageView*) imageView
{
    if (!self.enableScrollableNavigationBar) {
        return;
    }
    
    bool needReposition = true;
    
    if (self.trackedTableView == tableView) {
        needReposition = false;
    }
    
    self.trackedTableView = tableView;
    if (self.trackedTableView) {
        TransparentNavigationBar* transparentNavigationBar = [self transparentNavigationBar];
        transparentNavigationBar.tableView = self.trackedTableView;
        transparentNavigationBar.reappearanceOffset = reappearanceOffset;
        transparentNavigationBar.imageView = imageView;
        
        [self _adjustScrollViewPosition:self.trackedTableView];
        if ( needReposition ) {
            [self repositionNavigationBar];
        }
    }
    
}

#pragma mark - Private Methods

- (TransparentNavigationBar *)transparentNavigationBar {
    TransparentNavigationBar *transparentNavigationBar = (TransparentNavigationBar *)self.navigationController.navigationBar;
    if (![transparentNavigationBar isKindOfClass:[TransparentNavigationBar class]]) {
        return nil;
    }
    return transparentNavigationBar;
}

- (void)_adjustScrollViewPosition:(UIScrollView *)scrollView {
    BOOL navBarIsTranslucent = [self.navigationController.navigationBar isTranslucent];
    
    if (!navBarIsTranslucent) {
        CGRect tableViewFrame = scrollView.frame;
        tableViewFrame.origin.y -= kStatusBarPlusNavigationBarHeight;
        tableViewFrame.size.height += kStatusBarPlusNavigationBarHeight;
        scrollView.frame = tableViewFrame;
        
        UIEdgeInsets updatedContentInset = scrollView.contentInset;
        updatedContentInset.top += kStatusBarPlusNavigationBarHeight;
        scrollView.contentInset = updatedContentInset;
        
        UIEdgeInsets updatedScrollIndicatorInsets = scrollView.scrollIndicatorInsets;
        updatedScrollIndicatorInsets.top += kStatusBarPlusNavigationBarHeight;
        scrollView.scrollIndicatorInsets = updatedScrollIndicatorInsets;
    }
    else {
        // with the translucent nav bar, when popping a view controller, the nav bar is misplaced (shrinked)
    }
}

- (void)repositionNavigationBar {
    TransparentNavigationBar *navBar = [self transparentNavigationBar];
    navBar.viewControllerIsAboutToBePresented = YES;
    [navBar resetToDefaultPosition:NO];
}

@end

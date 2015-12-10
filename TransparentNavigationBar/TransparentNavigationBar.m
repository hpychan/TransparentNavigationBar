//
//  TransparentNavigationBar.m
//
//  Created by Henry Chan on 2015-12-03.
//  Copyright © 2015 APPSolute. All rights reserved.
//

#import "TransparentNavigationBar.h"
#import "UINavigationBar+Transparent.h"

typedef enum {
    TransparentNavigationBarStateNone,
    TransparentNavigationBarStateGesture,
    TransparentNavigationBarStateFinishing,
} TransparentNavigationBarState;


#define MODE_ALPHA      (0)
#define MODE_OFFSET     (1)

@interface TransparentNavigationBar () <UIGestureRecognizerDelegate> {
    
    CGFloat _barOffset;
    
    BOOL _navigationBarHidden;
    CGRect _bgImgViewFrame;
}

@property (assign, nonatomic) BOOL scrollable;
@property (assign, nonatomic) CGFloat scrollOffset;
@property (assign, nonatomic) CGFloat scrollOffsetStart;
@property (assign, nonatomic) CGFloat scrollOffsetRelative;
@property (assign, nonatomic) CGFloat barOffset;
@property (assign, nonatomic) CGFloat barOffsetStart;
@property (assign, nonatomic) CGFloat statusBarHeight;
@property (assign, nonatomic) TransparentNavigationBarState scrollState;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@end

@implementation TransparentNavigationBar

const CGFloat DefaultScrollTolerance = 44.0f;
SEL scrollViewDidScrollOriginalSelector;
NSString *ScrollViewContentOffsetPropertyName = @"contentOffset";
NSString *NavigationBarAnimationName = @"TransparentNavigationBar";

+ (void)initialize {
    scrollViewDidScrollOriginalSelector = NSSelectorFromString(@"scrollViewDidScrollOriginal:");
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.mode = MODE_ALPHA;
    self.color = [UIColor whiteColor];
    _barOffset = -1;
    self.scrollTolerance = DefaultScrollTolerance;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handlePan:)];
    self.panGesture.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
    self.tableView = nil;
}

- (void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;
    _bgImgViewFrame = _imageView.frame;
}

- (void)setTableView:(UITableView *)scrollView {
    // old scrollView
    if (_tableView) {
        [_tableView removeGestureRecognizer:self.panGesture];
        
        [_tableView removeObserver:self forKeyPath:ScrollViewContentOffsetPropertyName];
    }
    
    _tableView = scrollView;
    
    // new scrollView
    if (_tableView) {
        [_tableView addGestureRecognizer:self.panGesture];
        
        [_tableView addObserver:self
                      forKeyPath:ScrollViewContentOffsetPropertyName
                         options:0
                         context:NULL];
    }
    
    [self resetToDefaultPosition:NO];
}

- (void)resetToDefaultPosition:(BOOL)animated {
    if ( self.mode == MODE_ALPHA ) {
        [self reset];
        [self setScrollbarPosition:(BOOL)animated];
    } else {
        [self setBarOffset:0.0f animated:animated];
    }
}

- (void) reset {
    if ( self.mode == MODE_ALPHA ) {
        
        [self setShadowImage:[UIImage new]];
        [self bt_setBackgroundColor:[self.color colorWithAlphaComponent:0.0]];
        _navigationBarHidden = YES;
    }
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ScrollViewContentOffsetPropertyName] && object == self.tableView) {
        [self scrollViewDidScroll];
    }
}

#pragma mark - Notifications

- (void)statusBarOrientationDidChange {
    [self resetToDefaultPosition:NO];
}

- (void)applicationDidBecomeActive {
    [self resetToDefaultPosition:NO];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Helpers

- (BOOL)scrollable {
    if (self.viewControllerIsAboutToBePresented) {
        return NO;
    }
    
    CGSize contentSize = self.tableView.contentSize;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    CGSize containerSize = self.tableView.bounds.size;
    
    CGFloat containerHeight = containerSize.height - contentInset.top - contentInset.bottom;
    CGFloat contentHeight = contentSize.height;
    CGFloat barHeight = self.frame.size.height;
    
    return contentHeight - self.scrollTolerance - barHeight > containerHeight;
}

- (CGFloat)scrollOffset {
    return -(self.tableView.contentOffset.y + self.tableView.contentInset.top);
}

- (CGFloat)scrollOffsetRelative {
    return self.scrollOffset - self.scrollOffsetStart;
}

- (void)setScrollbarPosition:(BOOL)animated {
    float headerOffset = 0;
    float statusBarHeight = [self statusBarHeight];
    float headerHeight = self.reappearanceOffset;
    CGFloat offsetY = self.tableView.contentOffset.y;
    
    
    UIColor * color = self.color;
    
    //    float diff = offsetYL + oldY;
    float diff = 0; // avatarW - avatarPaddingY - navigationBarHeight - statusBarHeight;
    //        NSLog(@"diff : %f", diff);
    
    if (offsetY > diff) {
        // scroll down
        
        // Reset image view size
        // Update header view
        headerOffset = 0;
        //            NSLog(@"2 header offset : %f", headerFrame.origin.y);
        //            NSLog(@"2 header height : %f", headerFrame.size.height);
        
        
        // Update navigation bar button alpha
        float alphaScale = 64.0f;
        
        CGFloat alpha;
        CGFloat btnAlpha;
        
        float delta = offsetY-(diff);
        
        if (delta < alphaScale) {
            
            //            alpha = (delta)/alphaScale;
            alpha = 0;
            
            float halfAlpha = alphaScale;
            if (delta < halfAlpha) {
                btnAlpha = 1 - delta/ halfAlpha;
            }else{
                btnAlpha =  (delta - halfAlpha) / halfAlpha;
            }
            [self bt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
        }else{
            alpha = 1.0;
            btnAlpha = 1.0;
            [self bt_reset];
        }
        //                leftBtn.alpha = btnAlpha;
        //                rightBtn.alpha = btnAlpha;
        
        [self updateButtons:btnAlpha];
        
        float navigationBarOffset = offsetY;
        
        dispatch_block_t showNormalNavigationBarBlock = ^() {
            CGRect frame = self.frame;
            frame.origin.y = statusBarHeight;
            self.frame = frame;
        };
        
        dispatch_block_t hideNormalNavigationBarBlock = ^() {
            CGRect frame = self.frame;
            frame.origin.y = - offsetY + statusBarHeight;
            self.frame = frame;
        };
        
        float headerDelta = offsetY-(diff);
        
        if ( headerDelta < headerHeight || headerHeight == -1 ) {
            if ( _navigationBarHidden == NO ) {
                _navigationBarHidden = YES;
                navigationBarOffset += 44.0;
                if ( animated ) {
                    [UIView animateWithDuration:0.5 animations:^() {
                        hideNormalNavigationBarBlock();
                    }];
                } else {
                    hideNormalNavigationBarBlock();
                }
            } else {
                _navigationBarHidden = YES;
                
                hideNormalNavigationBarBlock();
            }
            [self setShadowImage:[UIImage new]];
        } else {
            if ( _navigationBarHidden == YES ) {
                _navigationBarHidden = NO;
                CGRect frame = self.frame;
                frame.origin.y = statusBarHeight - 44.0;
                self.frame = frame;
                if ( animated ) {
                    [UIView animateWithDuration:0.5 animations:^() {
                        showNormalNavigationBarBlock();
                    }];
                } else {
                    showNormalNavigationBarBlock();
                }
            } else {
                showNormalNavigationBarBlock();
            }
        }
    }else{
        // scroll up
        dispatch_block_t block = ^() {
            CGRect frame = self.frame;
            frame.origin.y = statusBarHeight;
            self.frame = frame;
            
            [self bt_setBackgroundColor:[color colorWithAlphaComponent:0]];
        };
        block();
        
        // Enlarge header and bg image size
        
        headerOffset = offsetY;
        
        // Set navigation
        [self updateButtons:1.0];
    }
    
    [self updateBgImageViewFrame: headerOffset];
}

- (void)scrollViewDidScroll {
    if ( self.mode == MODE_OFFSET ) {
        
        if (!self.scrollable) {
            [self setBarOffset:0 animated:NO];
            self.viewControllerIsAboutToBePresented = NO;
            return;
        }
        CGFloat offset = self.scrollOffsetRelative;
        CGFloat tolerance = self.scrollTolerance;
        
        if (self.scrollOffsetRelative > 0) {
            CGFloat maxTolerance = self.barOffsetStart - self.scrollOffsetStart;
            if (tolerance > maxTolerance) {
                tolerance = maxTolerance;
            }
        }
        
        if (ABS(offset) < tolerance) {
            offset = 0.0f;
        } else {
            offset = offset + (offset < 0 ? tolerance : -tolerance);
        }
        
        CGFloat barOffset = self.barOffsetStart + offset;
        [self setBarOffset:barOffset animated:NO];
        
    } else {
        [self setScrollbarPosition: YES];
    }
    [self scrollFinishing];
    self.viewControllerIsAboutToBePresented = NO;
}

-(void) updateButtons:(float) alpha {
    if ( self.transparentNavigationBarDelegate != nil ) {
        [self.transparentNavigationBarDelegate navigationBar:self buttonAlphaUpdated:alpha];
    }
}

-(void) updateBgImageViewFrame:(float) offsetY {
    CGRect bgImageFrame = _bgImgViewFrame;
//    NSLog(@"offset y : %f", offsetY);
//    NSLog(@"original image height : %f", _bgImgViewFrame.size.height);
    CGFloat height = _bgImgViewFrame.size.height - offsetY;
    CGFloat scaleRatio = height / _bgImgViewFrame.size.height;
    
    bgImageFrame.size.height = scaleRatio * _bgImgViewFrame.size.height;
    bgImageFrame.size.width = scaleRatio * _bgImgViewFrame.size.width;
    bgImageFrame.origin.y = _bgImgViewFrame.origin.y + offsetY;
    bgImageFrame.origin.x = - (bgImageFrame.size.width - _bgImgViewFrame.size.width) /2;
    self.imageView.frame = bgImageFrame;
//    NSLog(@"new image height : %f", self.imageView.frame.size.height);
//    NSLog(@"bg Image height : %f", self.imageView.frame.size.height);
    
}

- (void)scrollFinishing {
    if (self.scrollState != TransparentNavigationBarStateFinishing) {
        return;
    }
    
    [self debounce:@selector(scrollFinishingActually) delay:0.1f];
}

- (void)scrollFinishingActually {
    self.scrollState = TransparentNavigationBarStateNone;
    
    CGFloat barOffset = self.barOffset;
    CGFloat barHeight = self.frame.size.height;
    if (
        (ABS(barOffset) < barHeight / 2.0f) ||
        (-self.scrollOffset < barHeight)
        ) {
        // show bar
        barOffset = 0;
    }
    else {
        // hide bar
        barOffset = -barHeight;
    }
    
    [self setBarOffset:barOffset animated:YES];
    
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (!self.tableView || gesture.view != self.tableView) {
        return;
    }
    
    UIGestureRecognizerState gestureState = gesture.state;
    
    switch (gestureState) {
        case UIGestureRecognizerStateBegan: {
            // Begin state
            self.scrollState = TransparentNavigationBarStateGesture;
            self.scrollOffsetStart = self.scrollOffset;
            self.barOffsetStart = self.barOffset;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // Changed state
            [self scrollViewDidScroll];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            // End state
            self.scrollState = TransparentNavigationBarStateFinishing;
            [self scrollFinishing];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)statusBarHeight {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        default:
            break;
    };
    return 0.0f;
}

- (CGFloat)barOffset {
    if ( _barOffset < 0 ) {
        _barOffset = self.frame.origin.y;
    }
    return _barOffset - self.statusBarHeight;
}

- (void)setBarOffset:(CGFloat)offset {
    [self setBarOffset:offset animated:NO];
}

- (void)setBarOffset:(CGFloat)offset animated:(BOOL)animated {
    if (offset > 0) {
        offset = 0;
    }
    NSLog(@"set Bar offset : %f", offset);
    if ( self.mode == MODE_ALPHA ) {
        return;
    }
    
    const CGFloat nearZero = 0.001f;
    
    CGFloat barHeight = self.frame.size.height;
    CGFloat statusBarHeight = self.statusBarHeight;
    
    offset = MAX(offset, -barHeight);
    
    CGFloat alpha = MIN(1.0f - ABS(offset / barHeight) + nearZero, 1.0f);
    if ( _barOffset < 0 ) {
        _barOffset = self.frame.origin.y;
    }
    CGFloat currentOffset = _barOffset; //self.frame.origin.y;
    
    CGFloat targetOffset = statusBarHeight + offset;
    
    if (ABS(currentOffset - targetOffset) < FLT_EPSILON) {
        return;
    }
    
    if (animated) {
        [UIView beginAnimations:NavigationBarAnimationName context:nil];
    }
    
    // apply alpha
    for (UIView *view in self.subviews) {
        BOOL isBackgroundView = (view == [self.subviews objectAtIndex:0]);
        BOOL isInvisible = view.hidden || view.alpha < (nearZero / 2);
        if (isBackgroundView || isInvisible) {
            continue;
        }
        view.alpha = alpha;
    }
    
    // apply offset
    _barOffset = targetOffset;
    
    // apply offset
    CGRect frame = self.frame;
    frame.origin.y = targetOffset;
    self.frame = frame;
    
    
    if (animated) {
        [UIView commitAnimations];
    }
}


- (void)debounce:(SEL)selector delay:(NSTimeInterval)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
    [self performSelector:selector withObject:nil afterDelay:delay];
}

@end
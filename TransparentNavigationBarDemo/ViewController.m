//
//  ViewController.m
//  BeautyNavigationBarDemo
//
//  Created by Henry Chan on 2015-12-03.
//  Copyright © 2015 APPSolute. All rights reserved.
//

#import "ViewController.h"

#import "TransparentNavigationBar.h"
#import "UIImage+Scale.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource, TransparentNavigationBarDelegate>

@property (strong, nonatomic) UIImageView *imageView;;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"food"];
    
    CGFloat imageHeight = img.size.height;
    CGFloat imageWidth = img.size.width;
    
    UIImageView *bgImgView = [[UIImageView alloc] init];
    CGRect bgImgViewFrame = CGRectMake(0, 0,
                                       [UIScreen mainScreen].bounds.size.width,
                                       [UIScreen mainScreen].bounds.size.width /imageWidth * imageHeight);
    bgImgView.frame = bgImgViewFrame;
    bgImgView.backgroundColor = [UIColor grayColor];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    bgImgView.image = img;
    self.imageView = bgImgView;
    self.tableView.tableHeaderView = [self obtainHeaderView:bgImgView];
}

-(UIView*) obtainHeaderView: (UIImageView*) imageView {
    float width = imageView.frame.size.width;
    float height =  imageView.frame.size.height;
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:imageView];
    
    CGRect frame = CGRectMake(0, 0,
                                  width,
                                  height);
    
//    headerView.clipsToBounds = YES;
    headerView.frame = frame;
    
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self bindNavigationBarToTableView:self.tableView withDelegate:self reappearanceOffset:self.tableView.tableHeaderView.frame.size.height enlargeableImage:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

# pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndentifier = @"TableCell";
    UITableViewCell *cell=(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIndentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"test %ld", (unsigned long) (indexPath.row + 1)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *vc = (ViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


# pragma mark - TransparentNavigationBarDelegate
- (void)navigationBar:(TransparentNavigationBar *)navigationBar buttonAlphaUpdated:(float) alpha {
    
}

@end

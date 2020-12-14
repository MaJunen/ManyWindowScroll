//
//  ViewController.m
//  ManyWindowScroll
//
//  Created by 俊文 on 2020/12/11.
//

#import "MainViewController.h"
#import <Masonry.h>
#import "SwipeCardVCView.h"
#import "TestViewController.h"
#import "TestContentView.h"
#import "GXScrollWindowView.h"

@interface MainViewController ()
@property (nonatomic,strong) SwipeCardVCView *swipeView;
@property (nonatomic,strong) GXScrollWindowView *scrollWindowView;
@property (nonatomic,strong) NSMutableArray <UIViewController *>* dataSource;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self swipeViewUI];
    [self scrollWindowUI];
}


-(void)scrollWindowUI{
    [self.view addSubview:self.scrollWindowView];
    [self.scrollWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)swipeViewUI{
    [self.view addSubview:self.swipeView];
    [self.swipeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    __weak typeof(self) weakSelf = self;
    self.swipeView.deleteBlock = ^(NSInteger deleteIndex) {
        NSLog(@"deleteIndex = %ld",(long)deleteIndex);
    };
    
    self.swipeView.scrollBlock = ^(NSInteger nextIndex, NSInteger nowIndex) {
        NSLog(@"nextIndex = %ld,nowIndex = %ld",(long)nextIndex,(long)nowIndex);
    };
    
    self.swipeView.tapblock = ^(NSInteger tapIndex) {
        NSLog(@"tapIndex = %ld",(long)tapIndex);
    };
    self.swipeView.cancelBlock = ^{
    };
}

-(SwipeCardVCView *)swipeView{
    if (!_swipeView) {
        _swipeView = [[SwipeCardVCView alloc] initWithFrame:CGRectZero viewControllers:self.dataSource displayNum:7];
    }
    return _swipeView;
}

-(GXScrollWindowView *)scrollWindowView{
    if (!_scrollWindowView) {
        _scrollWindowView = [[GXScrollWindowView alloc] initWithFrame:CGRectZero];
        _scrollWindowView.dataSource = self.dataSource;
    }
    return _scrollWindowView;
}

-(NSMutableArray<UIViewController *> *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        NSArray *vcs = @[[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]
                         ,[[TestViewController alloc] init]];
        for (int i = 0; i < vcs.count; i ++) {
            TestViewController *vc = vcs[i];
            vc.title = [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d%d%d",i,i,i,i,i,i,i,i,i,i];
            [_dataSource addObject:vc];
        }
    }
    return _dataSource;
}

@end

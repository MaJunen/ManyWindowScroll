//
//  GXScrollWindowView.m
//  VCToScroll
//
//  Created by 俊文 on 2020/12/8.
//

#import "GXScrollWindowView.h"
#import "GestureScrollView.h"
#import <Masonry.h>
#import "TestContentView.h"

#define kDeviceHeight          [UIScreen mainScreen].bounds.size.height      // 获取屏幕高度
#define kDeviceWidth           [UIScreen mainScreen].bounds.size.width       // 获取屏幕宽度
#define viewLeading kDeviceWidth*0.3/2

@interface GXScrollWindowView()<UIScrollViewDelegate>
@property (nonatomic,strong) GestureScrollView *baseScrollView;

@property (nonatomic,strong) NSMutableArray <UIView *>*contentViews;

@property (nonatomic,assign) CGPoint pointStart;

@property (nonatomic,assign) BOOL isScrolling;
@end

@implementation GXScrollWindowView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupLayout];
    }
    return self;
}

-(void)setDataSource:(NSMutableArray<UIViewController *> *)dataSource{
    _dataSource = dataSource;
    for (UIViewController *vc in dataSource) {
        [vc.view removeFromSuperview];
    }
    [self addDataSourceView];
}

-(void)setupViews{
    [self addSubview:self.baseScrollView];
}

-(void)setupLayout{
    [self.baseScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addDataSourceView];
}

-(void)addDataSourceView{
    __block UIView *beforeView ;
    
    for (int i = 0; i < self.dataSource.count; i++) {
        UIView *view = self.dataSource[i].view;
        TestContentView *windowView = [[TestContentView alloc] initWithFrame:view.frame withView:view page:i+6];
        [self.baseScrollView addSubview:windowView];
        [windowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.baseScrollView);
            make.width.mas_equalTo(windowView.frame.size.width*0.7);
            make.height.mas_equalTo(windowView.frame.size.height*0.8);
            if (i==0) {
                make.top.equalTo(self.baseScrollView.mas_top).offset(20);
            }else{
                make.top.equalTo(beforeView.mas_top).offset(kDeviceHeight/5);
            }
            if (i==self.dataSource.count-1) {
                make.bottom.equalTo(self.baseScrollView.mas_bottom).offset(kDeviceHeight/2);
            }
        }];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [windowView addGestureRecognizer:pan];

        [self.contentViews addObject:windowView];
        beforeView = windowView;
    }
}

//拖动手势
-(void)pan:(UIPanGestureRecognizer*)sender{
    CGPoint translation = [sender locationInView:sender.view];
    
    UIView *nowView = self.contentViews[ [self.contentViews indexOfObject:sender.view] ];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.pointStart = translation;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.isScrolling) {
            return;
        }
        
        CGRect f = nowView.frame;
        CGFloat xTotalMove = translation.x-self.pointStart.x+nowView.frame.origin.x;
        f.origin.x = xTotalMove;
        nowView.frame = f;
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat xTotalMove = nowView.frame.origin.x-viewLeading;
        if (fabs(xTotalMove)>160 && self.contentViews.count > 1) {
            [self removeView:sender.view xTotalMove:xTotalMove];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                CGRect f = nowView.frame;
                f.origin.x = viewLeading;
                nowView.frame = f;
            }];
        }
    }
}

//移除视图
-(void)removeView:(UIView *)view xTotalMove:(CGFloat)xTotalMove{
    NSInteger removeIndex = [self.contentViews indexOfObject:view];
    NSInteger nextIndex = removeIndex + 1 >= self.contentViews.count ? removeIndex + 1 - removeIndex : removeIndex + 1;
    NSInteger beforeIndex = removeIndex - 1 < 0 ? removeIndex - 1 + self.contentViews.count : removeIndex - 1;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect f = self.contentViews[removeIndex].frame;
        f.origin.x = xTotalMove>0?self.frame.size.width:-self.frame.size.width;
        self.contentViews[removeIndex].frame = f;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [UIView animateWithDuration:1 animations:^{
            if (removeIndex == 0) {
                [self.contentViews[nextIndex] mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.baseScrollView);
                    make.width.mas_equalTo(self.contentViews[nextIndex].frame.size.width);
                    make.height.mas_equalTo(self.contentViews[nextIndex].frame.size.height);
                    make.top.equalTo(self.baseScrollView.mas_top).offset(20);
                }];
            }else if(removeIndex == self.contentViews.count - 1){
                NSInteger bebeforeIndex = beforeIndex - 1 < 0 ? beforeIndex - 1 + self.contentViews.count : beforeIndex - 1;
                [self.contentViews[beforeIndex] mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.baseScrollView);
                    make.width.mas_equalTo(self.contentViews[beforeIndex].frame.size.width);
                    make.height.mas_equalTo(self.contentViews[beforeIndex].frame.size.height);
                    make.bottom.equalTo(self.baseScrollView.mas_bottom).offset(kDeviceHeight/2);
                    if (beforeIndex != 0) {
                        make.top.equalTo(self.contentViews[bebeforeIndex].mas_top).offset(kDeviceHeight/5);
                    }else{
                        make.top.equalTo(self.baseScrollView.mas_top).offset(20);
                    }
                }];
            }else{
                [self.contentViews[nextIndex] mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.baseScrollView);
                    make.width.mas_equalTo(self.contentViews[nextIndex].frame.size.width);
                    make.height.mas_equalTo(self.contentViews[nextIndex].frame.size.height);
                    make.top.equalTo(self.contentViews[beforeIndex].mas_top).offset(kDeviceHeight/5);
                }];
            }
            
            [self.baseScrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            [self.contentViews removeObject:view];
        }];
    }];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"x = %lf   y = %lf",scrollView.contentOffset.x,scrollView.contentOffset.y);
    //上拉循环
    if (scrollView.contentOffset.y/2>60) {
        [self cycleUpScrollView:scrollView];
    }
   
    //下拉循环
    if (scrollView.contentOffset.y < -47) {
        [self cycleDownScrollView:scrollView];
    }
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == 0 && scrollView.contentOffset.y == 0) {
        return;
    }
    self.isScrolling = YES;
    
    for (UIView *view in self.contentViews) {
        view.userInteractionEnabled = NO;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isScrolling = NO;
    for (UIView *view in self.contentViews) {
        view.userInteractionEnabled = YES;
    }
}

#pragma mark - 上下拉循环
///上拉循环
-(void)cycleUpScrollView:(UIScrollView *)scrollView{
    NSInteger count = self.contentViews.count;
    
    scrollView.contentOffset = CGPointMake(0, -47);
//        self.contentViews[0].alpha = 1.0;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.contentViews[0].alpha = 0.0;
//        }completion:^(BOOL finished) {
        
        [self.contentViews[0] removeFromSuperview];
        
        [self.contentViews[count-1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.baseScrollView);
            make.width.mas_equalTo(self.contentViews[count-1].frame.size.width);
            make.height.mas_equalTo(self.contentViews[count-1].frame.size.height);
            make.top.equalTo(self.contentViews[count-2].mas_top).offset(kDeviceHeight/5);
        }];
        [self.contentViews[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.baseScrollView);
            make.width.mas_equalTo(self.contentViews[count-1].frame.size.width);
            make.height.mas_equalTo(self.contentViews[count-1].frame.size.height);
            make.top.equalTo(self.baseScrollView.mas_top).offset(20);
        }];
        [self.baseScrollView addSubview:self.contentViews[0]];
        [self.contentViews[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.baseScrollView);
            make.width.mas_equalTo(self.contentViews[count-1].frame.size.width);
            make.height.mas_equalTo(self.contentViews[count-1].frame.size.height);
            make.top.equalTo(self.contentViews[count-1].mas_top).offset(kDeviceHeight/5);
            make.bottom.equalTo(self.baseScrollView.mas_bottom).offset(kDeviceHeight/2);
        }];

        UIView *firstView = self.contentViews[0];
        firstView.alpha = 1.0;
        [self.contentViews removeObjectAtIndex:0];
        [self.contentViews addObject:firstView];
//        }];
}

///下拉循环
-(void)cycleDownScrollView:(UIScrollView *)scrollView{
    NSInteger count = self.contentViews.count;
    
    scrollView.contentOffset = CGPointMake(0, 65);
    [self.contentViews[count-1] removeFromSuperview];
    [self.contentViews[count-2] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.baseScrollView);
        make.width.mas_equalTo(self.contentViews[count-2].frame.size.width);
        make.height.mas_equalTo(self.contentViews[count-2].frame.size.height);
        make.bottom.equalTo(self.baseScrollView.mas_bottom).offset(kDeviceHeight/2);
        make.top.equalTo(self.contentViews[count-3].mas_top).offset(kDeviceHeight/5);
    }];
    [self.baseScrollView insertSubview:self.contentViews[count-1] belowSubview:self.contentViews[0]];
    [self.contentViews[count-1] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.baseScrollView);
        make.width.mas_equalTo(self.contentViews[count-1].frame.size.width);
        make.height.mas_equalTo(self.contentViews[count-1].frame.size.height);
        make.top.equalTo(self.baseScrollView.mas_top).offset(20);
    }];
    
    self.contentViews[count-1].alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentViews[count-1].alpha = 1.0;
    }];

    [self.contentViews[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.baseScrollView);
        make.width.mas_equalTo(self.contentViews[count-1].frame.size.width);
        make.height.mas_equalTo(self.contentViews[count-1].frame.size.height);
        make.top.equalTo(self.contentViews[count-1].mas_top).offset(kDeviceHeight/5);
    }];

    UIView *lastView = self.contentViews[count-1];
    [self.contentViews removeLastObject];
    [self.contentViews insertObject:lastView atIndex:0];
}

#pragma mark - lazy loading
-(GestureScrollView *)baseScrollView{
    if (!_baseScrollView) {
        _baseScrollView = [[GestureScrollView alloc] init];
        _baseScrollView.contentSize = CGSizeMake(kDeviceWidth, kDeviceHeight);
        _baseScrollView.delegate = self;
        _baseScrollView.showsVerticalScrollIndicator = NO;
    }
    return _baseScrollView;
}

-(NSMutableArray *)contentViews{
    if (!_contentViews) {
        _contentViews = [NSMutableArray array];
    }
    return _contentViews;
}

@end

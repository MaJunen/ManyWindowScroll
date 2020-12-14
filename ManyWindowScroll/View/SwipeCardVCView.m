//
//  GXSwipeCardVCView.m
//  VCToScroll
//
//  Created by 俊文 on 2020/11/27.
//

#import "SwipeCardVCView.h"
#import <Masonry.h>
#import <WebKit/WebKit.h>

/// 屏幕尺寸相关
#define kDeviceHeight          [UIScreen mainScreen].bounds.size.height      // 获取屏幕高度
#define kDeviceWidth           [UIScreen mainScreen].bounds.size.width       // 获取屏幕宽度
#define contentViewH  kDeviceHeight * 0.7
#define contentViewW  kDeviceWidth * 0.8

//childView距离父View左右的距离
const int LEFT_RIGHT_MARGIN=20;

//当前view距离父view的顶部的值
const int Bottom_padding=20;

///滑动距离  切换
const float Swipe_Dis=30;

///底部间距
const float Bottom_edge=(Bottom_padding*5);

///最大显示view数量
const NSInteger maxDisplayNum = 5;

///最小显示view数量
const NSInteger minDisplayNum = 3;
///scroll view上的视图tag
const NSInteger GXScrollViewCustomItemViewTag = 10000000;

@interface SwipeCardVCView()<UIScrollViewDelegate>

//当前的下标
@property(nonatomic,assign)int nowIndex;
//触摸开始的坐标
@property(nonatomic,assign)CGPoint pointStart;
//自身的宽度
@property(nonatomic,assign)int w;
//自身的高度
@property(nonatomic,assign)int h;
//是否是第一次执行
@property(nonatomic,assign)BOOL isFirstLayoutSub;

//视图数组
@property(nonatomic,strong) NSMutableArray <UIView *>* views;
//第一个视图的scollview
@property(nonatomic,strong)UIScrollView *baseScrollView;
//内容视图
@property(nonatomic,strong)UIView *contentView;
//背景视图
@property(nonatomic,strong)UIButton *backgroundButton;
//显示的视图
@property(nonatomic,strong)NSMutableArray <UIView *>*displayViews;

@end

@implementation SwipeCardVCView

-(instancetype)initWithFrame:(CGRect)frame viewControllers:(NSArray <UIViewController *>*)viewControllers displayNum:(NSInteger)number{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundButton];
        [self addSubview:self.contentView];
        _viewControllers = viewControllers;
        _displayNum = number;
        self.views = [NSMutableArray array];
        [self initViewToView];
        if (number > maxDisplayNum) {
            _displayNum = maxDisplayNum;
        }


        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers{
    _viewControllers = viewControllers;
    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    [self.views removeAllObjects];
    [self initViewToView];
    [self reloadUI];
}

-(void)setDisplayNum:(NSInteger)displayNum{
    _displayNum = displayNum;
    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    [self reloadUI];
}

//
-(void)initViewToView{
    //加tag,并且转换成view
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIView *view = [self screenSnapshot:self.viewControllers[i].view];
        [self.views addObject:view];
    }
}

//拖动手势
-(void)pan:(UIPanGestureRecognizer*)sender{
    if (self.views.count == 1) {
        [self removeGestureRecognizer:sender];
    }
    CGPoint translation = [sender locationInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.pointStart = translation;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect f = self.displayViews[0].frame;
        CGFloat xTotalMove = translation.y-self.pointStart.y;
        f.origin.y = xTotalMove;
        self.displayViews[0].frame = f;
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat xTotalMove = translation.y-self.pointStart.y;
        fabs(xTotalMove) > Swipe_Dis ? (xTotalMove > 0 ? [self swipeDown] : [self swipeUp]) : [UIView animateWithDuration:0.2 animations:^{
            CGRect f = self.displayViews[0].frame;
            f.origin.y = 0;
            self.displayViews[0].frame = f;
        }];
    }
}

//滑动到下一个界面
-(void)swipeUp
{
    if (self.views.count < 2) {
        return;
    }
    
    //view总共的数量
    NSInteger totalNum = self.views.count;
    //显示视图数
    NSInteger displayNum = self.displayViews.count;
    
    CGRect f = self.displayViews[0].frame;
    f.origin.y =   -self.h-20;
    
    self.scrollBlock ? self.scrollBlock(self.nowIndex,self.nowIndex+1<totalNum?self.nowIndex+1:self.nowIndex+1-(int)totalNum):nil;
    [UIView animateWithDuration:0.3 animations:^{
        self.displayViews[0].frame = f;
        [self.displayViews[0] layoutIfNeeded];
        for (int i = 1; i < displayNum; i++) {

            self.displayViews[i].frame = CGRectMake(LEFT_RIGHT_MARGIN * (i-1), Bottom_padding * (i-1)+self.h*0.05*(i-1), self.w-LEFT_RIGHT_MARGIN * (i-1) * 2, self.h*(1-0.05*(i-1)));
            [self.displayViews[i] layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        self.nowIndex++;
        self.nowIndex = self.nowIndex<totalNum?self.nowIndex:self.nowIndex-(int)totalNum;
        
        for (int i = 0; i < displayNum - 1; i++) {
            self.displayViews[i] = self.displayViews[i+1];
        }

        UIView *lastView = self.views[self.nowIndex+displayNum-1<totalNum?(int)self.nowIndex+displayNum-1:(int)self.nowIndex+displayNum-(int)totalNum-1];
        [lastView removeFromSuperview];
        lastView.layer.anchorPoint = CGPointMake(1, 1);
        lastView.frame = CGRectMake(LEFT_RIGHT_MARGIN*(displayNum - 1), Bottom_padding*(displayNum - 1)+self.h*0.05*(displayNum - 1), self.w-LEFT_RIGHT_MARGIN*(displayNum - 1)*2, self.h*(1-0.05*(displayNum - 1)));
        self.displayViews[displayNum-1] = lastView;
        [self.contentView insertSubview:lastView belowSubview:self.displayViews[displayNum-2]];

        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.displayViews[displayNum-1].frame;
            frame.origin.y = Bottom_padding*(displayNum-1)+self.h*0.05*(displayNum - 1);
            self.displayViews[displayNum-1].frame = frame;
        }];

        [self removeSubviewFromScrollView];
        self.baseScrollView.frame = CGRectMake(0, 0, self.w, self.h);
        [self.baseScrollView addSubview:self.displayViews[0]];
    }];
    
}

//滑动到上一个界面
-(void)swipeDown
{
    if (self.views.count < 2) {
        return;
    }
    
    //view总共的数量
    NSInteger totalNum = self.views.count;
    //显示视图数
    NSInteger displayNum = self.displayViews.count;
    
    CGRect f = self.displayViews[0].frame;
    f.origin.y =  -self.h-Bottom_edge-20;

    self.scrollBlock ? self.scrollBlock(self.nowIndex,self.nowIndex-1<0?self.nowIndex-1+(int)totalNum:self.nowIndex-1):nil;
    self.displayViews[0].frame = CGRectMake(LEFT_RIGHT_MARGIN, Bottom_padding, self.w-LEFT_RIGHT_MARGIN * 2, self.h);;
    [self.displayViews[0] layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 1; i < displayNum; i++) {
            self.displayViews[i].frame = CGRectMake(LEFT_RIGHT_MARGIN * (i+1), Bottom_padding * (i+1)+self.h*0.05*(i+1), self.w-LEFT_RIGHT_MARGIN * (i+1) * 2, self.h*(1-0.05*(i+1)));
            [self.displayViews[i] layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        self.nowIndex--;
        self.nowIndex = self.nowIndex<0?self.nowIndex+(int)totalNum:self.nowIndex;
        
        for (int i = (int)displayNum-1; i > 0; i--) {
            self.displayViews[i] = self.displayViews[i-1];
        }
        
        UIView *lastView = self.views[self.nowIndex+displayNum<totalNum?(int)self.nowIndex+displayNum:(int)self.nowIndex+displayNum-(int)totalNum];
        [lastView removeFromSuperview];
        
        UIView *firstView = self.views[self.nowIndex];
        [firstView removeFromSuperview];
        firstView.layer.anchorPoint = CGPointMake(1, 1);
        firstView.frame = CGRectMake(0, 0, self.w, self.h);
        self.displayViews[0] = firstView;
        
        [self.contentView insertSubview:self.displayViews[1] belowSubview:self.baseScrollView];
        
        
        self.displayViews[0].frame = CGRectMake(0, -self.h, self.w, self.h);
        [UIView animateWithDuration:0.2 animations:^{
            self.displayViews[0].frame = CGRectMake(0, 0, self.w, self.h);;
        }];
        
        [self removeSubviewFromScrollView];
        self.baseScrollView.frame = CGRectMake(0, 0, self.w, self.h);
        [self.baseScrollView addSubview:self.displayViews[0]];
    }];
    
}


//移除第一个界面
-(void)removeFirstView:(BOOL)isRight
{
    //view总共的数量
    NSInteger totalNum = self.views.count;
    //显示视图数
    NSInteger displayNum = self.displayViews.count;
    
    //只剩1个
    if (totalNum == 1) {
        return;
    }
    
    self.deleteBlock? self.deleteBlock(self.nowIndex):nil;
    [UIView animateWithDuration:0.3 animations:^{
        self.displayViews[0].frame = CGRectMake(isRight?-self.w:self.w, 0, self.w, self.h);
        [self.displayViews[0] layoutIfNeeded];
        for (int i = 1; i < displayNum; i++) {

            self.displayViews[i].frame = CGRectMake(LEFT_RIGHT_MARGIN * (i-1), Bottom_padding * (i-1)+self.h*0.05*(i-1), self.w-LEFT_RIGHT_MARGIN * (i-1) * 2, self.h*(1-0.05*(i-1)));
            [self.displayViews[i] layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        self.displayViews[0].frame = CGRectMake(0, 0, self.w, self.h);
        
        self.nowIndex++;
//        self.nowIndex = self.nowIndex<totalNum?self.nowIndex:0;
        self.nowIndex = self.nowIndex<totalNum?self.nowIndex:self.nowIndex-(int)totalNum;
        
        if (totalNum < 1) {
            return;
        }
        
        
        UIView *removeView = self.displayViews[0];
        for (int i = 0; i < displayNum - 1; i++) {
            self.displayViews[i] = self.displayViews[i+1];
        }
        
        if (totalNum != displayNum) {
            UIView *lastView = self.views[self.nowIndex+displayNum-1<totalNum?(int)self.nowIndex+displayNum-1:(int)self.nowIndex+displayNum-(int)totalNum-1];
            [lastView removeFromSuperview];
            lastView.layer.anchorPoint = CGPointMake(1, 1);

            lastView.frame = CGRectMake(LEFT_RIGHT_MARGIN*(displayNum - 1), Bottom_padding*(displayNum - 1)+self.h*0.05*(displayNum - 1), self.w-LEFT_RIGHT_MARGIN*(displayNum - 1)*2, self.h*(1-0.05*(displayNum - 1)));
            self.displayViews[displayNum-1] = lastView;
            [self.contentView insertSubview:lastView belowSubview:self.displayViews[displayNum-2]];
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.displayViews[displayNum-1].frame;
                frame.origin.y = Bottom_padding*(displayNum-1)+self.h*0.05*(displayNum - 1);
                self.displayViews[displayNum-1].frame = frame;
            }];
        }
        
        [self removeSubviewFromScrollView];
        [self.baseScrollView addSubview:self.displayViews[0]];
        
        [removeView removeFromSuperview];
        if (totalNum == displayNum) {
            [self.displayViews removeObjectAtIndex:displayNum-1];
        }

        [self.views removeObject:removeView];
        self.nowIndex = self.nowIndex-1<0?(int)totalNum-1:self.nowIndex-1;
    }];
    
}

//移除scrollview上的子view
-(void)removeSubviewFromScrollView{
    for (UIView *subview in self.baseScrollView.subviews) {
        if (subview.tag == GXScrollViewCustomItemViewTag) {
            [subview removeFromSuperview];
        }
    }
}

//点击事件
-(void)tapGestureAction:(UITapGestureRecognizer *)tap{
    self.tapblock ? self.tapblock(self.nowIndex) : nil;
}

-(void)cancelAction{
    self.cancelBlock?self.cancelBlock():nil;
}

#pragma mark - 截屏
- (UIView *)screenSnapshot:(UIView *)view{
    // 返回截图
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height*0.7/0.8), NO, 0);
    BOOL isWebView = NO;
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[WKWebView class]]) {
            isWebView = YES;
        }
    }
    if (isWebView) {
        for (UIView *subView in view.subviews) {
            [subView drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        }
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.contentMode = UIViewContentModeScaleToFill;
    return (UIView *)snapshot;
}


//布局subview的方法
-(void)layoutSubviews{
    if(!self.isFirstLayoutSub){
        self.isFirstLayoutSub=YES;
        self.w = contentViewW;
        self.h = contentViewH-Bottom_edge-self.displayNum;
        [self reloadUI];
    }
}

//重新加载数据方法，会再首次执行layoutSubviews的时候调用
-(void)reloadUI{
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < self.displayNum; i++) {
        [self.displayViews removeAllObjects];
    }

    for (int i = 0;i < self.displayNum; i++) {
        UIView *displayView = self.views[self.nowIndex+i];
        [self.displayViews addObject:displayView];
    }
    
    for (long i = self.displayNum - 1; i >= 0; i--) {
        if (i == 0) {
            [self.contentView addSubview:self.baseScrollView];
        }
        [self.displayViews[i] removeFromSuperview];
        self.displayViews[i].layer.anchorPoint = CGPointMake(1, 1);
        if (i == 0) {
            self.displayViews[i].frame = CGRectMake(0, 0, self.w, self.h);
            [self.baseScrollView addSubview:self.displayViews[i]];
        }else{
            self.displayViews[i].frame = CGRectMake(LEFT_RIGHT_MARGIN*i, Bottom_padding*i+self.h*0.05*i, self.w-i *2*LEFT_RIGHT_MARGIN, self.h*(1-0.05*i));
            [self.contentView addSubview:self.displayViews[i]];
        }
        
    }
    
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (fabs(scrollView.contentOffset.x) > 50) {
        if (self.views.count == 1) {
            self.cancelBlock?self.cancelBlock():nil;
        }
        if (self.views.count < 1) {
            return;
        }
        [self removeFirstView:scrollView.contentOffset.x > 0];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - lazy loading
-(UIScrollView *)baseScrollView{
    if (!_baseScrollView) {
        _baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.w, self.h)];
        _baseScrollView.contentSize = CGSizeMake(self.w+1, 0);
        _baseScrollView.showsHorizontalScrollIndicator = NO;
        _baseScrollView.delegate = self;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [_baseScrollView addGestureRecognizer:tap];
    }
    return _baseScrollView;
}

-(NSMutableArray<UIView *> *)displayViews{
    if (!_displayViews) {
        _displayViews = [NSMutableArray array];
    }
    return _displayViews;
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth/2-contentViewW/2, kDeviceHeight/2-contentViewH/2+64, contentViewW, contentViewH)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

-(UIButton *)backgroundButton{
    if (!_backgroundButton) {
        _backgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
        _backgroundButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_backgroundButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundButton;
}



@end




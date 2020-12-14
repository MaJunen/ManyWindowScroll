//
//  GestureScrollView.m
//  VCToScroll
//
//  Created by 俊文 on 2020/12/5.
//

#import "GestureScrollView.h"

@interface GestureScrollView()
@property(nonatomic,assign)BOOL isMoveRight;
@end

@implementation GestureScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.isMoveRight = YES;
    }
    return self;
}

//1返回值是返回是否生效。此方法在gesture recognizer视图转出UIGestureRecognizerStatePossible状态时调用，如果返回NO,则转换到UIGestureRecognizerStateFailed;如果返回YES,则继续识别触摸序列
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{

    //滑动速度
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
    
//    NSLog(@"velocity.x:%f----location.y:%f",velocity.x,velocity.y);
    
    //x方向速度>y方向就是左右滑动
    if (fabs(velocity.x) > fabs(velocity.y)) {

        self.isMoveRight = YES;

    }else{
        
        self.isMoveRight = NO;
    }
    
    return YES;

}

//2
//此方法返回YES时，手势事件会一直往下传递(允许多手势触发)，不论当前层次是否对该事件进行响应。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    
    //根据contentOffset.x 与 滑动方向 来判断手势是否向下传递
    if (self.contentOffset.x == 0 && !self.isMoveRight) {
        
        return YES;
    }
    
    return NO;
   
}

@end

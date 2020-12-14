//
//  TestContentView.m
//  VCToScroll
//
//  Created by 俊文 on 2020/11/26.
//

#import "TestContentView.h"
#import <Masonry.h>

@interface TestContentView()
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UIView *originView;
@end

@implementation TestContentView

-(instancetype)initWithFrame:(CGRect)frame withView:(UIView *)view page:(NSInteger)page{
    if (self = [super initWithFrame:frame]) {
        self.contentInset = UIEdgeInsetsMake(50.0f, 50.0f, 0.0f, 0.0f);
        self.originView = view;
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        CATransform3D turnTrans = [self cellToCATransform3D:page offset:CGPointZero];
        view.layer.transform = turnTrans;
        
        self.contentView = view;
        self.page = page;
    }
    return self;
}

-(void)resetTransform3D:(NSInteger)numberOfPages{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / 900.0f;
    
    CGFloat angle = 30.0f + MIN(numberOfPages * 5.0f, 30.0f);
    if(0 < -self.contentInset.top) {
        angle += (ABS(0) - self.contentInset.top) / 9.0f;
    }
    
    transform = CATransform3DRotate(transform, -(angle * M_PI / 180.0f), 1.0f, 0.0f, 0.0f);
    transform = CATransform3DScale(transform, 1/0.9f, 1/0.9f, 1.0f);
}

-(CATransform3D)cellToCATransform3D:(NSInteger)numberOfPages offset:(CGPoint)contentOffset{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / 900.0f;
    
    CGFloat angle = 30.0f + MIN(numberOfPages * 5.0f, 30.0f);
    if(contentOffset.y < -self.contentInset.top) {
        angle += (ABS(contentOffset.y) - self.contentInset.top) / 9.0f;
    }
    
    transform = CATransform3DRotate(transform, (angle * M_PI / 180.0f), 1.0f, 0.0f, 0.0f);
    transform = CATransform3DScale(transform, 0.9f, 0.9f, 1.0f);
    
    return transform;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self pointInside:point withEvent:event]) {
        CGPoint newp = [self.contentView.layer convertPoint:point fromLayer:self.layer];
        BOOL b = [self.contentView.layer containsPoint:newp];
//        NSLog(@"%d ---- %ld",b,self.page-6);
        if (!b) {
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}



@end

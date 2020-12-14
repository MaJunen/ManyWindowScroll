//
//  GXSwipeCardVCView.h
//  VCToScroll
//
//  Created by 俊文 on 2020/11/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SwipeCardVCViewTapBlock)(NSInteger tapIndex);
typedef void(^SwipeCardVCViewCancelBlock)(void);
typedef void(^SwipeCardVCViewDeleteBlock)(NSInteger deleteIndex);
typedef void(^SwipeCardVCViewScrollBlock)(NSInteger nextIndex,NSInteger nowIndex);

@interface SwipeCardVCView : UIView

@property (nonatomic, copy) SwipeCardVCViewTapBlock tapblock;
@property (nonatomic, copy) SwipeCardVCViewCancelBlock cancelBlock;
@property (nonatomic, copy) SwipeCardVCViewDeleteBlock deleteBlock;
@property (nonatomic, copy) SwipeCardVCViewScrollBlock scrollBlock;


//显示视图数量
@property(nonatomic,assign)NSInteger displayNum;
//视图数组
@property(nonatomic,strong) NSArray <UIViewController *>* viewControllers;

-(instancetype)initWithFrame:(CGRect)frame viewControllers:(NSArray <UIViewController *>*)viewControllers displayNum:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END

//
//  TestContentView.h
//  VCToScroll
//
//  Created by 俊文 on 2020/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestContentView : UIView
-(instancetype)initWithFrame:(CGRect)frame withView:(UIView *)view page:(NSInteger)page;
-(void)resetTransform3D:(NSInteger)numberOfPages;
@end

NS_ASSUME_NONNULL_END

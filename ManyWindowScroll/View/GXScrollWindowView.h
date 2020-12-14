//
//  GXScrollWindowView.h
//  VCToScroll
//
//  Created by 俊文 on 2020/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GXScrollWindowView : UIView
@property (nonatomic,strong) NSArray <UIViewController *>* dataSource;
@end

NS_ASSUME_NONNULL_END

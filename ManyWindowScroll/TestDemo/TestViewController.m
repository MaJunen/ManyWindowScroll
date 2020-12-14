//
//  TestViewController.m
//  VCToScroll
//
//  Created by 俊文 on 2020/11/26.
//

#import "TestViewController.h"
#import <Masonry.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int r = arc4random()%255;
    int g = arc4random()%255;
    int b = arc4random()%255;
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.image = [UIImage imageNamed:@"feathers"];
//    imageV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.text = self.title;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-60);
        make.top.equalTo(self.view.mas_top).offset(50);
    }];

    UILabel *label2 = [[UILabel alloc] init];
    label2.textColor = [UIColor whiteColor];
    label2.text = @"qwqqwqwqqwqwqw";
    [self.view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-60);
        make.top.equalTo(label.mas_bottom).offset(50);
    }];
}

@end

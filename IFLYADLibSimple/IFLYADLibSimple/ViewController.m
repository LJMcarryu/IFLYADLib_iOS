//
//  ViewController.m
//  IFLYADLibSimple
//
//  Created by admin on 3.3.25.
//

#import "IFLYNativeViewController.h"
#import "IFLYSplashViewController.h"
#import "IFLYVideoViewController.h"
#import "ViewController.h"

#import "IFLYADUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self initADTypeListView];
}

- (void)initADTypeListView {
    UIButton *splashButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 200, self.view.frame.size.width - 80, 50) title:@"开屏广告" target:self action:@selector(splashADTypeClick:)];

    [self.view addSubview:splashButton];

    UIButton *nativeButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 300, self.view.frame.size.width - 80, 50) title:@"图片广告" target:self action:@selector(nativeADTypeClick:)];

    [self.view addSubview:nativeButton];

    UIButton *videoButton = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(40, 400, self.view.frame.size.width - 80, 50) title:@"视频广告" target:self action:@selector(videoADTypeClick:)];

    [self.view addSubview:videoButton];
}

- (void)splashADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYSplashViewController.alloc.init animated:YES];
}

- (void)nativeADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYNativeViewController.alloc.init animated:YES];
}

- (void)videoADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYVideoViewController.alloc.init animated:YES];
}

@end

//
//  AppDelegate.m
//  IFLYADLibSimple
//
//  Created by admin on 3.3.25.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import <IFLYADLib/IFLYADLib.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *rootViewController = [[ViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    /// 设置是否开启个性化推荐
    [IFLYAdConfig setPersonalizedEnabled:YES];

    return YES;
}

@end

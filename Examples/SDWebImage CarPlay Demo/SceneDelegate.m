/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SceneDelegate.h"
#import "MainViewController.h"

#import <SDWebImage/SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    //Add a custom read-only cache path
    NSString *bundledPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CustomPathImages"];
    [SDImageCache sharedImageCache].additionalCachePathBlock = ^NSString * _Nullable(NSString * _Nonnull key) {
        NSString *fileName = [[SDImageCache sharedImageCache] cachePathForKey:key].lastPathComponent;
        return [bundledPath stringByAppendingPathComponent:fileName.stringByDeletingPathExtension];
    };

    if (@available(iOS 14, tvOS 14, macOS 11, watchOS 7, *)) {
        // iOS 14 supports WebP built-in
        [[SDImageCodersManager sharedManager] addCoder:[SDImageAWebPCoder sharedCoder]];
    } else {
        // iOS 13 does not supports WebP, use third-party codec
        [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
    }
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // For HEIC animated image. Animated image is new introduced in iOS 13, but it contains performance issue for now.
        [[SDImageCodersManager sharedManager] addCoder:[SDImageHEICCoder sharedCoder]];
    }

    UIWindowScene *windowScene = (UIWindowScene*)scene;
    if (![session.configuration.name isEqualToString: @"Default Configuration"]) {
        return;
    }

    self.window = [[UIWindow alloc] initWithFrame: windowScene.coordinateSpace.bounds];
    // Override point for customization after application launch.

    MainViewController *masterViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    self.window.windowScene = windowScene;
    [self.window makeKeyAndVisible];
}

@end

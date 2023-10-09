/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MainViewController.h"
#import <SDWebImage/SDWebImage.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"SDWebImage";
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Clear Cache"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(flushCache)];
    }
    return self;
}

- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearWithCacheType:SDImageCacheTypeAll completion:nil];
}

@end

/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CarPlayApplicationSceneDelegate.h"
#import "TemplateManager.h"

@interface CarPlayApplicationSceneDelegate ()

@property (strong, nonatomic) TemplateManager  *templateManager;

@end

@implementation CarPlayApplicationSceneDelegate

- (void) templateApplicationScene:(CPTemplateApplicationScene *)templateApplicationScene didConnectInterfaceController:(CPInterfaceController *)interfaceController {
    _templateManager = [[TemplateManager alloc] init];
    [_templateManager connectInterfaceController: interfaceController];
}

- (void) templateApplicationScene:(CPTemplateApplicationScene *)templateApplicationScene didDisconnectInterfaceController:(CPInterfaceController *)interfaceController {
}

@end

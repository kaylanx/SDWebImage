/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "TemplateManager.h"
#import <SDWebImage/SDWebImage.h>

@interface TemplateManager ()

@property (strong, nonatomic) CPInterfaceController  *interfaceController;

@end

@implementation TemplateManager

- (void) connectInterfaceController: (CPInterfaceController*) interfaceController {
    self.interfaceController = interfaceController;


    // HTTP NTLM auth example
    // Add your NTLM image url to the array below and replace the credentials
    [SDWebImageDownloader sharedDownloader].config.username = @"httpwatch";
    [SDWebImageDownloader sharedDownloader].config.password = @"httpwatch01";
    [[SDWebImageDownloader sharedDownloader] setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    [SDWebImageDownloader sharedDownloader].config.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;

    [self setRootTemplate];
}

- (void) setRootTemplate {

    NSMutableArray *listItems = [NSMutableArray arrayWithObject:[self clearCacheListItem]];
    [listItems addObjectsFromArray: [self listItemsWithImages]];

    CPListSection* listSection = [[CPListSection alloc] initWithItems: listItems];

    CPListTemplate* listTemplate = [[CPListTemplate alloc] initWithTitle:@"SDWebImage" sections: @[listSection]];

    [self.interfaceController setRootTemplate: listTemplate animated: YES completion: nil];
}

- (NSArray<CPListItem*> *) listItemsWithImages {
    NSMutableArray *listItems = [[NSMutableArray alloc] init];
    NSArray * imageUrlStrings = [self imageUrls];
    for (NSUInteger i=0; i<imageUrlStrings.count; i++) {
        NSString *text = [NSString stringWithFormat:@"Image #%ld", (long)i+1];
        CPListItem *listItem = [[CPListItem alloc] initWithText:text detailText: nil];
        [listItem setHandler:^(id <CPSelectableListItem> item,
                               dispatch_block_t completionBlock) {
            completionBlock();
        }];

        NSURL *imageUrl = [NSURL URLWithString:imageUrlStrings[i]];
        static UIImage *placeholderImage = nil;
        if (!placeholderImage) {
            placeholderImage = [UIImage imageNamed:@"placeholder"];
        }
        [listItem sd_setImageWithURL:imageUrl placeholderImage: placeholderImage];

        [listItems addObject:listItem];
    }
    return listItems;
}

- (CPListItem *) clearCacheListItem {
    CPListItem *listItem = [[CPListItem alloc] initWithText:@"Clear cache" detailText: nil];
    [listItem setHandler:^(id <CPSelectableListItem> item,
                           dispatch_block_t completionBlock) {
        [SDWebImageManager.sharedManager.imageCache clearWithCacheType:SDImageCacheTypeAll completion:nil];
        [self setRootTemplate];
        completionBlock();
    }];
    return listItem;
}

- (NSArray *) imageUrls {

    NSMutableArray *urlStrings = [NSMutableArray arrayWithObjects:
                 @"http://www.httpwatch.com/httpgallery/authentication/authenticatedimage/default.aspx?0.35786508303135633",     // requires HTTP auth, used to demo the NTLM auth
                 @"http://assets.sbnation.com/assets/2512203/dogflops.gif",
                 @"https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif",
                 @"http://apng.onevcat.com/assets/elephant.png",
                 @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
                 @"http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
                 @"http://littlesvr.ca/apng/images/SteamEngine.webp",
                 @"http://littlesvr.ca/apng/images/world-cup-2014-42.webp",
                 @"https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp",
                 @"https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
                 @"https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic",
                 @"https://s2.ax1x.com/2019/11/01/KHYIgJ.gif",
                 @"https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/stack_of_photos.pdf",
                 @"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
                 @"https://res.cloudinary.com/dwpjzbyux/raw/upload/v1666474070/RawDemo/raw_vebed5.NEF",
                 @"https://via.placeholder.com/200x200.jpg",
                 nil];

    for (int i=1; i<25; i++) {
        // From http://r0k.us/graphics/kodak/, 768x512 resolution, 24 bit depth PNG
        [urlStrings addObject:[NSString stringWithFormat:@"http://r0k.us/graphics/kodak/kodak/kodim%02d.png", i]];
    }
    return urlStrings;
}

@end

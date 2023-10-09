/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <CarPlay/CarPlay.h>
#import "UIView+WebCacheState.h"

@interface CPListItem (WebCacheState)

/**
 Get the image loading state container for specify operation key

 @param key key for identifying the operations
 @return The image loading state container
 */
- (nullable SDWebImageLoadState *)sd_imageLoadStateForKey:(nullable NSString *)key;

/**
 Set the image loading state container for specify operation key

 @param state The image loading state container
 @param key key for identifying the operations
 */
- (void)sd_setImageLoadState:(nullable SDWebImageLoadState *)state forKey:(nullable NSString *)key;

/**
 Rmove the image loading state container for specify operation key

 @param key key for identifying the operations
 */
- (void)sd_removeImageLoadStateForKey:(nullable NSString *)key;

@end

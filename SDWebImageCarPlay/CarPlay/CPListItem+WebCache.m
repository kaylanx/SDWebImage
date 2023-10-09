/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CPListItem+WebCache.h"
#import "objc/runtime.h"
#import "SDInternalMacros.h"
#import "CPListItem+WebCacheOperation.h"
#import "CPListItem+WebCacheState.h"

#if SD_UIKIT

@implementation CPListItem (WebCache)

- (nullable NSString *)sd_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(sd_latestOperationKey));
}

- (void)setSd_latestOperationKey:(NSString * _Nullable)sd_latestOperationKey {
    objc_setAssociatedObject(self, @selector(sd_latestOperationKey), sd_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)sd_setImageWithURL:(nullable NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options context:(nullable SDWebImageContext *)context {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options progress:(nullable SDImageLoaderProgressBlock)progressBlock completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                   context:(nullable SDWebImageContext *)context
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    __weak typeof(self) wself = self;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:context
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (@available(iOS 14.0, *)) {
            [wself setImage: image];
        }
    }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
    }];
}

- (void)sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock cacheType:(SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    SDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else {
        CPListItem *cpListItem = (CPListItem *)self;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, SDImageCacheType setCacheType, NSURL *setImageURL) {
            if (@available(iOS 14.0, *)) {
                [cpListItem setImage: setImage];
            }
        };
    }

    if (finalSetImageBlock) {
        finalSetImageBlock(image, imageData, cacheType, imageURL);
    }
}

- (nullable id<SDWebImageOperation>)sd_internalSetImageWithURL:(nullable NSURL *)url
                                              placeholderImage:(nullable UIImage *)placeholder
                                                       options:(SDWebImageOptions)options
                                                       context:(nullable SDWebImageContext *)context
                                                 setImageBlock:(nullable SDSetImageBlock)setImageBlock
                                                      progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                                     completed:(nullable SDInternalCompletionBlock)completedBlock {
    if (context) {
        // copy to avoid mutable object
        context = [context copy];
    } else {
        context = [NSDictionary dictionary];
    }
    NSString *validOperationKey = context[SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        // pass through the operation key to downstream, which can used for tracing operation or image view class
        validOperationKey = NSStringFromClass([self class]);
        SDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[SDWebImageContextSetImageOperationKey] = validOperationKey;
        context = [mutableContext copy];
    }
    self.sd_latestOperationKey = validOperationKey;
    if (!(SD_OPTIONS_CONTAINS(options, SDWebImageAvoidAutoCancelImage))) {
        // cancel previous loading for the same set-image operation key by default
        [self sd_cancelImageLoadOperationWithKey:validOperationKey];
    }
    SDWebImageLoadState *loadState = [self sd_imageLoadStateForKey:validOperationKey];
    if (!loadState) {
        loadState = [SDWebImageLoadState new];
    }
    loadState.url = url;
    [self sd_setImageLoadState:loadState forKey:validOperationKey];

    SDWebImageManager *manager = context[SDWebImageContextCustomManager];
    if (!manager) {
        manager = [SDWebImageManager sharedManager];
    } else {
        // remove this manager to avoid retain cycle (manger -> loader -> operation -> context -> manager)
        SDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[SDWebImageContextCustomManager] = nil;
        context = [mutableContext copy];
    }

    BOOL shouldUseWeakCache = NO;
    if ([manager.imageCache isKindOfClass:SDImageCache.class]) {
        shouldUseWeakCache = ((SDImageCache *)manager.imageCache).config.shouldUseWeakMemoryCache;
    }
    if (!(options & SDWebImageDelayPlaceholder)) {
        if (shouldUseWeakCache) {
            NSString *key = [manager cacheKeyForURL:url context:context];
            // call memory cache to trigger weak cache sync logic, ignore the return value and go on normal query
            // this unfortunately will cause twice memory cache query, but it's fast enough
            // in the future the weak cache feature may be re-design or removed
            [((SDImageCache *)manager.imageCache) imageFromMemoryCacheForKey:key];
        }
        dispatch_main_async_safe(^{
            [self sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:SDImageCacheTypeNone imageURL:url];
        });
    }

    id <SDWebImageOperation> operation = nil;

    if (url) {
        // reset the progress
        NSProgress *imageProgress = loadState.progress;
        if (imageProgress) {
            imageProgress.totalUnitCount = 0;
            imageProgress.completedUnitCount = 0;
        }

        SDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (imageProgress) {
                imageProgress.totalUnitCount = expectedSize;
                imageProgress.completedUnitCount = receivedSize;
            }

            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        @weakify(self);
        operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self);
            if (!self) { return; }
            // if the progress not been updated, mark it to complete state
            if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
                imageProgress.totalUnitCount = SDWebImageProgressUnitCountUnknown;
                imageProgress.completedUnitCount = SDWebImageProgressUnitCountUnknown;
            }

            BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & SDWebImageDelayPlaceholder)));
            SDWebImageNoParamsBlock callCompletedBlockClosure = ^{
                if (!self) { return; }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };

            // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClosure);
                return;
            }

            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
                targetImage = image;
                targetData = data;
            } else if (options & SDWebImageDelayPlaceholder) {
                // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }

            dispatch_main_async_safe(^{
                [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:cacheType imageURL:imageURL];
                callCompletedBlockClosure();
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        if (completedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
                completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
            });
        }
    }

    return operation;
}

#endif

@end

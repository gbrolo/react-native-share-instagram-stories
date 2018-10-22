#import "RNShareInstagramStories.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <React/RCTLog.h>

@implementation RNShareInstagramStories

NSString *const INSTAGRAM_STORIES_SCHEME = @"instagram-stories://share";

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport
{
    return @{@"GENERAL_ERROR": @"GENERAL_ERROR",
             @"NOT_INSTALLED_ERROR": @"NOT_INSTALLED_ERROR",
             @"FILE_TYPE_UNSUPPORTED_ERROR": @"FILE_TYPE_UNSUPPORTED_ERROR"};
}

- (BOOL)checkInstagramApp
{
    NSURL *urlScheme = [NSURL URLWithString:INSTAGRAM_STORIES_SCHEME];
    return [[UIApplication sharedApplication] canOpenURL:urlScheme];
}

- (NSData*)loadDataFromUri:(nonnull NSString *)uri
{
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:uri];

    NSData *data = [NSData dataWithContentsOfFile:[url relativePath] options: 0 error: &error];

    if (data == nil && error != nil) {
        NSLog(@"Error loading asset: %@", error);
    }

    return data;
}

- (NSString*) fileMIMEType:(NSString*) file {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);

    return (__bridge NSString *)MIMEType;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(isAvailable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([NSNumber numberWithBool:[self checkInstagramApp]]);
}

RCT_EXPORT_METHOD(shareWithStories:(nonnull NSString *)stickerAssetUri
                  backgroundAssetUri:(nonnull NSString *)backgroundAssetUri
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (![self checkInstagramApp]) {
        reject(@"ig_share_failure", @"NOT_INSTALLED_ERROR", nil);
        return;
    }

    NSString *fileType = [self fileMIMEType:stickerAssetUri];

    if (![fileType isEqualToString:@"image/png"] && ![fileType isEqualToString:@"image/jpeg"]) {
        reject(@"ig_share_failure", @"FILE_TYPE_UNSUPPORTED_ERROR", nil);
        return;
    }

    NSData *stickerAsset = [self loadDataFromUri:stickerAssetUri];
    NSData *backgroundAsset = [self loadDataFromUri:backgroundAssetUri];

    if (stickerAsset == nil || backgroundAsset == nil) {
        reject(@"ig_share_failure", @"GENERAL_ERROR", nil );
    }

    NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.stickerImage" : stickerAsset,
                                   @"com.instagram.sharedSticker.backgroundImage" : backgroundAsset}];

    if (@available(iOS 10.0, *)) {
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
    } else {
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems];
    }

    NSURL *urlScheme = [NSURL URLWithString:INSTAGRAM_STORIES_SCHEME];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:urlScheme];
    }

    resolve(@YES);
}

@end


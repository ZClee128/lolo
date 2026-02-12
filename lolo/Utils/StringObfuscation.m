//
//  StringObfuscation.m
//  lolo
//
//  Created on 2026/02/12.
//  Purpose: Centralized string obfuscation implementation
//

#import "StringObfuscation.h"
#import "ObfuscationUtil.h"

@implementation StringObfuscation

#pragma mark - URLs

+ (NSString *)avatarBaseURL {
    static NSString *url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // https://i.pravatar.cc/150?u=
        NSArray *bytes = @[@36, @59, @56, @63, @63, @117, @99, @96, @37, @97, @60, @61, @45, @57, @45, @59, @45, @61, @98, @44, @47, @96, @125, @122, @124, @112, @57, @114];
        url = [ObfuscationUtil decodeBytes:bytes];
    });
    return url;
}

+ (NSString *)placeholderImageBaseURL {
    static NSString *url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // https://picsum.photos/
        NSArray *bytes = @[@36, @59, @56, @63, @63, @117, @99, @96, @60, @38, @47, @60, @57, @34, @98, @63, @36, @32, @56, @32, @63, @96];
        url = [ObfuscationUtil decodeBytes:bytes];
    });
    return url;
}

#pragma mark - Notification Names

+ (NSString *)notificationNameCoinsBalanceChanged {
    static NSString *name = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLOCoinsBalanceDidChangeNotification
        NSArray *bytes = @[@0, @0, @0, @0, @15, @32, @37, @33, @63, @13, @45, @35, @45, @33, @47, @42, @8, @38, @40, @12, @36, @46, @34, @40, @41, @1, @35, @59, @37, @41, @37, @44, @45, @59, @37, @32, @34];
        name = [ObfuscationUtil decodeBytes:bytes];
    });
    return name;
}

+ (NSString *)notificationNameAccountDeleted {
    static NSString *name = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLOAccountDeletedNotification
        NSArray *bytes = @[@0, @0, @0, @0, @13, @44, @47, @32, @57, @33, @56, @11, @41, @35, @41, @59, @41, @43, @2, @32, @56, @38, @42, @38, @47, @46, @56, @38, @35, @33];
        name = [ObfuscationUtil decodeBytes:bytes];
    });
    return name;
}

+ (NSString *)notificationNameTermsAgreed {
    static NSString *name = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLOTermsAgreedNotification
        NSArray *bytes = @[@0, @0, @0, @0, @24, @42, @62, @34, @63, @14, @43, @61, @41, @42, @40, @1, @35, @59, @37, @41, @37, @44, @45, @59, @37, @32, @34];
        name = [ObfuscationUtil decodeBytes:bytes];
    });
    return name;
}

#pragma mark - UserDefaults Keys

+ (NSString *)userDefaultsKeyCurrentUserId {
    static NSString *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLO_CurrentUserId
        NSArray *bytes = @[@0, @0, @0, @0, @19, @12, @57, @61, @62, @42, @34, @59, @25, @60, @41, @61, @5, @43];
        key = [ObfuscationUtil decodeBytes:bytes];
    });
    return key;
}

+ (NSString *)userDefaultsKeyHasAgreedToTerms {
    static NSString *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLO_HasAgreedToTerms
        NSArray *bytes = @[@0, @0, @0, @0, @19, @7, @45, @60, @13, @40, @62, @42, @41, @43, @24, @32, @24, @42, @62, @34, @63];
        key = [ObfuscationUtil decodeBytes:bytes];
    });
    return key;
}

+ (NSString *)userDefaultsKeyUserCreatedPosts {
    static NSString *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLO_UserCreatedPosts
        NSArray *bytes = @[@0, @0, @0, @0, @19, @26, @63, @42, @62, @12, @62, @42, @45, @59, @41, @43, @28, @32, @63, @59, @63];
        key = [ObfuscationUtil decodeBytes:bytes];
    });
    return key;
}

+ (NSString *)userDefaultsKeyBlockedUsers {
    static NSString *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // LOLO_BlockedUsers
        NSArray *bytes = @[@0, @0, @0, @0, @19, @13, @32, @32, @47, @36, @41, @43, @25, @60, @41, @61, @63];
        key = [ObfuscationUtil decodeBytes:bytes];
    });
    return key;
}

@end

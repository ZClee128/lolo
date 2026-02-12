//
//  StringObfuscation.h
//  lolo
//
//  Created on 2026/02/12.
//  Purpose: Centralized string obfuscation to avoid binary fingerprinting
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Centralized obfuscated string management
/// All hardcoded strings that could be fingerprinted should go through this class
@interface StringObfuscation : NSObject

#pragma mark - URLs

/// Avatar image base URL
+ (NSString *)avatarBaseURL;

/// Placeholder image base URL
+ (NSString *)placeholderImageBaseURL;

#pragma mark - Notification Names

/// Coins balance changed notification
+ (NSString *)notificationNameCoinsBalanceChanged;

/// Account deleted notification
+ (NSString *)notificationNameAccountDeleted;

/// Terms agreed notification
+ (NSString *)notificationNameTermsAgreed;

#pragma mark - UserDefaults Keys

/// Current user ID key
+ (NSString *)userDefaultsKeyCurrentUserId;

/// Terms agreement key
+ (NSString *)userDefaultsKeyHasAgreedToTerms;

/// User created posts key
+ (NSString *)userDefaultsKeyUserCreatedPosts;

/// Blocked users key
+ (NSString *)userDefaultsKeyBlockedUsers;

@end

NS_ASSUME_NONNULL_END

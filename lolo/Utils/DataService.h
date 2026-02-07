//
//  DataService.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>
@class User, Post, Activity, Venue, Conversation, Message, SportRecord;

NS_ASSUME_NONNULL_BEGIN

@interface DataService : NSObject

@property (class, nonatomic, readonly) DataService *shared;

- (User *)getCurrentUser;
- (NSArray<User *> *)getUsers;
- (NSArray<Post *> *)getPosts;
- (NSArray<Activity *> *)getActivities;
- (NSArray<Venue *> *)getVenues;
- (NSArray<NSString *> *)getMessagesForUser:(NSString *)userId;
- (void)addMessage:(NSString *)messageText forUser:(NSString *)userId isFromCurrentUser:(BOOL)isFromCurrentUser;
- (NSString *)getLastMessageForUser:(NSString *)userId;
- (NSString *)getLastMessageTimeForUser:(NSString *)userId;
- (NSString *)getLastMessageForUser:(NSString *)userId;
- (NSString *)getLastMessageTimeForUser:(NSString *)userId;
- (NSArray<SportRecord *> *)getSportRecords;
- (void)blockUser:(NSString *)userId;
- (BOOL)isUserBlocked:(NSString *)userId;

// Post management
- (void)addPost:(Post *)post;
- (NSArray<Post *> *)getCurrentUserPosts; // Only returns posts created by current user

// Account management
- (void)deleteCurrentUserAccount;

// Coins management
- (NSInteger)getCurrentUserCoins;
- (BOOL)addCoins:(NSInteger)amount;
- (BOOL)deductCoins:(NSInteger)amount;
- (BOOL)hasEnoughCoins:(NSInteger)amount;

// Pin management
- (BOOL)pinPost:(Post *)post duration:(NSTimeInterval)duration;
- (void)unpinPost:(Post *)post;
- (void)checkAndExpirePinnedPosts;
- (NSArray<Post *> *)sortPostsWithPinnedFirst:(NSArray<Post *> *)posts;

@end

NS_ASSUME_NONNULL_END

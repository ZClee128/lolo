//
//  User.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) NSInteger followingCount;

// Sport stats
@property (nonatomic, assign) double totalDistance; // in km
@property (nonatomic, assign) NSInteger totalCalories;
@property (nonatomic, assign) NSInteger totalWorkouts;

// User blocking and moderation (App Store Guideline 1.2)
@property (nonatomic, copy, nullable) NSArray<NSString *> *blockedUserIds;
@property (nonatomic, assign) BOOL isBlocked; // User is blocked by admin

// Coins system
@property (nonatomic, assign) NSInteger coinsBalance;

- (instancetype)initWithId:(NSString *)userId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                       bio:(NSString *)bio
            followersCount:(NSInteger)followersCount
            followingCount:(NSInteger)followingCount
             totalDistance:(double)totalDistance
             totalCalories:(NSInteger)totalCalories
             totalWorkouts:(NSInteger)totalWorkouts
              coinsBalance:(NSInteger)coinsBalance;

@end

NS_ASSUME_NONNULL_END

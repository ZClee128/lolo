//
//  User.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "User.h"

@implementation User

- (instancetype)initWithId:(NSString *)userId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                       bio:(NSString *)bio
            followersCount:(NSInteger)followersCount
            followingCount:(NSInteger)followingCount
             totalDistance:(double)totalDistance
             totalCalories:(NSInteger)totalCalories
             totalWorkouts:(NSInteger)totalWorkouts
              coinsBalance:(NSInteger)coinsBalance {
    self = [super init];
    if (self) {
        _userId = [userId copy];
        _username = [username copy];
        _avatar = [avatar copy];
        _bio = [bio copy];
        _followersCount = followersCount;
        _followingCount = followingCount;
        _totalDistance = totalDistance;
        _totalCalories = totalCalories;
        _totalWorkouts = totalWorkouts;
        _coinsBalance = coinsBalance;
    }
    return self;
}

@end

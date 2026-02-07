//
//  Post.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "Post.h"
#import "User.h"

@implementation Post

- (instancetype)initWithId:(NSString *)postId
                      user:(User *)user
                 sportType:(NSString *)sportType
                   content:(NSString *)content
                    images:(NSArray<NSString *> *)images
                  videoUrl:(nullable NSString *)videoUrl
                  distance:(nullable NSNumber *)distance
                  duration:(nullable NSNumber *)duration
                  calories:(nullable NSNumber *)calories
                likesCount:(NSInteger)likesCount
             commentsCount:(NSInteger)commentsCount
                 timestamp:(NSDate *)timestamp
                  location:(nullable NSString *)location {
    self = [super init];
    if (self) {
        _postId = [postId copy];
        _user = user;
        _sportType = [sportType copy];
        _content = [content copy];
        _images = [images copy];
        _videoUrl = [videoUrl copy];
        _distance = distance;
        _duration = duration;
        _calories = calories;
        _likesCount = likesCount;
        _commentsCount = commentsCount;
        _timestamp = timestamp;
        _location = [location copy];
        _isPinned = NO;
        _pinnedUntil = nil;
    }
    return self;
}

@end

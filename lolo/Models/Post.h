//
//  Post.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Post : NSObject

@property (nonatomic, copy) NSString *postId;
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *sportType;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSArray<NSString *> *images;
@property (nonatomic, copy, nullable) NSString *videoUrl;

// Pin功能
@property (nonatomic, assign) BOOL isPinned;
@property (nonatomic, strong, nullable) NSDate *pinnedUntil;

@property (nonatomic, strong, nullable) NSNumber *distance; // in km
@property (nonatomic, strong, nullable) NSNumber *duration; // in minutes
@property (nonatomic, strong, nullable) NSNumber *calories;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, copy, nullable) NSString *location;

// Content moderation (App Store Guideline 1.2)
@property (nonatomic, assign) BOOL isFlagged;
@property (nonatomic, assign) BOOL isRemoved;
@property (nonatomic, copy, nullable) NSArray<NSString *> *reportReasons;

// For user-uploaded images (not persisted, only in memory)
@property (nonatomic, strong, nullable) UIImage *selectedImage;

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
                  location:(nullable NSString *)location;

@end

NS_ASSUME_NONNULL_END

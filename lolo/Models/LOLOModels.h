//
//  Activity.h
//  Venue.h
//  Conversation.h
//  SportRecord.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>
@class User, Message;

NS_ASSUME_NONNULL_BEGIN

// Activity
@interface Activity : NSObject
@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *activityDescription;
@property (nonatomic, copy) NSString *coverImage;
@property (nonatomic, copy) NSString *sportType;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, assign) NSInteger maxParticipants;
@property (nonatomic, assign) NSInteger currentParticipants;
@property (nonatomic, strong) User *organizer;
@end

// Venue
@interface Venue : NSObject
@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSArray<NSString *> *sportTypes;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double rating;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@end

// Conversation
@interface Conversation : NSObject
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, strong) User *otherUser;
@property (nonatomic, strong) Message *lastMessage;
@property (nonatomic, assign) NSInteger unreadCount;
@end

// SportRecord
@interface SportRecord : NSObject
@property (nonatomic, copy) NSString *recordId;
@property (nonatomic, copy) NSString *sportType;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, strong, nullable) NSNumber *distance;
@property (nonatomic, assign) NSInteger calories;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy, nullable) NSString *notes;
@property (nonatomic, copy) NSArray<NSString *> *images;
@end

NS_ASSUME_NONNULL_END

//
//  DataService.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "DataService.h"
#import "Post.h"
#import "User.h"
#import "ReportManager.h"
#import "StringObfuscation.h"
#import "ObfuscationUtil.h"
#import "LOLOModels.h"

@interface DataService ()
// Messages storage: key = userId, value = NSMutableArray of messages
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *messagesDict;
@property (nonatomic, strong) NSMutableSet<NSString *> *blockedUserIds;
// User created posts
@property (nonatomic, strong) NSMutableArray<Post *> *userPosts;
@end

@implementation DataService

- (instancetype)init {
    self = [super init];
    if (self) {
        _messagesDict = [NSMutableDictionary dictionary];
        _blockedUserIds = [NSMutableSet set];
        _userPosts = [NSMutableArray array];
        [self loadUserPosts];
        
        // Only setup mock messages if this is NOT a new account
        // New accounts should start with zero messages
        NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:[StringObfuscation userDefaultsKeyCurrentUserId]];
        if (userId != nil) {
            // Existing account - load mock messages for demo purposes
            [self setupInitialMessages];
        }
        // New accounts (userId == nil) will have empty messages
    }
    return self;
}

- (void)setupInitialMessages {
    // Setup some initial messages for users (User IDs 1-5 from getUsers)
    [self addMessage:@"Hey! Want to join the morning run tomorrow?" forUser:@"1" isFromCurrentUser:NO];
    
    [self addMessage:@"Great cycling session today!" forUser:@"2" isFromCurrentUser:NO];
    
    [self addMessage:@"The yoga class schedule has been updated." forUser:@"3" isFromCurrentUser:NO];
    
    [self addMessage:@"See you at the game!" forUser:@"4" isFromCurrentUser:NO];
}

+ (DataService *)shared {
    static DataService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)convertToRelativeDate:(NSDate *)date {
    NSTimeInterval timeInterval = -[date timeIntervalSinceNow];
    
    if (timeInterval < 60) return @"Just now";
    if (timeInterval < 3600) return [NSString stringWithFormat:@"%dm ago", (int)(timeInterval / 60)];
    if (timeInterval < 86400) return [NSString stringWithFormat:@"%dh ago", (int)(timeInterval / 3600)];
    if (timeInterval < 604800) return [NSString stringWithFormat:@"%dd ago", (int)(timeInterval / 86400)];
    
    return @"1w+ ago";
}

- (NSString *)getRelativeTimeForUserId:(NSString *)userId {
    if ([userId isEqualToString:@"1"]) return @"2h ago";
    if ([userId isEqualToString:@"2"]) return @"5h ago";
    if ([userId isEqualToString:@"3"]) return @"1d ago";
    if ([userId isEqualToString:@"4"]) return @"4h ago";
    return @"Just now";
}

// ... (existing methods for users, posts, activities, venues) ...

- (NSArray<NSString *> *)getMessagesForUser:(NSString *)userId {
    if (!self.messagesDict[userId]) {
        self.messagesDict[userId] = [NSMutableArray array];
    }
    return self.messagesDict[userId];
}

- (void)addMessage:(NSString *)messageText forUser:(NSString *)userId isFromCurrentUser:(BOOL)isFromCurrentUser {
    if (!self.messagesDict[userId]) {
        self.messagesDict[userId] = [NSMutableArray array];
    }
    
    // In a real app we would use a Message object. optimizing for string simplicity here as requested
    // Prefixing with "ME:" for current user messages to distinguish simple strings
    NSString *storedMessage = isFromCurrentUser ? [NSString stringWithFormat:@"ME:%@", messageText] : messageText;
    [self.messagesDict[userId] addObject:storedMessage];
}

- (NSString *)getLastMessageForUser:(NSString *)userId {
    NSArray *messages = self.messagesDict[userId];
    if (messages.count > 0) {
        NSString *lastMsg = messages.lastObject;
        if ([lastMsg hasPrefix:@"ME:"]) {
            return [NSString stringWithFormat:@"You: %@", [lastMsg substringFromIndex:3]];
        }
        return lastMsg;
    }
    return @"Started a conversation";
}

- (NSString *)getLastMessageTimeForUser:(NSString *)userId {
    // Simulation
    if ([userId isEqualToString:@"1"]) return @"38m ago";
    if ([userId isEqualToString:@"2"]) return @"1h ago";
    if ([userId isEqualToString:@"3"]) return @"2h ago";
    if ([userId isEqualToString:@"4"]) return @"4h ago";
    return @"Just now";
}

- (User *)getCurrentUser {
    // Check if we have a stored user ID
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:[StringObfuscation userDefaultsKeyCurrentUserId]];
    
    // If no user ID exists, this is a brand new account
    if (!userId) {
        // Generate unique user ID
        userId = [NSString stringWithFormat:@"user_%@", [[NSUUID UUID] UUIDString]];
        
        // Generate unique username
        NSArray *firstNames = @[@"Alex", @"Jordan", @"Taylor", @"Morgan", @"Casey", @"Riley", @"Avery", @"Quinn"];
        NSArray *lastNames = @[@"Chen", @"Smith", @"Johnson", @"Williams", @"Brown", @"Jones", @"Garcia", @"Miller"];
        NSString *firstName = firstNames[arc4random_uniform((uint32_t)firstNames.count)];
        NSString *lastName = lastNames[arc4random_uniform((uint32_t)lastNames.count)];
        NSString *username = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Generate unique avatar URL based on username
        NSString *avatarSeed = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *avatar = [NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], avatarSeed];
        
        // Default bio
        NSString *bio = @"Fitness enthusiast 💪";
        
        // NEW ACCOUNTS START WITH ZERO STATS
        NSInteger followers = 0;
        NSInteger following = 0;
        CGFloat distance = 0.0;
        NSInteger calories = 0;
        NSInteger workouts = 0;
        NSInteger coins = 50; // New users get 50 free coins
        
        // Save everything to UserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userId forKey:[StringObfuscation userDefaultsKeyCurrentUserId]];
        [defaults setObject:username forKey:@"CurrentUsername"];
        [defaults setObject:avatar forKey:@"CurrentAvatar"];
        [defaults setObject:bio forKey:@"CurrentBio"];
        [defaults setInteger:followers forKey:@"CurrentFollowers"];
        [defaults setInteger:following forKey:@"CurrentFollowing"];
        [defaults setDouble:distance forKey:@"CurrentDistance"];
        [defaults setInteger:calories forKey:@"CurrentCalories"];
        [defaults setInteger:workouts forKey:@"CurrentWorkouts"];
        [defaults setInteger:coins forKey:@"CurrentCoins"];
        [defaults synchronize];
        
        NSLog(@"[DataService] New account created: %@ (ID: %@)", username, userId);
    }
    
    // Load all data from UserDefaults (works for both new and existing accounts)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"CurrentUsername"];
    NSString *avatar = [defaults stringForKey:@"CurrentAvatar"];
    NSString *bio = [defaults stringForKey:@"CurrentBio"];
    NSInteger followers = [defaults integerForKey:@"CurrentFollowers"];
    NSInteger following = [defaults integerForKey:@"CurrentFollowing"];
    CGFloat distance = [defaults doubleForKey:@"CurrentDistance"];
    NSInteger calories = [defaults integerForKey:@"CurrentCalories"];
    NSInteger workouts = [defaults integerForKey:@"CurrentWorkouts"];
    NSInteger coins = [defaults integerForKey:@"CurrentCoins"];
    
    // Create and return user object
    User *user = [[User alloc] initWithId:userId
                                 username:username
                                   avatar:avatar
                                      bio:bio
                           followersCount:followers
                           followingCount:following
                            totalDistance:distance
                            totalCalories:calories
                            totalWorkouts:workouts
                             coinsBalance:coins];
    return user;
}

- (NSArray<User *> *)getUsers {
    NSMutableArray<User *> *users = [NSMutableArray array];
    
    [users addObject:[[User alloc] initWithId:@"1" username:@"Sarah Johnson" avatar:[NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"1"] bio:@"Running coach | 5 marathons completed 🏃‍♀️" followersCount:2145 followingCount:324 totalDistance:3200.5 totalCalories:180500 totalWorkouts:420 coinsBalance:0]];
    
    [users addObject:[[User alloc] initWithId:@"2" username:@"Mike Chen" avatar:[NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"2"] bio:@"Cyclist | Mountain biker | Weekend warrior 🚴" followersCount:1856 followingCount:412 totalDistance:8450.3 totalCalories:425000 totalWorkouts:315 coinsBalance:0]];
    
    [users addObject:[[User alloc] initWithId:@"3" username:@"Emma Davis" avatar:[NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"3"] bio:@"Yoga instructor | Mindfulness advocate 🧘‍♀️" followersCount:3421 followingCount:198 totalDistance:125.8 totalCalories:89200 totalWorkouts:628 coinsBalance:0]];
    
    [users addObject:[[User alloc] initWithId:@"4" username:@"James Wilson" avatar:[NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"4"] bio:@"Basketball player | Team captain | Hoops life 🏀" followersCount:987 followingCount:645 totalDistance:450.2 totalCalories:125600 totalWorkouts:245 coinsBalance:0]];
    
    [users addObject:[[User alloc] initWithId:@"5" username:@"Lisa Martinez" avatar:[NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"5"] bio:@"Swimmer | Triathlete in training | Water is life 🏊‍♀️" followersCount:1654 followingCount:289 totalDistance:1247.6 totalCalories:156800 totalWorkouts:398 coinsBalance:0]];
    
    return users;
}

- (NSArray<Post *> *)getPosts {
    NSArray<User *> *users = [self getUsers];
    User *currentUser = [self getCurrentUser];
    NSDate *now = [NSDate date];
    
    NSMutableArray<Post *> *posts = [NSMutableArray array];
    
    // Add user created posts first (newest first)
    [posts addObjectsFromArray:self.userPosts];
    
    // First two posts MUST be videos - using mock users, NOT current user
    [posts addObject:[[Post alloc] initWithId:@"v1" user:users[0] sportType:@"Cycling" content:@"Check out my new cycling route! 🚴‍♂️ The weather was perfect and I managed to capture some great moments." images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 1]] videoUrl:@"x0p4m1.mp4" distance:@25.5 duration:@90 calories:@650 likesCount:43 commentsCount:5 timestamp:[now dateByAddingTimeInterval:-300] location:@"Lolo Park"]];
    
    [posts addObject:[[Post alloc] initWithId:@"v2" user:users[1] sportType:@"Running" content:@"Morning trail run through the forest! 🏃‍♀️ Beautiful sunrise views today." images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 2]] videoUrl:@"v8n2m9.mp4" distance:@8.2 duration:@45 calories:@520 likesCount:67 commentsCount:8 timestamp:[now dateByAddingTimeInterval:-600] location:@"Forest Trail"]];
    
    // More diverse posts with different users and content
    [posts addObject:[[Post alloc] initWithId:@"3" user:users[2] sportType:@"Swimming" content:@"Finally hit my 1000m freestyle goal! 🏊‍♂️ Practice makes perfect." images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 3]] videoUrl:nil distance:@1.0 duration:@25 calories:@280 likesCount:52 commentsCount:12 timestamp:[now dateByAddingTimeInterval:-1800] location:@"Olympic Pool"]];
    
    [posts addObject:[[Post alloc] initWithId:@"4" user:users[3] sportType:@"Yoga" content:@"Sunday morning yoga session 🧘‍♂️ Feeling refreshed and centered." images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 4]] videoUrl:nil distance:@0 duration:@60 calories:@180 likesCount:38 commentsCount:4 timestamp:[now dateByAddingTimeInterval:-3600] location:@"Sunset Studio"]];
    
    [posts addObject:[[Post alloc] initWithId:@"5" user:users[4] sportType:@"Basketball" content:@"Epic game today! 🏀 We won 98-92 in overtime. Team effort!" images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 5]] videoUrl:nil distance:@2.5 duration:@105 calories:@680 likesCount:94 commentsCount:18 timestamp:[now dateByAddingTimeInterval:-7200] location:@"Downtown Court"]];
    
    [posts addObject:[[Post alloc] initWithId:@"6" user:users[0] sportType:@"Hiking" content:@"Weekend mountain adventure 🏔️ The view from the summit was absolutely worth it!" images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 6]] videoUrl:nil distance:@12.3 duration:@210 calories:@890 likesCount:128 commentsCount:23 timestamp:[now dateByAddingTimeInterval:-14400] location:@"Eagle Peak"]];
    
    [posts addObject:[[Post alloc] initWithId:@"7" user:users[1] sportType:@"Tennis" content:@"Great match with my doubles partner! 🎾 Won 6-4, 7-5." images:@[[NSString stringWithFormat:@"%@400/300?random=%d", [StringObfuscation placeholderImageBaseURL], 7]] videoUrl:nil distance:@4.2 duration:@90 calories:@450 likesCount:61 commentsCount:9 timestamp:[now dateByAddingTimeInterval:-21600] location:@"City Tennis Club"]];
    
    return posts;
}

- (NSArray<Activity *> *)getActivities {
    NSArray<User *> *users = [self getUsers];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSMutableArray<Activity *> *activities = [NSMutableArray array];
    
    Activity *activity1 = [[Activity alloc] init];
    activity1.activityId = @"1";
    activity1.title = @"Weekend Group Run";
    activity1.activityDescription = @"Join us for a scenic 10K run through the park. All paces welcome!";
    activity1.coverImage = @"figure.run";
    activity1.sportType = @"Running";
    activity1.location = @"Lake Park";
    activity1.startTime = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:now options:0];
    activity1.endTime = [activity1.startTime dateByAddingTimeInterval:3600*2];
    activity1.maxParticipants = 20;
    activity1.currentParticipants = 12;
    activity1.organizer = users[0];
    [activities addObject:activity1];
    
    Activity *activity2 = [[Activity alloc] init];
    activity2.activityId = @"2";
    activity2.title = @"Sunset Cycling Tour";
    activity2.activityDescription = @"Experience the city's best cycling routes as the sun sets.";
    activity2.coverImage = @"figure.outdoor.cycle";
    activity2.sportType = @"Cycling";
    activity2.location = @"Riverside Trail";
    activity2.startTime = [calendar dateByAddingUnit:NSCalendarUnitDay value:2 toDate:now options:0];
    activity2.endTime = [activity2.startTime dateByAddingTimeInterval:3600*3];
    activity2.maxParticipants = 15;
    activity2.currentParticipants = 8;
    activity2.organizer = users[1];
    [activities addObject:activity2];
    
    return activities;
}

- (NSArray<Venue *> *)getVenues {
    NSMutableArray<Venue *> *venues = [NSMutableArray array];
    
    Venue *venue1 = [[Venue alloc] init];
    venue1.venueId = @"1";
    venue1.name = @"FitZone Gym";
    venue1.image = @"figure.strengthtraining.traditional";
    venue1.sportTypes = @[@"Gym", @"Weightlifting", @"HIIT"];
    venue1.distance = 0.8;
    venue1.rating = 4.7;
    venue1.address = @"123 Main St, Downtown";
    venue1.latitude = 40.7128;
    venue1.longitude = -74.0060;
    [venues addObject:venue1];
    
    Venue *venue2 = [[Venue alloc] init];
    venue2.venueId = @"2";
    venue2.name = @"AquaLife Pool";
    venue2.image = @"figure.pool.swim";
    venue2.sportTypes = @[@"Swimming", @"Water Polo"];
    venue2.distance = 1.2;
    venue2.rating = 4.8;
    venue2.address = @"456 Water Ave, Westside";
    venue2.latitude = 40.7200;
    venue2.longitude = -74.0100;
    [venues addObject:venue2];
    
    return venues;
}

- (NSArray<Conversation *> *)getConversations {
    // Basic implementation
    return @[];
}

- (NSArray<Message *> *)getMessagesForConversationId:(NSString *)conversationId {
    // Basic implementation
    return @[];
}

- (NSArray<SportRecord *> *)getSportRecords {
    // Basic implementation  
    return @[];
}

- (void)blockUser:(NSString *)userId {
    [self.blockedUserIds addObject:userId];
}

- (BOOL)isUserBlocked:(NSString *)userId {
    return [self.blockedUserIds containsObject:userId];
}

#pragma mark - Post Management

- (void)addPost:(Post *)post {
    // Add to user posts array
    [self.userPosts insertObject:post atIndex:0]; // Insert at beginning for newest first
    
    // Save to UserDefaults
    [self saveUserPosts];
}

- (NSArray<Post *> *)getCurrentUserPosts {
    // Return only the posts created by the current user (stored in userPosts array)
    // This excludes all mock data
    return [self.userPosts copy];
}

- (void)saveUserPosts {
    NSMutableArray *postsData = [NSMutableArray array];
    
    for (Post *post in self.userPosts) {
        NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
        postDict[@"postId"] = post.postId ?: @"";
        postDict[@"userId"] = post.user.userId ?: @"";
        postDict[@"username"] = post.user.username ?: @"";
        postDict[@"avatar"] = post.user.avatar ?: @"";
        postDict[@"sportType"] = post.sportType ?: @"";
        postDict[@"content"] = post.content ?: @"";
        postDict[@"images"] = post.images ?: @[];
        postDict[@"videoUrl"] = post.videoUrl ?: @"";
        postDict[@"distance"] = post.distance ?: @0;
        postDict[@"duration"] = post.duration ?: @0;
        postDict[@"calories"] = post.calories ?: @0;
        postDict[@"likesCount"] = @(post.likesCount);
        postDict[@"commentsCount"] = @(post.commentsCount);
        postDict[@"timestamp"] = post.timestamp ?: [NSDate date];
        postDict[@"location"] = post.location ?: @"";
        postDict[@"isPinned"] = @(post.isPinned);
        
        if (post.pinnedUntil) {
            postDict[@"pinnedUntil"] = post.pinnedUntil;
        }
        
        [postsData addObject:postDict];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:postsData forKey:[StringObfuscation userDefaultsKeyUserCreatedPosts]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadUserPosts {
    NSArray *postsData = [[NSUserDefaults standardUserDefaults] arrayForKey:[StringObfuscation userDefaultsKeyUserCreatedPosts]];
    
    if (postsData) {
        for (NSDictionary *postDict in postsData) {
            // Reconstruct user object
            User *user = [[User alloc] initWithId:postDict[@"userId"]
                                         username:postDict[@"username"]
                                           avatar:postDict[@"avatar"]
                                              bio:@""
                                   followersCount:0
                                   followingCount:0
                                    totalDistance:0
                                    totalCalories:0
                                    totalWorkouts:0
                                     coinsBalance:0];
            
            // Reconstruct post object
            Post *post = [[Post alloc] initWithId:postDict[@"postId"]
                                             user:user
                                        sportType:postDict[@"sportType"]
                                          content:postDict[@"content"]
                                           images:postDict[@"images"]
                                         videoUrl:postDict[@"videoUrl"]
                                         distance:postDict[@"distance"]
                                         duration:postDict[@"duration"]
                                         calories:postDict[@"calories"]
                                       likesCount:[postDict[@"likesCount"] integerValue]
                                    commentsCount:[postDict[@"commentsCount"] integerValue]
                                        timestamp:postDict[@"timestamp"]
                                         location:postDict[@"location"]];
            
            // Restore pin status
            if (postDict[@"isPinned"]) {
                post.isPinned = [postDict[@"isPinned"] boolValue];
            }
            if (postDict[@"pinnedUntil"] && ![postDict[@"pinnedUntil"] isEqual:[NSNull null]]) {
                post.pinnedUntil = postDict[@"pinnedUntil"];
            }
            
            [self.userPosts addObject:post];
        }
    }
}

#pragma mark - Account Management

- (void)deleteCurrentUserAccount {
    // Clear all in-memory data
    self.userPosts = [NSMutableArray array];
    self.messagesDict = [NSMutableDictionary dictionary];
    self.blockedUserIds = [NSMutableSet set];
    
    // Clear ALL UserDefaults data related to the account
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // User identity
    [defaults removeObjectForKey:[StringObfuscation userDefaultsKeyCurrentUserId]];
    [defaults removeObjectForKey:@"CurrentUsername"];
    [defaults removeObjectForKey:@"CurrentAvatar"];
    [defaults removeObjectForKey:@"CurrentBio"];
    
    // User stats
    [defaults removeObjectForKey:@"CurrentFollowers"];
    [defaults removeObjectForKey:@"CurrentFollowing"];
    [defaults removeObjectForKey:@"CurrentDistance"];
    [defaults removeObjectForKey:@"CurrentCalories"];
    [defaults removeObjectForKey:@"CurrentWorkouts"];
    [defaults removeObjectForKey:@"CurrentCoins"];
    
    // User content
    [defaults removeObjectForKey:[StringObfuscation userDefaultsKeyUserCreatedPosts]];
    [defaults removeObjectForKey:[StringObfuscation userDefaultsKeyHasAgreedToTerms]];
    
    // Other app data
    [defaults removeObjectForKey:[StringObfuscation userDefaultsKeyBlockedUsers]];
    [defaults removeObjectForKey:@"SavedPosts"];
    [defaults removeObjectForKey:@"hasAcceptedTerms"]; // Legacy key
    
    [defaults synchronize];
    
    NSLog(@"[DataService] Account deleted - all user data cleared");
    
    // Post notification to reset app
    [[NSNotificationCenter defaultCenter] postNotificationName:[StringObfuscation notificationNameAccountDeleted] object:nil];
}

#pragma mark - Coins Management

- (NSInteger)getCurrentUserCoins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"CurrentCoins"];
}

- (BOOL)addCoins:(NSInteger)amount {
    if (amount <= 0) {
        NSLog(@"[DataService] Cannot add negative or zero coins");
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentCoins = [defaults integerForKey:@"CurrentCoins"];
    NSInteger newBalance = currentCoins + amount;
    
    [defaults setInteger:newBalance forKey:@"CurrentCoins"];
    [defaults synchronize];
    
    NSLog(@"[DataService] Added %ld coins. New balance: %ld", (long)amount, (long)newBalance);
    
    // Post notification for UI updates
    [[NSNotificationCenter defaultCenter] postNotificationName:[StringObfuscation notificationNameCoinsBalanceChanged] object:nil];
    
    return YES;
}

- (BOOL)deductCoins:(NSInteger)amount {
    if (amount <= 0) {
        NSLog(@"[DataService] Cannot deduct negative or zero coins");
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentCoins = [defaults integerForKey:@"CurrentCoins"];
    
    if (currentCoins < amount) {
        NSLog(@"[DataService] Insufficient coins. Current: %ld, Required: %ld", (long)currentCoins, (long)amount);
        return NO;
    }
    
    NSInteger newBalance = currentCoins - amount;
    [defaults setInteger:newBalance forKey:@"CurrentCoins"];
    [defaults synchronize];
    
    NSLog(@"[DataService] Deducted %ld coins. New balance: %ld", (long)amount, (long)newBalance);
    
    // Post notification for UI updates
    [[NSNotificationCenter defaultCenter] postNotificationName:[StringObfuscation notificationNameCoinsBalanceChanged] object:nil];
    
    return YES;
}

- (BOOL)hasEnoughCoins:(NSInteger)amount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentCoins = [defaults integerForKey:@"CurrentCoins"];
    return currentCoins >= amount;
}

#pragma mark - Pin Management

- (BOOL)pinPost:(Post *)post duration:(NSTimeInterval)duration {
    if (!post) return NO;
    post.isPinned = YES;
    post.pinnedUntil = [NSDate dateWithTimeIntervalSinceNow:duration];
    [self saveUserPosts];
    NSLog(@"[DataService] Pinned post %@ until %@", post.postId, post.pinnedUntil);
    return YES;
}

- (void)unpinPost:(Post *)post {
    if (!post) return;
    post.isPinned = NO;
    post.pinnedUntil = nil;
    [self saveUserPosts];
    NSLog(@"[DataService] Unpinned post %@", post.postId);
}

- (void)checkAndExpirePinnedPosts {
    NSDate *now = [NSDate date];
    BOOL needsSave = NO;
    for (Post *post in self.userPosts) {
        if (post.isPinned && post.pinnedUntil && [post.pinnedUntil compare:now] == NSOrderedAscending) {
            post.isPinned = NO;
            post.pinnedUntil = nil;
            needsSave = YES;
            NSLog(@"[DataService] Expired pin for post %@", post.postId);
        }
    }
    if (needsSave) [self saveUserPosts];
}

- (NSArray<Post *> *)sortPostsWithPinnedFirst:(NSArray<Post *> *)posts {
    [self checkAndExpirePinnedPosts];
    return [posts sortedArrayUsingComparator:^NSComparisonResult(Post *post1, Post *post2) {
        if (post1.isPinned && post2.isPinned) return [post2.pinnedUntil compare:post1.pinnedUntil];
        if (post1.isPinned) return NSOrderedAscending;
        if (post2.isPinned) return NSOrderedDescending;
        return [post2.timestamp compare:post1.timestamp];
    }];
}

@end

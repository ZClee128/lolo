//
//  UIView+Extensions.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LOLOExtensions)

- (void)addShadowWithOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;
- (void)roundCornersWithRadius:(CGFloat)radius;

@end

@interface UIColor (LOLOExtensions)

- (instancetype)initWithHexString:(NSString *)hexString;

@end

@interface NSDate (LOLOExtensions)

- (NSString *)timeAgo;
- (NSString *)formattedWithFormat:(NSString *)format;

@end

@interface NSString (LOLOExtensions)

- (nullable NSDate *)toDateWithFormat:(NSString *)format;

@end

NS_ASSUME_NONNULL_END

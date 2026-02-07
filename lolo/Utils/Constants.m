//
//  Constants.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "Constants.h"
#import "ObfuscationUtil.h"

@implementation LOLOColors

+ (UIColor *)primary {
    return [UIColor colorWithRed:1.0 green:0.42 blue:0.21 alpha:1.0]; // #FF6B35
}

+ (UIColor *)accent {
    return [UIColor colorWithRed:0.31 green:0.80 blue:0.77 alpha:1.0]; // #4ECDC4
}

+ (UIColor *)background {
    return [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]; // #F7F7F7
}

+ (UIColor *)textPrimary {
    return [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

+ (UIColor *)textSecondary {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

+ (UIColor *)border {
    return [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
}

+ (UIColor *)lightGray {
    return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

@end

@implementation LOLOFonts

+ (UIFont *)largeTitle {
    return [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
}

+ (UIFont *)title {
    return [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
}

+ (UIFont *)headline {
    return [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
}

+ (UIFont *)body {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
}

+ (UIFont *)bodyBold {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
}

+ (UIFont *)caption {
    return [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
}

+ (UIFont *)smallCaption {
    return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
}

+ (UIFont *)sectionHeader {
    return [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
}

@end

@implementation LOLOSpacing

+ (CGFloat)small {
    return 8.0;
}

+ (CGFloat)medium {
    return 16.0;
}

+ (CGFloat)large {
    return 24.0;
}

+ (CGFloat)extraLarge {
    return 32.0;
}

@end

@implementation LOLOCornerRadius

+ (CGFloat)standard {
    return 12.0;
}

+ (CGFloat)large {
    return 20.0;
}

+ (CGFloat)circle {
    return 999.0;
}

@end

@implementation LOLOSportTypes

+ (NSArray<NSString *> *)all {
    static NSArray<NSString *> *sportTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sportTypes = @[
            [ObfuscationUtil decodeBytes:@[@0x12, @0x3A, @0x22, @0x21, @0x25, @0x29, @0x2B, @0x27]], // "Running"
            [ObfuscationUtil decodeBytes:@[@0x03, @0x36, @0x2F, @0x23, @0x25, @0x26, @0x2B, @0x27]], // "Cycling"
            [ObfuscationUtil decodeBytes:@[@0x13, @0x38, @0x25, @0x22, @0x21, @0x26, @0x27, @0x29]], // "Swimming"
            [ObfuscationUtil decodeBytes:@[@0x02, @0x2E, @0x3F, @0x24, @0x29, @0x3B, @0x2E, @0x2F, @0x2C, @0x23]], // "Basketball"
            [ObfuscationUtil decodeBytes:@[@0x06, @0x20, @0x23, @0x3B, @0x2E, @0x2E, @0x20, @0x23, @0x2C]], // "Football"
            [ObfuscationUtil decodeBytes:@[@0x14, @0x2A, @0x22, @0x21, @0x25, @0x3C]], // "Tennis"
            [ObfuscationUtil decodeBytes:@[@0x19, @0x20, @0x2B, @0x2E]], // "Yoga"
            [ObfuscationUtil decodeBytes:@[@0x07, @0x36, @0x21]], // "Gym"
            [ObfuscationUtil decodeBytes:@[@0x08, @0x26, @0x27, @0x26, @0x22, @0x28]], // "Hiking"
            [ObfuscationUtil decodeBytes:@[@0x04, @0x2E, @0x22, @0x2C, @0x25, @0x29, @0x27]] // "Dancing"
        ];
    });
    return sportTypes;
}

+ (NSArray<NSString *> *)allCases {
    return [self all];
}

@end

//
//  ObfuscationUtil.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A simple utility to decode obfuscated strings at runtime.
@interface ObfuscationUtil : NSObject

/// Decodes a byte array using XOR with a fixed key.
/// @param bytes The obfuscated byte array.
/// @return The original string.
+ (NSString *)decodeBytes:(NSArray<NSNumber *> *)bytes;

@end

NS_ASSUME_NONNULL_END

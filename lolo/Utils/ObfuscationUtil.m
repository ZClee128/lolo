//
//  ObfuscationUtil.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "ObfuscationUtil.h"

@implementation ObfuscationUtil

+ (NSString *)decodeBytes:(NSArray<NSNumber *> *)bytes {
    static const UInt8 key[] = {0x4C, 0x4F, 0x4C, 0x4F}; // "LOLO" in hex
    static const NSUInteger keyLength = sizeof(key) / sizeof(key[0]);
    
    NSMutableData *decoded = [NSMutableData dataWithCapacity:bytes.count];
    
    for (NSUInteger index = 0; index < bytes.count; index++) {
        UInt8 byte = [bytes[index] unsignedCharValue];
        UInt8 decodedByte = byte ^ key[index % keyLength];
        [decoded appendBytes:&decodedByte length:1];
    }
    
    return [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding] ?: @"";
}

@end

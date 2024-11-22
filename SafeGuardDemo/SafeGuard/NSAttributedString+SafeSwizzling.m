//
//  NSAttributedString+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSAttributedString+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSAttributedString (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取NSConcreteAttributedString的类对象
        Class concreteAttributedStringClass = objc_getClass("NSConcreteAttributedString");
        // 交换实例方法 initWithString:
        [NSAttributedString mk_swizzleInstanceMethodClass:concreteAttributedStringClass withInstanceMethod:@selector(initWithString:) withSwizzleMethod:@selector(mksafe_initWithString:)];
        // 交换实例方法 attributedSubstringFromRange:
        [NSAttributedString mk_swizzleInstanceMethodClass:concreteAttributedStringClass withInstanceMethod:@selector(attributedSubstringFromRange:) withSwizzleMethod:@selector(mksafe_attributedSubstringFromRange:)];
        // 交换实例方法 attribute:atIndex:effectiveRange:
        [NSAttributedString mk_swizzleInstanceMethodClass:concreteAttributedStringClass withInstanceMethod:@selector(attribute:atIndex:effectiveRange:) withSwizzleMethod:@selector(mksafe_attribute:atIndex:effectiveRange:)];
        // 交换实例方法 enumerateAttribute:inRange:options:usingBlock:
        [NSAttributedString mk_swizzleInstanceMethodClass:concreteAttributedStringClass withInstanceMethod:@selector(enumerateAttribute:inRange:options:usingBlock:) withSwizzleMethod:@selector(mksafe_enumerateAttribute:inRange:options:usingBlock:)];
        // 交换实例方法 enumerateAttributesInRange:options:usingBlock:
        [NSAttributedString mk_swizzleInstanceMethodClass:concreteAttributedStringClass withInstanceMethod:@selector(enumerateAttributesInRange:options:usingBlock:) withSwizzleMethod:@selector(mksafe_enumerateAttributesInRange:options:usingBlock:)];
    });
}

#pragma mark - Safe Methods

- (instancetype)mksafe_initWithString:(NSString *)str {
    if (str == nil) {
        NSLog(@"❌❌❌: Attempted to initialize NSAttributedString with nil string in mksafe_initWithString:");
        return nil;
    }
    return [self mksafe_initWithString:str];
}

- (NSAttributedString *)mksafe_attributedSubstringFromRange:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_attributedSubstringFromRange: with attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return nil;
    }
    return [self mksafe_attributedSubstringFromRange:range];
}

- (id)mksafe_attribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    if (index >= self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_attribute:atIndex:effectiveRange: with attributed string length %lu", (unsigned long)index, (unsigned long)self.length);
        return nil;
    }
    return [self mksafe_attribute:attrName atIndex:index effectiveRange:range];
}

- (void)mksafe_enumerateAttribute:(NSAttributedStringKey)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, BOOL *stop))block {
    if (NSMaxRange(enumerationRange) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_enumerateAttribute:inRange:options:usingBlock: with attributed string length %lu", (unsigned long)enumerationRange.location, (unsigned long)enumerationRange.length, (unsigned long)self.length);
        
        // 修正范围，以避免超出边界的崩溃
        enumerationRange = NSMakeRange(enumerationRange.location, self.length - enumerationRange.location);
    }
    
    [self mksafe_enumerateAttribute:attrName inRange:enumerationRange options:opts usingBlock:block];
}

- (void)mksafe_enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop))block {
    if (NSMaxRange(enumerationRange) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_enumerateAttributesInRange:options:usingBlock: with attributed string length %lu", (unsigned long)enumerationRange.location, (unsigned long)enumerationRange.length, (unsigned long)self.length);
        
        // 修正范围，以避免超出边界的崩溃
        enumerationRange = NSMakeRange(enumerationRange.location, self.length - enumerationRange.location);
    }
    
    [self mksafe_enumerateAttributesInRange:enumerationRange options:opts usingBlock:block];
}

@end

//
//  NSString+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSString+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSString (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换类方法 stringWithUTF8String:
        [NSString mk_swizzleClassMethod:@selector(stringWithUTF8String:) withSwizzleMethod:@selector(mksafe_stringWithUTF8String:)];
        // 交换类方法 stringWithCString:encoding:
        [NSString mk_swizzleClassMethod:@selector(stringWithCString:encoding:) withSwizzleMethod:@selector(mksafe_stringWithCString:encoding:)];
        
        // 获取__NSCFConstantString的类对象(不可变字符串)
        Class immutableStringClass = objc_getClass("__NSCFConstantString");
        // 交换实例方法 characterAtIndex:
        [NSString mk_swizzleInstanceMethodClass:immutableStringClass withInstanceMethod:@selector(characterAtIndex:) withSwizzleMethod:@selector(mksafe_characterAtIndex:)];
        // 交换实例方法 substringFromIndex:
        [NSString mk_swizzleInstanceMethodClass:immutableStringClass withInstanceMethod:@selector(substringFromIndex:) withSwizzleMethod:@selector(mksafe_constant_substringFromIndex:)];
        // 交换实例方法 substringToIndex:
        [NSString mk_swizzleInstanceMethodClass:immutableStringClass withInstanceMethod:@selector(substringToIndex:) withSwizzleMethod:@selector(mksafe_constant_substringToIndex:)];
        // 交换实例方法 substringWithRange:
        [NSString mk_swizzleInstanceMethodClass:immutableStringClass withInstanceMethod:@selector(substringWithRange:) withSwizzleMethod:@selector(mksafe_constant_substringWithRange:)];
        // 交换实例方法 rangeOfString:options:range:locale:
        [NSString mk_swizzleInstanceMethodClass:immutableStringClass withInstanceMethod:@selector(rangeOfString:options:range:locale:) withSwizzleMethod:@selector(mksafe_rangeOfString:options:range:locale:)];
    });
}

#pragma mark - Safe Methods

+ (instancetype)mksafe_stringWithUTF8String:(const char *)nullCString {
    if (nullCString == NULL) {
        NSLog(@"❌❌❌: mksafe_stringWithUTF8String received NULL cString");
        return nil;
    }
    return [self mksafe_stringWithUTF8String:nullCString];
}

+ (instancetype)mksafe_stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding
{
    if (NULL == cString){
        NSLog(@"❌❌❌: mksafe_stringWithCString:encoding: received NULL cString");
        return nil;
    }
    return [self mksafe_stringWithCString:cString encoding:encoding];
}

- (unichar)mksafe_characterAtIndex:(NSUInteger)index {
    if (index >= self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_characterAtIndex: with string length %lu", (unsigned long)index, (unsigned long)self.length);
        return 0;
    }
    return [self mksafe_characterAtIndex:index];
}

- (NSString *)mksafe_constant_substringFromIndex:(NSUInteger)index {
    if (index > self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_constant_substringFromIndex: with string length %lu", (unsigned long)index, (unsigned long)self.length);
        return @"";
    }
    return [self mksafe_constant_substringFromIndex:index];
}

- (NSString *)mksafe_constant_substringToIndex:(NSUInteger)index {
    if (index > self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_constant_substringToIndex: with string length %lu", (unsigned long)index, (unsigned long)self.length);
        return @"";
    }
    return [self mksafe_constant_substringToIndex:index];
}

- (NSString *)mksafe_constant_substringWithRange:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_constant_substringWithRange: with string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return @"";
    }
    return [self mksafe_constant_substringWithRange:range];
}

- (NSRange)mksafe_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options range:(NSRange)range locale:(NSLocale *)locale {
    if (!searchString) {
        NSLog(@"❌❌❌: Attempted to search nil string in mksafe_rangeOfString:options:range:locale:");
        return NSMakeRange(NSNotFound, 0);
    }
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_rangeOfString:options:range:locale: with string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return NSMakeRange(NSNotFound, 0);
    }
    return [self mksafe_rangeOfString:searchString options:options range:range locale:locale];
}

@end

//
//  NSMutableString+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSMutableString+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSMutableString (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取__NSCFString的类对象(可变字符串)
        Class mutableStringClass = objc_getClass("__NSCFString");
        // 交换实例方法 appendString:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(appendString:) withSwizzleMethod:@selector(mksafe_appendString:)];
        // 交换实例方法 insertString:atIndex:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(insertString:atIndex:) withSwizzleMethod:@selector(mksafe_insertString:atIndex:)];
        // 交换实例方法 deleteCharactersInRange:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(deleteCharactersInRange:) withSwizzleMethod:@selector(mksafe_deleteCharactersInRange:)];
        // 交换实例方法 replaceCharactersInRange:withString:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(replaceCharactersInRange:withString:) withSwizzleMethod:@selector(mksafe_replaceCharactersInRange:withString:)];
        // 交换实例方法 substringFromIndex:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(substringFromIndex:) withSwizzleMethod:@selector(mksafe_substringFromIndex:)];
        // 交换实例方法 substringToIndex:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(substringToIndex:) withSwizzleMethod:@selector(mksafe_substringToIndex:)];
        // 交换实例方法 substringWithRange:
        [NSMutableString mk_swizzleInstanceMethodClass:mutableStringClass withInstanceMethod:@selector(substringWithRange:) withSwizzleMethod:@selector(mksafe_substringWithRange:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_appendString:(NSString *)aString {
    if (aString == nil) {
        NSLog(@"❌❌❌: Attempted to append nil string in mksafe_appendString:");
        return;
    }
    [self mksafe_appendString:aString];
}

- (void)mksafe_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    if (aString == nil) {
        NSLog(@"❌❌❌: Attempted to insert nil string in mksafe_insertString:atIndex:");
        return;
    }
    if (loc > self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_insertString:atIndex: with string length %lu", (unsigned long)loc, (unsigned long)self.length);
        return;
    }
    [self mksafe_insertString:aString atIndex:loc];
}

- (void)mksafe_deleteCharactersInRange:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_deleteCharactersInRange: with string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return;
    }
    [self mksafe_deleteCharactersInRange:range];
}

- (void)mksafe_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if (aString == nil) {
        NSLog(@"❌❌❌: Attempted to replace with nil string in mksafe_replaceCharactersInRange:withString:");
        return;
    }
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_replaceCharactersInRange:withString: with string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return;
    }
    [self mksafe_replaceCharactersInRange:range withString:aString];
}

- (NSString *)mksafe_substringFromIndex:(NSUInteger)index {
    if (index > self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_substringFromIndex: with string length %lu", (unsigned long)index, (unsigned long)self.length);
        return nil;
    }
    return [self mksafe_substringFromIndex:index];
}

- (NSString *)mksafe_substringToIndex:(NSUInteger)index {
    if (index > self.length) {
        NSLog(@"❌❌❌: Index %lu out of bounds in mksafe_substringToIndex: with string length %lu", (unsigned long)index, (unsigned long)self.length);
        return nil;
    }
    return [self mksafe_substringToIndex:index];
}

- (NSString *)mksafe_substringWithRange:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_substringWithRange: with string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        return nil;
    }
    return [self mksafe_substringWithRange:range];
}

@end

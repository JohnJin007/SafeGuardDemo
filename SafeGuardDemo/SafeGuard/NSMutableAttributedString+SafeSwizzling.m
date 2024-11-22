//
//  NSMutableAttributedString+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSMutableAttributedString+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSMutableAttributedString (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取NSConcreteMutableAttributedString的类对象
        Class concreteMutableAttributedStringClass = objc_getClass("NSConcreteMutableAttributedString");
        // 交换实例方法 initWithString:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(initWithString:) withSwizzleMethod:@selector(mksafe_initWithString:)];
        // 交换实例方法 initWithString:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(initWithString:attributes:) withSwizzleMethod:@selector(mksafe_initWithString:attributes:)];
        // 交换实例方法 addAttribute:value:range:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(addAttribute:value:range:) withSwizzleMethod:@selector(mksafe_addAttribute:value:range:)];
        // 交换实例方法 addAttributes:range:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(addAttributes:range:) withSwizzleMethod:@selector(mksafe_addAttributes:range:)];
        // 交换实例方法 removeAttribute:range:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(removeAttribute:range:) withSwizzleMethod:@selector(mksafe_removeAttribute:range:)];
        // 交换实例方法 setAttributes:range:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(setAttributes:range:) withSwizzleMethod:@selector(mksafe_setAttributes:range:)];
        // 交换实例方法 deleteCharactersInRange:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(deleteCharactersInRange:) withSwizzleMethod:@selector(mksafe_deleteCharactersInRange:)];
        // 交换实例方法 replaceCharactersInRange:withString:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(replaceCharactersInRange:withString:) withSwizzleMethod:@selector(mksafe_replaceCharactersInRange:withString:)];
        // 交换实例方法 replaceCharactersInRange:withAttributedString:
        [NSMutableAttributedString mk_swizzleInstanceMethodClass:concreteMutableAttributedStringClass withInstanceMethod:@selector(replaceCharactersInRange:withAttributedString:) withSwizzleMethod:@selector(mksafe_replaceCharactersInRange:withAttributedString:)];
    });
}

#pragma mark - Safe Methods

- (instancetype)mksafe_initWithString:(NSString *)str {
    if (str == nil) {
        NSLog(@"❌❌❌: Attempting to initialize NSMutableAttributedString with nil string in mksafe_initWithString:, defaulting to empty string.");
        str = @"";  // 使用空字符串以防止崩溃
    }
    return [self mksafe_initWithString:str];
}

- (instancetype)mksafe_initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    if (str == nil) {
        NSLog(@"❌❌❌: Attempting to initialize NSMutableAttributedString with nil string in mksafe_initWithString:attributes:, defaulting to empty string.");
        str = @"";  // 使用空字符串以防止崩溃
    }
    return [self mksafe_initWithString:str attributes:attrs];
}

- (void)mksafe_addAttribute:(NSAttributedStringKey)name value:(id)value range:(NSRange)range {
    if (name == nil || value == nil) {
        NSLog(@"❌❌❌: Attempted to add nil attribute or value in mksafe_addAttribute:value:range:");
        return;
    }
    
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_addAttribute:value:range: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 调整范围，避免越界崩溃
        range = NSMakeRange(range.location, self.length - range.location);
    }
    [self mksafe_addAttribute:name value:value range:range];
}

- (void)mksafe_addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_addAttributes:range: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 调整范围，避免越界崩溃
        range = NSMakeRange(range.location, self.length - range.location);
    }
    [self mksafe_addAttributes:attrs range:range];
}

- (void)mksafe_removeAttribute:(NSAttributedStringKey)name range:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_removeAttribute:range: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 调整范围，避免越界崩溃
        range = NSMakeRange(range.location, self.length - range.location);
    }
    [self mksafe_removeAttribute:name range:range];
}

- (void)mksafe_setAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes range:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_setAttributes:range: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 调整范围，避免越界崩溃
        range = NSMakeRange(range.location, self.length - range.location);
    }
    [self mksafe_setAttributes:attributes range:range];
}

- (void)mksafe_deleteCharactersInRange:(NSRange)range {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_deleteCharactersInRange: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 如果范围无效，不执行删除操作
        return;
    }
    [self mksafe_deleteCharactersInRange:range];
}

- (void)mksafe_replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_replaceCharactersInRange:withString: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        // 如果范围无效，不执行替换操作
        return;
    }
    [self mksafe_replaceCharactersInRange:range withString:str];
}

- (void)mksafe_replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrStr {
    if (NSMaxRange(range) > self.length) {
        NSLog(@"❌❌❌: Range {%lu, %lu} out of bounds in mksafe_replaceCharactersInRange:withAttributedString: with mutable attributed string length %lu", (unsigned long)range.location, (unsigned long)range.length, (unsigned long)self.length);
        
        return;
    }
    [self mksafe_replaceCharactersInRange:range withAttributedString:attrStr];
}

@end

//
//  NSMutableDictionary+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSMutableDictionary+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSMutableDictionary (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取__NSDictionaryM的类对象(可变字典)
        Class mutableDictionaryClass = objc_getClass("__NSDictionaryM");
        // 交换实例方法 setObject:forKey:
        [NSMutableDictionary mk_swizzleInstanceMethodClass:mutableDictionaryClass withInstanceMethod:@selector(setObject:forKey:) withSwizzleMethod:@selector(mksafe_setObject:forKey:)];
        // 交换实例方法 setObject:forKeyedSubscript:
        [NSMutableDictionary mk_swizzleInstanceMethodClass:mutableDictionaryClass withInstanceMethod:@selector(setObject:forKeyedSubscript:) withSwizzleMethod:@selector(mksafe_setObject:forKeyedSubscript:)];
        // 交换实例方法 removeObjectForKey:
        [NSMutableDictionary mk_swizzleInstanceMethodClass:mutableDictionaryClass withInstanceMethod:@selector(removeObjectForKey:) withSwizzleMethod:@selector(mksafe_removeObjectForKey:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_setObject:(id)object forKey:(id<NSCopying>)key {
    if (!object) {
        NSLog(@"❌❌❌: Attempted to set nil object for key: %@", key);
        return;
    }
    if (!key) {
        NSLog(@"❌❌❌: Attempted to set object for nil key");
        return;
    }
    // 调用原始 setObject:forKey: 方法（通过方法交换）
    [self mksafe_setObject:object forKey:key];
}

- (void)mksafe_setObject:(id)object forKeyedSubscript:(id<NSCopying>)key {
    if (key) {
        // 调用原始 setObject:forKeyedSubscript: 方法（通过方法交换）
        [self mksafe_setObject:object forKeyedSubscript:key];
    }else {
        NSLog(@"❌❌❌: Attempted to set object:%@ for key:%@",object,key);
    }
}

- (void)mksafe_removeObjectForKey:(id)key {
    if (!key) {
        NSLog(@"❌❌❌: Attempted to remove object for nil key");
        return;
    }
    // 调用原始 removeObjectForKey: 方法（通过方法交换）
    [self mksafe_removeObjectForKey:key];
}

@end

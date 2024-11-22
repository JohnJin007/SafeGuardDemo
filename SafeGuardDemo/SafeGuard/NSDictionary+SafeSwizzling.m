//
//  NSDictionary+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/12.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSDictionary+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSDictionary (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换类方法 dictionaryWithObject:forKey:
        [NSDictionary mk_swizzleClassMethod:@selector(dictionaryWithObject:forKey:) withSwizzleMethod:@selector(mksafe_dictionaryWithObject:forKey:)];
        // 交换类方法 dictionaryWithObjects:forKeys:count:
        [NSDictionary mk_swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:) withSwizzleMethod:@selector(mksafe_dictionaryWithObjects:forKeys:count:)];
        
        // 获取__NSPlaceholderDictionary的类对象(占位字典)
        Class placeholderDictionaryClass = objc_getClass("__NSPlaceholderDictionary");
        // 交换实例方法 initWithObjects:forKeys:count:
        [NSDictionary mk_swizzleInstanceMethodClass:placeholderDictionaryClass withInstanceMethod:@selector(initWithObjects:forKeys:count:) withSwizzleMethod:@selector(mksafe_initWithObjects:forKeys:count:)];
    });
}

#pragma mark - Safe Methods

+ (instancetype)mksafe_dictionaryWithObject:(id)object forKey:(id<NSCopying>)key {
    if (!object) {
        NSLog(@"❌❌❌: Attempted to insert nil object for key %@", key);
        return nil;
    }
    if (!key) {
        NSLog(@"❌❌❌: Attempted to insert object for nil key");
        return nil;
    }
    return [self mksafe_dictionaryWithObject:object forKey:key];
}

+ (instancetype)mksafe_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id<NSCopying> safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id object = objects[i];
        if (key && object) {
            safeKeys[j] = key;
            safeObjects[j] = object;
            j++;
        } else {
            if (!key) {
                NSLog(@"❌❌❌: Attempted to insert nil key at index %lu. Skipping.", (unsigned long)i);
            }
            if (!object) {
                NSLog(@"❌❌❌: Attempted to insert nil object for key %@ at index %lu. Skipping.", key, (unsigned long)i);
            }
        }
    }
    
    return [self mksafe_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)mksafe_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects
                              forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys
                                count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id<NSCopying> safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id object = objects[i];
        if (key && object) {
            safeKeys[j] = key;
            safeObjects[j] = object;
            j++;
        } else {
            if (!key) {
                NSLog(@"❌❌❌: Attempted to insert nil key at index %lu. Skipping.", (unsigned long)i);
            }
            if (!object) {
                NSLog(@"❌❌❌: Attempted to insert nil object for key %@ at index %lu. Skipping.", key, (unsigned long)i);
            }
        }
    }
    
    // 调用原始的 initWithObjects:forKeys:count: 方法
    return [self mksafe_initWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

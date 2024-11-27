//
//  NSObject+KVCCrash.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/27.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSObject+KVCCrash.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSObject (KVCCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取NSObject的类对象
        Class objectKVCClass = objc_getClass("NSObject");
        // 交换实例方法 setValue:forKey:
        [NSObject mk_swizzleInstanceMethodClass:objectKVCClass withInstanceMethod:@selector(setValue:forKey:) withSwizzleMethod:@selector(mksafe_setValue:forKey:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_setValue:(id)value forKey:(NSString *)key {
    if (key == nil) {
        NSString *crashMessages = [NSString stringWithFormat:@"KVC Crash: [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
        NSLog(@"❌❌❌: %@", crashMessages);
        return;
    }

    [self mksafe_setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"KVC Crash : [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
    NSLog(@"❌❌❌: %@", crashMessages);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"KVC Crash : [<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key: %@,value:%@'",NSStringFromClass([self class]),self,key,value];
    NSLog(@"❌❌❌: %@", crashMessages);
}

- (nullable id)valueForUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"KVC Crash :[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@",NSStringFromClass([self class]),self,key];
    NSLog(@"❌❌❌: %@", crashMessages);
    
    return self;
}

@end

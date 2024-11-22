//
//  NSMutableSet+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/13.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSMutableSet+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSMutableSet (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取__NSSetM的类对象(可变集合)
        Class mutableSetClass = objc_getClass("__NSSetM");
        //交换实例方法 addObject:
        [NSMutableSet mk_swizzleInstanceMethodClass:mutableSetClass withInstanceMethod:@selector(addObject:) withSwizzleMethod:@selector(mksafe_addObject:)];
        //交换实例方法 removeObject:
        [NSMutableSet mk_swizzleInstanceMethodClass:mutableSetClass withInstanceMethod:@selector(removeObject:) withSwizzleMethod:@selector(mksafe_removeObject:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_addObject:(id)object {
    if (object == nil) {
        NSLog(@"❌❌❌: Attempted to add nil object to NSMutableSet in mksafe_addObject:");
        return; // 忽略添加操作
    }
    [self mksafe_addObject:object];
}

- (void)mksafe_removeObject:(id)object {
    if (object == nil) {
        NSLog(@"❌❌❌: Attempted to remove nil object from NSMutableSet in mksafe_removeObject:");
        return; // 忽略删除操作
    }
    [self mksafe_removeObject:object];
}

@end

//
//  NSSet+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/13.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSSet+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSSet (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换类方法 setWithObject:
        [NSSet mk_swizzleClassMethod:@selector(setWithObject:) withSwizzleMethod:@selector(mksafe_setWithObject:)];
        
        // 获取__NSPlaceholderSet的类对象(占位集合)
        Class placeholdeSetClass = objc_getClass("__NSPlaceholderSet");
        // 交换实例方法 initWithObjects:
        [NSSet mk_swizzleInstanceMethodClass:placeholdeSetClass withInstanceMethod:@selector(initWithObjects:count:) withSwizzleMethod:@selector(mksafe_initWithObjects:count:)];
    });
}

#pragma mark - Safe Methods

+ (instancetype)mksafe_setWithObject:(id)object{
    if (object == nil){
        NSLog(@"❌❌❌: NSSet mksafe_setWithObject nil object");
        return nil;
    }
    return [self mksafe_setWithObject:object];
}

- (instancetype)mksafe_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    NSUInteger validCount = 0;
    id __unsafe_unretained validObjects[cnt];
    
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i] != nil) {
            validObjects[validCount] = objects[i];
            validCount++;
        } else {
            NSLog(@"❌❌❌: Attempted to add nil object to NSSet in mksafe_initWithObjects:count:");
        }
    }
    return [self mksafe_initWithObjects:validObjects count:validCount];
}

@end

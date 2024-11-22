//
//  NSMutableArray+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/11.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSMutableArray+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSMutableArray (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取__NSArrayM的类对象(可变数组)
        Class mutableArrayClass = objc_getClass("__NSArrayM");
        // 交换实例方法 addObject:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(addObject:) withSwizzleMethod:@selector(mksafe_addObject:)];
        // 交换实例方法 objectAtIndex:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(objectAtIndex:) withSwizzleMethod:@selector(mksafe_objectAtIndex:)];
        // 交换实例方法 objectAtIndexedSubscript:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(objectAtIndexedSubscript:) withSwizzleMethod:@selector(mksafe_objectAtIndexedSubscript:)];
        // 交换实例方法 insertObject:atIndex:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(insertObject:atIndex:) withSwizzleMethod:@selector(mksafe_insertObject:atIndex:)];
        // 交换实例方法 removeObjectAtIndex:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(removeObjectAtIndex:) withSwizzleMethod:@selector(mksafe_removeObjectAtIndex:)];
        // 交换实例方法 replaceObjectAtIndex:withObject:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withSwizzleMethod:@selector(mksafe_replaceObjectAtIndex:withObject:)];
        // 交换实例方法 removeObjectsInRange:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(removeObjectsInRange:) withSwizzleMethod:@selector(mksafe_removeObjectsInRange:)];
        // 交换实例方法 setObject:atIndexedSubscript:
        [NSMutableArray mk_swizzleInstanceMethodClass:mutableArrayClass withInstanceMethod:@selector(setObject:atIndexedSubscript:) withSwizzleMethod:@selector(mksafe_setObject:atIndexedSubscript:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_addObject:(id)object {
    if (object == nil) {
        NSLog(@"❌❌❌: Attempted to add nil object to __NSArrayM array");
    } else {
        // 调用原始 addObject: 方法（通过方法交换）
        [self mksafe_addObject:object];
    }
}

- (id)mksafe_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        // 调用原始 objectAtIndex: 方法（通过方法交换）
        return [self mksafe_objectAtIndex:index];
    } else {
        NSLog(@"❌❌❌: Index %lu out of bounds for __NSArrayM array of count %lu", (unsigned long)index, (unsigned long)self.count);
        return nil; // 返回 nil 或者其他默认值
    }
}

- (id)mksafe_objectAtIndexedSubscript:(NSUInteger)idx {
    // 检查下标是否越界
    if (idx < self.count) {
        // 调用原始的 objectAtIndexedSubscript: 方法（通过方法交换）
        return [self mksafe_objectAtIndexedSubscript:idx];
    } else {
        NSLog(@"❌❌❌: Idx %lu out of bounds for __NSArrayM array of count %lu", (unsigned long)idx, (unsigned long)self.count);
        return nil; // 返回 nil 或默认值
    }
}

- (void)mksafe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject == nil) {
        NSLog(@"❌❌❌: Attempted to insert nil object at index %lu", (unsigned long)index);
    } else if (index > self.count) {
        NSLog(@"❌❌❌: Attempted to insert object at an invalid index %lu, array count is %lu", (unsigned long)index, (unsigned long)self.count);
    } else {
        // 调用原始 insertObject:atIndex: 方法（通过方法交换）
        [self mksafe_insertObject:anObject atIndex:index];
    }
}

- (void)mksafe_removeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        NSLog(@"❌❌❌: Attempted to remove object at invalid index %lu, array count is %lu", (unsigned long)index, (unsigned long)self.count);
    } else {
        // 调用原始 removeObjectAtIndex: 方法（通过方法交换）
        [self mksafe_removeObjectAtIndex:index];
    }
}

- (void)mksafe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (anObject == nil) {
        NSLog(@"❌❌❌: Attempted to replace object with nil at index %lu", (unsigned long)index);
    } else if (index >= self.count) {
        NSLog(@"❌❌❌: Attempted to replace object at invalid index %lu, array count is %lu", (unsigned long)index, (unsigned long)self.count);
    } else {
        // 调用原始 replaceObjectAtIndex:withObject: 方法（通过方法交换）
        [self mksafe_replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)mksafe_removeObjectsInRange:(NSRange)range {
    if (range.location + range.length > self.count) {
        NSLog(@"❌❌❌: Attempted to remove objects in invalid range %@, array count is %lu", NSStringFromRange(range), (unsigned long)self.count);
    } else {
        // 调用原始 removeObjectsInRange: 方法（通过方法交换）
        [self mksafe_removeObjectsInRange:range];
    }
}

- (void)mksafe_setObject:(id)object atIndexedSubscript:(NSUInteger)index {
    if (index <= self.count && object) {
        // 调用原始 setObject:atIndexedSubscript: 方法（通过方法交换）
        [self mksafe_setObject:object atIndexedSubscript:index];
    }else {
        NSLog(@"❌❌❌:Attempted to set object:%@ at index %lu, array count is %lu", object,(unsigned long)index, (unsigned long)self.count);
    }
}

@end

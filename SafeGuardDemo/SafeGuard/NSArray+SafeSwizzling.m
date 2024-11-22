//
//  NSArray+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/11.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSArray+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSArray (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换类方法 arrayWithObject:
        [NSArray mk_swizzleClassMethod:@selector(arrayWithObject:) withSwizzleMethod:@selector(mksafe_arrayWithObject:)];
        // 交换类方法 arrayWithObjects:count:
        [NSArray mk_swizzleClassMethod:@selector(arrayWithObjects:count:) withSwizzleMethod:@selector(mksafe_arrayWithObjects:count:)];
        
        // 获取__NSPlaceholderArray的类对象(占位数组)
        Class placeholderArrayClass = objc_getClass("__NSPlaceholderArray");
        // 交换实例方法 initWithObjects:count:
        [NSArray mk_swizzleInstanceMethodClass:placeholderArrayClass withInstanceMethod:@selector(initWithObjects:count:) withSwizzleMethod:@selector(mksafe_initWithObjects:count:)];
        
        // 获取__NSArray0的类对象(空数组)
        Class emptyArrayClass = objc_getClass("__NSArray0");
        // 交换实例方法 objectAtIndex:
        [NSArray mk_swizzleInstanceMethodClass:emptyArrayClass withInstanceMethod:@selector(objectAtIndex:) withSwizzleMethod:@selector(mksafe_empty_objectAtIndex:)];
        // 交换实例方法 objectAtIndexedSubscript:
        [NSArray mk_swizzleInstanceMethodClass:emptyArrayClass withInstanceMethod:@selector(objectAtIndexedSubscript:) withSwizzleMethod:@selector(mksafe_empty_objectAtIndexedSubscript:)];
        
        // 获取__NSSingleObjectArrayI的类对象(只有一个对象的数组)
        Class singleObjectArrayClass = objc_getClass("__NSSingleObjectArrayI");
        // 交换实例方法 objectAtIndex:
        [NSArray mk_swizzleInstanceMethodClass:singleObjectArrayClass withInstanceMethod:@selector(objectAtIndex:) withSwizzleMethod:@selector(mksafe_single_objectAtIndex:)];
        // 交换实例方法 objectAtIndexedSubscript:
        [NSArray mk_swizzleInstanceMethodClass:singleObjectArrayClass withInstanceMethod:@selector(objectAtIndexedSubscript:) withSwizzleMethod:@selector(mksafe_single_objectAtIndexedSubscript:)];
        
        // 获取__NSArrayI的类对象(不可变数组)
        Class immutableArrayClass = objc_getClass("__NSArrayI");
        // 交换实例方法 objectAtIndex:
        [NSArray mk_swizzleInstanceMethodClass:immutableArrayClass withInstanceMethod:@selector(objectAtIndex:) withSwizzleMethod:@selector(mksafe_objectAtIndex:)];
        // 交换实例方法 objectAtIndexedSubscript:
        [NSArray mk_swizzleInstanceMethodClass:immutableArrayClass withInstanceMethod:@selector(objectAtIndexedSubscript:) withSwizzleMethod:@selector(mksafe_objectAtIndexedSubscript:)];
        // 交换实例方法 subarrayWithRange:
        [NSArray mk_swizzleInstanceMethodClass:immutableArrayClass withInstanceMethod:@selector(subarrayWithRange:) withSwizzleMethod:@selector(mksafe_subarrayWithRange:)];
    });
}

#pragma mark - Safe Methods

+ (instancetype)mksafe_arrayWithObject:(id)object {
    if (object == nil) {
        NSLog(@"❌❌❌: Attempted to create NSArray with nil object. Returning nil.");
        return nil;
    }
    return [self mksafe_arrayWithObject:object];
}

+ (instancetype)mksafe_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt {
    id validObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i]) {
            validObjects[j] = objects[i];
            j++;
        } else {
            NSLog(@"❌❌❌: Attempted to initialize NSArray(mksafe_arrayWithObjects:count:) with nil object at index %lu",(unsigned long)i);
        }
    }
    return [self mksafe_arrayWithObjects:validObjects count:j];
}

- (instancetype)mksafe_initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    id validObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i]) {
            validObjects[j] = objects[i];
            j++;
        } else {
            NSLog(@"❌❌❌: Attempted to initialize NSArray(mksafe_initWithObjects:count:) with nil object at index %lu",(unsigned long)i);
        }
    }
    
    // 调用原始的 initWithObjects:count: 实现
    return [self mksafe_initWithObjects:validObjects count:j];
}

- (id)mksafe_empty_objectAtIndex:(NSUInteger)index {
    // 检查数组是否为空并避免越界访问
    if (self.count == 0) {
        NSLog(@"❌❌❌: Attempted to access index %lu in an empty NSArray (__NSArray0).", (unsigned long)index);
        return nil; // 返回 nil，避免崩溃
    }
    
    // 调用原始的 objectAtIndex: 方法
    return [self mksafe_empty_objectAtIndex:index];
}

- (id)mksafe_empty_objectAtIndexedSubscript:(NSUInteger)idx {
    // 检查下标是否越界
    if (idx < self.count) {
        // 调用原始的 objectAtIndexedSubscript: 方法（通过方法交换）
        return [self mksafe_empty_objectAtIndexedSubscript:idx];
    } else {
        NSLog(@"❌❌❌: Idx %lu out of bounds for  NSArray (__NSArray0) of count %lu", (unsigned long)idx, (unsigned long)self.count);
        return nil; // 返回 nil 或默认值
    }
}

- (id)mksafe_single_objectAtIndex:(NSUInteger)index {
    // 检查索引是否有效，防止越界访问
    if (index >= self.count) {
        NSLog(@"❌❌❌: Attempted to access index %lu in a single-object NSArray (__NSSingleObjectArrayI) with count %lu.", (unsigned long)index, (unsigned long)self.count);
        return nil; // 返回 nil，避免崩溃
    }
    
    // 调用原始的 objectAtIndex: 方法
    return [self mksafe_single_objectAtIndex:index];
}

- (id)mksafe_single_objectAtIndexedSubscript:(NSUInteger)idx {
    // 检查下标是否越界
    if (idx < self.count) {
        // 调用原始的 objectAtIndexedSubscript: 方法（通过方法交换）
        return [self mksafe_single_objectAtIndexedSubscript:idx];
    } else {
        NSLog(@"❌❌❌: Idx %lu out of bounds for NSArray (__NSSingleObjectArrayI) of count %lu", (unsigned long)idx, (unsigned long)self.count);
        return nil; // 返回 nil 或默认值
    }
}

- (id)mksafe_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self mksafe_objectAtIndex:index];
    } else {
        NSLog(@"❌❌❌: Array index %lu is out of bounds. Returning nil.", (unsigned long)index);
        return nil;
    }
}

- (id)mksafe_objectAtIndexedSubscript:(NSUInteger)idx {
    // 检查下标是否越界
    if (idx < self.count) {
        // 调用原始的 objectAtIndexedSubscript: 方法（通过方法交换）
        return [self mksafe_objectAtIndexedSubscript:idx];
    } else {
        NSLog(@"❌❌❌: Idx %lu out of bounds for NSArray (__NSArrayI) of count %lu", (unsigned long)idx, (unsigned long)self.count);
        return nil; // 返回 nil 或默认值
    }
}

- (NSArray *)mksafe_subarrayWithRange:(NSRange)range {
    // 检查 range 是否越界
    if (range.location + range.length <= self.count) {
        // 如果范围有效，调用原始的 subarrayWithRange:
        return [self mksafe_subarrayWithRange:range];
    } else if(range.location < self.count){
        // 返回一个安全范围的子数组
        NSRange safeRange = NSMakeRange(range.location, self.count - range.location);
        // 如果范围无效，打印警告并返回一个安全的子数组
        NSLog(@"❌❌❌: Attempted to access subarray with out-of-bounds range %@. Returning available subarray range %@.", NSStringFromRange(range),NSStringFromRange(safeRange));
        return [self mksafe_subarrayWithRange:safeRange];
    }else {
        NSLog(@"❌❌❌: Attempted to access subarray with out-of-bounds range %@. Returning nil.", NSStringFromRange(range));
        return nil;
    }
}

@end

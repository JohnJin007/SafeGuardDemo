//
//  NSObject+SafeSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/14.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSObject+SafeSwizzling.h"
#import "NSObject+SafeMethodSwizzling.h"

@implementation NSObject (SafeSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换类方法 methodSignatureForSelector:
        [NSObject mk_swizzleClassMethod:@selector(methodSignatureForSelector:) withSwizzleMethod:@selector(mksafe_classMethodSignatureForSelector:)];
        // 交换类方法 forwardInvocation:
        [NSObject mk_swizzleClassMethod:@selector(forwardInvocation:) withSwizzleMethod:@selector(mksafe_classForwardInvocation:)];
        
        // 获取NSObject的类对象
        Class objectClass = objc_getClass("NSObject");
        // 交换实例方法 methodSignatureForSelector:
        [NSObject mk_swizzleInstanceMethodClass:objectClass withInstanceMethod:@selector(methodSignatureForSelector:) withSwizzleMethod:@selector(mksafe_instanceMethodSignatureForSelector:)];
        // 交换实例方法 forwardInvocation:
        [NSObject mk_swizzleInstanceMethodClass:objectClass withInstanceMethod:@selector(forwardInvocation:) withSwizzleMethod:@selector(mksafe_instanceForwardInvocation:)];
    });
}

#pragma mark - Safe Methods

+ (NSMethodSignature *)checkObjectSignatureAndCurrentClass:(Class)currentClass{
    IMP originIMP = class_getMethodImplementation([NSObject class], @selector(methodSignatureForSelector:));
    IMP currentClassIMP = class_getMethodImplementation(currentClass, @selector(methodSignatureForSelector:));
    
    // If current class override methodSignatureForSelector return nil
    if (originIMP != currentClassIMP){
        return nil;
    }
    
    // Customer method signature
    // void xxx(id,sel,id)
    return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}

+ (NSMethodSignature*)mksafe_classMethodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature* methodSignature = [self mksafe_classMethodSignatureForSelector:aSelector];
    if (methodSignature) {
        return methodSignature;
    }
    
    return [self.class checkObjectSignatureAndCurrentClass:self.class];
}

+ (void)mksafe_classForwardInvocation:(NSInvocation*)invocation{
    SEL selector = [invocation selector];
    NSLog(@"❌❌❌: Static class %@ does not implement selector %@", NSStringFromClass(self.class), NSStringFromSelector(selector));
}

- (NSMethodSignature*)mksafe_instanceMethodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature* methodSignature = [self mksafe_instanceMethodSignatureForSelector:aSelector];
    if (methodSignature) {
        return methodSignature;
    }
    
    return [self.class checkObjectSignatureAndCurrentClass:self.class];
}

- (void)mksafe_instanceForwardInvocation:(NSInvocation*)invocation{
    SEL selector = [invocation selector];
    NSLog(@"❌❌❌: Instance class %@ does not implement selector %@", NSStringFromClass(self.class), NSStringFromSelector(selector));
}

@end

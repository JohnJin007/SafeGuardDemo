//
//  NSObject+SafeMethodSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/19.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSObject+SafeMethodSwizzling.h"

void swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector) {
    if (!cls) {
        return;
    }
    
    Method originalMethod = class_getClassMethod(cls, originSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzleSelector);
    
    //由于类方法的实现在元类中,因此需要获取元类
    //如果 self 是一个实例对象,object_getClass((id)self) 会返回它的“类”--也就是实例所属的类对象
    //如果 self 是一个类对象,object_getClass((id)self) 会返回它的“元类”
    Class metacls = object_getClass((id)cls);
    // 方法交换
    BOOL didAddMethod = class_addMethod(metacls,
                                        originSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(metacls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector) {
    if (!cls) {
        return;
    }
    
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    // 方法交换
    BOOL didAddMethod = class_addMethod(cls,
                                        originSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSObject (SafeMethodSwizzling)

+ (void)mk_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector {
    //self.class,[self class],self在类方法中都表示类对象
    swizzleClassMethod(self.class, originSelector, swizzleSelector);
}

+ (void)mk_swizzleInstanceMethodClass:(Class)class withInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector {
    swizzleInstanceMethod(class, originSelector, swizzleSelector);
}

@end

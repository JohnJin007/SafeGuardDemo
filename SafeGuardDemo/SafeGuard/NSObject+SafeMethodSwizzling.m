//
//  NSObject+SafeMethodSwizzling.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/19.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSObject+SafeMethodSwizzling.h"

static const char mkSwizzledDeallocKey;

// a class doesn't need dealloc swizzled if it or a superclass has been swizzled already
BOOL mk_requiresDeallocSwizzle(Class class)
{
    BOOL swizzled = NO;
    for ( Class currentClass = class; !swizzled && currentClass != nil; currentClass = class_getSuperclass(currentClass) ) {
        swizzled = [objc_getAssociatedObject(currentClass, &mkSwizzledDeallocKey) boolValue];
    }
    return !swizzled;
}

void mk_swizzleDeallocIfNeeded(Class class)
{
    static SEL deallocSEL = NULL;
    static SEL cleanupSEL = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deallocSEL = sel_getUid("dealloc");
        cleanupSEL = sel_getUid("mk_cleanKVO");
    });
    
    @synchronized (class) {
        if (!mk_requiresDeallocSwizzle(class)) {
            return;
        }
        
        objc_setAssociatedObject(class, &mkSwizzledDeallocKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    Method dealloc = NULL;
    
    unsigned int count = 0;
    Method* method = class_copyMethodList(class, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(method[i]) == deallocSEL) {
            dealloc = method[i];
            break;
        }
    }
    
    if ( dealloc == NULL ) {
        Class superclass = class_getSuperclass(class);
        
        class_addMethod(class, deallocSEL, imp_implementationWithBlock(^(__unsafe_unretained id self) {
            
            ((void(*)(id, SEL))objc_msgSend)(self, cleanupSEL);
            
            struct objc_super superStruct = (struct objc_super){ self, superclass };
            ((void (*)(struct objc_super*, SEL))objc_msgSendSuper)(&superStruct, deallocSEL);
            
        }), method_getTypeEncoding(dealloc));
    }else{
        __block IMP deallocIMP = method_setImplementation(dealloc, imp_implementationWithBlock(^(__unsafe_unretained id self) {
            ((void(*)(id, SEL))objc_msgSend)(self, cleanupSEL);
            
            ((void(*)(id, SEL))deallocIMP)(self, deallocSEL);
        }));
    }
}

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

//
//  NSObject+SafeMethodSwizzling.h
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/19.
//  Copyright © 2024 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SafeMethodSwizzling)

/**
 Swizzle Class Method

 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
+ (void)mk_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

/**
 Swizzle Instance Method
 @param cls Class
 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
+ (void)mk_swizzleInstanceMethodClass:(Class)class withInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

@end

NS_ASSUME_NONNULL_END

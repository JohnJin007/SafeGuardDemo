//
//  NSObject+KVOCrash.m
//  QQMobileToken
//
//  Created by v_jinlilili on 2024/11/26.
//  Copyright © 2024 tencent. All rights reserved.
//

#import "NSObject+KVOCrash.h"
#import "NSObject+SafeMethodSwizzling.h"

static const char DeallocMKKVOKey;

@interface MKKVOObjectItem : NSObject

// KVO observer
@property (nonatomic, assign) NSObject* observer;
// KVO which object
@property (nonatomic, assign) NSObject* whichObject;

@property (nonatomic, copy) NSString* keyPath;

@property (nonatomic, assign) NSKeyValueObservingOptions options;

@property (nonatomic, assign) void* context;

@end

@implementation MKKVOObjectItem

- (BOOL)isEqual:(MKKVOObjectItem*)object {
    if (!self.observer || !self.whichObject || !self.keyPath
        || !object.observer || !object.whichObject || !object.keyPath) {
        return NO;
    }
    if ([self.observer isEqual:object.observer] && [self.whichObject isEqual:object.whichObject] && [self.keyPath isEqualToString:object.keyPath]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.observer hash] ^ [self.whichObject hash] ^ [self.keyPath hash];
}

- (void)dealloc {
    self.observer = nil;
    self.whichObject = nil;
    self.context = nil;
    if (self.keyPath) {
        [self.keyPath release];
    }
    [super dealloc];
}

@end

@interface MKKVOObjectContainer : NSObject

// KVO object array set
@property (nonatomic, retain) NSMutableSet* kvoObjectSet;
// NSMutableSet safe-thread
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, retain) dispatch_semaphore_t kvoLock;
#else
@property (nonatomic, assign) dispatch_semaphore_t kvoLock;
#endif

- (void)checkAddKVOItemExist:(MKKVOObjectItem*)item existResult:(void (^)(void))existResult;

- (void)lockObjectSet:(void (^)(NSMutableSet *kvoObjectSet))objectSet;
// Clean the kvo info and set the item property nil,break the reference
- (void)cleanKVOData;

@end

@implementation MKKVOObjectContainer

#pragma mark - Public Method

- (void)checkAddKVOItemExist:(MKKVOObjectItem*)item existResult:(void (^)(void))existResult {
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    if (!item) {
        dispatch_semaphore_signal(self.kvoLock);
        return;
    }
    BOOL exist = [self.kvoObjectSet containsObject:item];
    if (!exist) {
        if (existResult) {
            existResult();
        }
        [self.kvoObjectSet addObject:item];
    }
    dispatch_semaphore_signal(self.kvoLock);
}

- (void)lockObjectSet:(void (^)(NSMutableSet *kvoObjectSet))objectSet {
    if (objectSet) {
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        objectSet(self.kvoObjectSet);
        dispatch_semaphore_signal(self.kvoLock);
    }
}

- (void)cleanKVOData {
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    for (MKKVOObjectItem *item in self.kvoObjectSet) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if (item.observer) {
            @try {
                ((void(*)(id,SEL,id,NSString*))objc_msgSend)(item.whichObject,@selector(mksafe_removeObserver:forKeyPath:),item.observer,item.keyPath);
            }@catch (NSException *exception) {
            }
            item.observer = nil;
            item.whichObject = nil;
            item.keyPath = nil;
        }
        #pragma clang diagnostic pop
    }
    [self.kvoObjectSet removeAllObjects];
    dispatch_semaphore_signal(self.kvoLock);
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self.kvoObjectSet release];
    dispatch_release(self.kvoLock);
    [super dealloc];
}

#pragma mark - Setter

- (NSMutableSet*)kvoObjectSet{
    if(!_kvoObjectSet){
        _kvoObjectSet = [[NSMutableSet alloc] init];
    }
    return _kvoObjectSet;
}

- (dispatch_semaphore_t)kvoLock{
    if (!_kvoLock) {
        _kvoLock = dispatch_semaphore_create(1);
    }
    return _kvoLock;
}

@end

@implementation NSObject (KVOCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取NSObject的类对象
        Class objectKVOClass = objc_getClass("NSObject");
        // 交换实例方法 addObserver:forKeyPath:options:context:
        [NSObject mk_swizzleInstanceMethodClass:objectKVOClass withInstanceMethod:@selector(addObserver:forKeyPath:options:context:) withSwizzleMethod:@selector(mksafe_addObserver:forKeyPath:options:context:)];
        // 交换实例方法 removeObserver:forKeyPath:
        [NSObject mk_swizzleInstanceMethodClass:objectKVOClass withInstanceMethod:@selector(removeObserver:forKeyPath:) withSwizzleMethod:@selector(mksafe_removeObserver:forKeyPath:)];
        // 交换实例方法 removeObserver:forKeyPath:context:
        [NSObject mk_swizzleInstanceMethodClass:objectKVOClass withInstanceMethod:@selector(removeObserver:forKeyPath:context:) withSwizzleMethod:@selector(mksafe_removeObserver:forKeyPath:context:)];
        // 交换实例方法 observeValueForKeyPath:ofObject:change:context:
        [NSObject mk_swizzleInstanceMethodClass:objectKVOClass withInstanceMethod:@selector(observeValueForKeyPath:ofObject:change:context:) withSwizzleMethod:@selector(mksafe_observeValueForKeyPath:ofObject:change:context:)];
    });
}

#pragma mark - Safe Methods

- (void)mksafe_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if ([self ignoreKVOInstanceClass:observer]) {
        [self mksafe_addObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }
    
    if (!observer || keyPath.length == 0) {
        return;
    }
    
    MKKVOObjectContainer *objectContainer = objc_getAssociatedObject(self, &DeallocMKKVOKey);
    if (!objectContainer) {
        objectContainer = [MKKVOObjectContainer new];
        objc_setAssociatedObject(self, &DeallocMKKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN);
        [objectContainer release];
    }
    
    // Record the kvo relation info
    MKKVOObjectItem *item = [[MKKVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;
    item.whichObject = self;
    
    [objectContainer checkAddKVOItemExist:item existResult:^{
        [self mksafe_addObserver:observer forKeyPath:keyPath options:options context:context];
    }];
    
    MKKVOObjectContainer *observerContainer = objc_getAssociatedObject(observer, &DeallocMKKVOKey);
    if (!observerContainer) {
        observerContainer = [MKKVOObjectContainer new];
        objc_setAssociatedObject(observer, &DeallocMKKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
        [observerContainer release];
    }
    [observerContainer checkAddKVOItemExist:item existResult:nil];
    
    [item release];
    
    // clean the self and observer
    mk_swizzleDeallocIfNeeded(self.class);
    mk_swizzleDeallocIfNeeded(observer.class);
}

- (void)mksafe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([self ignoreKVOInstanceClass:observer]) {
        [self mksafe_removeObserver:observer forKeyPath:keyPath];
        return;
    }
    if (!observer) {
        return;
    }
    
    MKKVOObjectContainer *objectContainer = objc_getAssociatedObject(self, &DeallocMKKVOKey);
    if (!objectContainer) {
        return;
    }
    
    [objectContainer lockObjectSet:^(NSMutableSet *kvoObjectSet) {
        MKKVOObjectItem *targetItem = [[MKKVOObjectItem alloc]init];
        targetItem.observer = observer;
        targetItem.whichObject = self;
        targetItem.keyPath = keyPath;
        
        MKKVOObjectItem *resultItem = nil;
        NSSet *set = [kvoObjectSet copy];
        for (MKKVOObjectItem *item in set) {
            if ([item isEqual:targetItem]) {
                resultItem = item;
                break;
            }
        }
        if (resultItem) {
            @try {
                [self mksafe_removeObserver:observer forKeyPath:keyPath];
            } @catch (NSException *exception) {
            }
            
            //Clean the reference
            resultItem.observer = nil;
            resultItem.whichObject = nil;
            resultItem.keyPath = nil;
            [kvoObjectSet removeObject:resultItem];
        }
        
        [targetItem release];
        [set release];
    }];
}

- (void)mksafe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void*)context {
    if ([self ignoreKVOInstanceClass:observer]) {
        [self mksafe_removeObserver:observer forKeyPath:keyPath context:context];
        return;
    }
    [self removeObserver:observer forKeyPath:keyPath];
}

- (void)mksafe_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([self ignoreKVOInstanceClass:object]) {
        [self mksafe_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    @try {
        [self mksafe_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } @catch (NSException *exception) {
        NSLog(@"❌❌❌: KVO Crash%@", exception.description);
    }
}

#pragma mark - Private Methods

- (BOOL)ignoreKVOInstanceClass:(id)object{
    if (!object) {
        return NO;
    }
    //Ignore ReactiveCocoa
    if (object_getClass(object) == objc_getClass("RACKVOProxy")) {
        return YES;
    }
    //Ignore AMAP
    NSString* className = NSStringFromClass(object_getClass(object));
    if ([className hasPrefix:@"AMap"]) {
        return YES;
    }
    return NO;
}

// Hook the kvo object dealloc and to clean the kvo array
- (void)mk_cleanKVO {
    MKKVOObjectContainer *objectContainer = objc_getAssociatedObject(self, &DeallocMKKVOKey);
    if (objectContainer) {
        [objectContainer cleanKVOData];
    }
}

@end

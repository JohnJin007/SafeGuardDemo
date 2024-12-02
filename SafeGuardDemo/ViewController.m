//
//  ViewController.m
//  SafeGuardDemo
//
//  Created by v_jinlilili on 2024/11/22.
//

#import "ViewController.h"
#import "KVOCrashObject.h"
#import "KVCCrashObject.h"

@interface ViewController ()

@property (nonatomic, strong) KVOCrashObject *objc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //test
    [self testSafeGuard];
}

- (void)testSafeGuard {
    //NSArray
    NSArray *array = [NSArray arrayWithObject:nil]; // 不会崩溃，返回空数组并打印警告日志
    const id __unsafe_unretained objects[] = {@"A", nil, @"B", nil};
    NSArray *safeArray = [NSArray arrayWithObjects:objects count:4];
    NSLog(@"Safe Array: %@",safeArray);
    const id __unsafe_unretained objects1[] = {@"A", nil, @"B", nil};
    NSArray *safeArray1 = [[NSArray alloc]initWithObjects:objects1 count:4];
    NSLog(@"Safe Array1: %@",safeArray1);
    NSArray *emptyArray = [NSArray array];
    NSLog(@"emptyArray = %@",[emptyArray objectAtIndex:0]);
    NSLog(@"emptyArray: %@",emptyArray[0]);
    NSArray *singleArray = [NSArray arrayWithObjects:@"A", nil];
    NSLog(@"singleArray = %@",[singleArray objectAtIndex:1]);
    NSLog(@"singleArray: %@",singleArray[1]);
    NSArray *immutableArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    NSLog(@"immutableArray = %@",[immutableArray objectAtIndex:3]);
    NSLog(@"immutableArray: %@",immutableArray[3]);
    NSArray *array1 = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    NSArray *subarray = [array1 subarrayWithRange:NSMakeRange(1, 5)];
    
    //NSMutableArray
    NSMutableArray *mutableArray = [NSMutableArray array];
    [mutableArray addObject:nil];  // 输出: Attempted to add nil object to array
    NSMutableArray *mutableArray1 = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", nil];
    NSLog(@"object = %@",[mutableArray1 objectAtIndex:5]);//越界访问
    NSLog(@"object: %@",mutableArray1[5]);
    // 尝试插入 nil 对象
    [mutableArray1 insertObject:nil atIndex:1];
    // 尝试插入到无效索引（超出范围）
    [mutableArray1 insertObject:@"D" atIndex:5];
    // 正常插入
    [mutableArray1 insertObject:@"D" atIndex:2];
    NSLog(@"%@", mutableArray1);  // 输出: ["A", "B", "D", "C"]
    [mutableArray1 removeObjectAtIndex:5];
    // 尝试替换一个超出范围的索引
    [mutableArray1 replaceObjectAtIndex:5 withObject:@"D"];
    // 尝试替换为 nil 对象
    [mutableArray1 replaceObjectAtIndex:1 withObject:nil];
    // 尝试移除一个超出范围的范围
    [mutableArray1 removeObjectsInRange:NSMakeRange(1, 8)];
    // 尝试设置一个超出范围的索引
    mutableArray1[8] = @"D";
    // 尝试设置 nil 对象
    mutableArray1[1] = nil;
    
    //NSDictionary
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:nil forKey:@"Key1"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"A" forKey:nil];
    id dictObjects[] = { @"Value1", nil, @"Value3" };
    id<NSCopying> dictKeys[] = { @"Key1", @"Key2", @"Key3" };
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys count:3];
    NSLog(@"dict = %@",dict);
    NSDictionary *dict3 = [[NSDictionary alloc]initWithObjects:dictObjects forKeys:dictKeys count:3];
    
    //NSMutableDictionary
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setObject:nil forKey:@"Key2"];
    [mutableDict setObject:@"Value3" forKey:nil];
    mutableDict[@"Key4"] = nil;
    mutableDict[nil] = @"Value5";
    [mutableDict removeObjectForKey:nil];
    
    //NSString
    const char *nullCString = NULL;
    NSString *nullString = [NSString stringWithUTF8String:nullCString];
    NSLog(@"nullString: %@", nullString); // 应输出警告日志并返回 nil
    // 测试 NULL C 字符串
    NSString *nullString1 = [NSString stringWithCString:nullCString encoding:NSUTF8StringEncoding];
    NSLog(@"nullString1: %@", nullString1); // 应输出警告日志并返回 nil
    NSString *testString = @"Hello, World!";
    unichar character = [testString characterAtIndex:20]; // 超出范围，输出警告
    NSString *substring1 = [testString substringFromIndex:20]; // 超出范围，输出警告
    NSString *substring2 = [testString substringToIndex:20]; // 超出范围，输出警告
    NSLog(@"character: %C, substring1: %@, substring2: %@", character, substring1, substring2);
    NSString *substring = [testString substringWithRange:NSMakeRange(0, 20)]; // 超出范围，输出警告
    NSLog(@"substring: %@", substring); // 应输出警告并返回空字符串
    NSRange range = [testString rangeOfString:@"World" options:0 range:NSMakeRange(0, 20) locale:nil];
    NSLog(@"range: %@", NSStringFromRange(range)); // 应输出警告并返回 NSNotFound
    
    //NSMutableString
    NSMutableString *mutableStr = [NSMutableString stringWithString:@"Hello"];
    [mutableStr appendString:nil]; // 输出警告：Attempted to append nil string
    [mutableStr insertString:@"World" atIndex:10]; // 输出警告：Index out of bounds
    [mutableStr insertString:nil atIndex:2];       // 输出警告：Attempted to insert nil string
    [mutableStr deleteCharactersInRange:NSMakeRange(0, 20)]; // 输出警告：Range out of bounds
    [mutableStr replaceCharactersInRange:NSMakeRange(0, 20) withString:@"Hi"];
    [mutableStr replaceCharactersInRange:NSMakeRange(0, 2) withString:nil];
    NSMutableString *mutableString = [NSMutableString stringWithString:@"Hello, World!"];
    NSString *substring3 = [mutableString substringFromIndex:5];
    NSLog(@"Substring3 from index: %@", substring3);
    NSString *substring4 = [mutableString substringToIndex:20]; // 越界测试
    NSLog(@"Substring4 to index: %@", substring4);
    NSString *substring5 = [mutableString substringWithRange:NSMakeRange(7, 20)]; // 越界测试
    NSLog(@"Substring5 with range: %@", substring5);
    
    //NSAttributedString
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:nil];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"Hello, World!"];
    NSAttributedString *subStr = [attrStr1 attributedSubstringFromRange:NSMakeRange(0, 20)];
    NSLog(@"subStr: %@", subStr); // 输出警告日志并返回 nil
    // 测试索引超出字符串长度的情况
    NSRange effectiveRange;
    id attribute = [attrStr1 attribute:NSForegroundColorAttributeName atIndex:20 effectiveRange:&effectiveRange];
    NSLog(@"attribute: %@", attribute); // 输出警告日志并返回 nil
    // 测试范围超出字符串长度的情况
    [attrStr1 enumerateAttribute:NSForegroundColorAttributeName
                        inRange:NSMakeRange(0, 20)
                        options:0
                     usingBlock:^(id value, NSRange range, BOOL *stop) {
                         NSLog(@"Attribute1: %@, Range1: %@", value, NSStringFromRange(range));
                     }]; // 输出警告日志并自动调整范围
    // 测试范围超出字符串长度的情况
    [attrStr1 enumerateAttributesInRange:NSMakeRange(0, 20)
                                options:0
                             usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop) {
                                 NSLog(@"Attributes2: %@, Range2: %@", attrs, NSStringFromRange(range));
                             }]; // 输出警告日志并自动调整范围
    
    //NSMutableAttributedString
    NSMutableAttributedString *mutableAttrStr1 = [[NSMutableAttributedString alloc] initWithString:nil];
    NSLog(@"%@", mutableAttrStr1);
    NSMutableAttributedString *mutableAttrStr2 = [[NSMutableAttributedString alloc] initWithString:nil attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
    NSLog(@"%@", mutableAttrStr2);
    NSMutableAttributedString *mutableAttrStr = [[NSMutableAttributedString alloc] initWithString:@"Hello, World!"];
    [mutableAttrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 20)];
    [mutableAttrStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]} range:NSMakeRange(0, 20)];
    [mutableAttrStr removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, 20)];
    [mutableAttrStr setAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]}
                            range:NSMakeRange(0, 20)];
    [mutableAttrStr deleteCharactersInRange:NSMakeRange(0, 20)]; // 输出警告日志，并且不进行删除操作
    [mutableAttrStr replaceCharactersInRange:NSMakeRange(0, 20) withString:@"Goodbye"];
    NSAttributedString *replacementAttrStr = [[NSAttributedString alloc] initWithString:@"Goodbye"];
    [mutableAttrStr replaceCharactersInRange:NSMakeRange(0, 20) withAttributedString:replacementAttrStr];
    [mutableAttrStr replaceCharactersInRange:NSMakeRange(0, 5) withAttributedString:replacementAttrStr]; // 替换成功，结果为 "Goodbye, World!"
    NSLog(@"%@", mutableAttrStr); // 输出: "Goodbye, World!"
    
    //NSSet
    NSSet *set = [NSSet setWithObject:nil];
    const id __unsafe_unretained setObjects[] = {@"1", @"2", nil, @"3", nil};
    NSSet *set1 = [[NSSet alloc] initWithObjects:setObjects count:5];
    NSLog(@"%@", set1); // 输出: "{1, 2, 3}"
    
    //NSMutableSet
    NSMutableSet *mutableSet = [NSMutableSet set];
    [mutableSet addObject:nil]; // 输出警告，不会崩溃
    NSLog(@"%@", mutableSet); // 输出: "{}" 表示空集合
    [mutableSet removeObject:nil]; // 输出警告，不会崩溃
    NSLog(@"%@", mutableSet); // 输出: "{}" 表示空集合
    
    //NSObject
    [NSObject performSelector:@selector(classMethod)];
    NSObject *object1 = [[NSObject alloc]init];
    [object1 performSelector:@selector(instanceMethod:)];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //KVO Test
    //    1.1 移除了未注册的观察者，导致崩溃
         [self testKVOCrash11];

    //    1.2 重复移除多次，移除次数多于添加次数，导致崩溃
    //    [self testKVOCrash12];

    //    1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
    //    [self testKVOCrash13];

    //    2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
    //    [self testKVOCrash2];

    //    3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
    //    [self testKVOCrash3];
        
    //    4. 添加或者移除时 keypath == nil，导致崩溃。
    //    [self testKVOCrash4];
    
    //KVC Test
    //    1. key 不是对象的属性，造成崩溃
    //    [self testKVCCrash1];

    //    2. keyPath 不正确，造成崩溃
    //    [self testKVCCrash2];

    //    3. key 为 nil，造成崩溃
    //    [self testKVCCrash4];

    //    4. value 为 nil，为非对象设值，造成崩溃
    //    [self testKVCCrash4];
}

#pragma mark - KVO

/**
 1.1 移除了未注册的观察者，导致崩溃
 */
- (void)testKVOCrash11 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.2 重复移除多次，移除次数多于添加次数，导致崩溃
 */
- (void)testKVOCrash12 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
    [self.objc removeObserver:self forKeyPath:@"name"];
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
 */
- (void)testKVOCrash13 {
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
}

/**
 2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
 */
- (void)testKVOCrash2 {
    // 崩溃日志：An instance xxx of class xxx was deallocated while key value observers were still registered with it.
    // iOS 10 及以下会导致崩溃，iOS 11 之后就不会崩溃了
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    [obj addObserver: self
          forKeyPath: @"name"
             options: NSKeyValueObservingOptionNew
             context: nil];
}

/**
 3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
 */
- (void)testKVOCrash3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @"title"
              options: NSKeyValueObservingOptionNew
              context: nil];

    self.title = @"111";
}

/**
 4. 添加或者移除时 keypath == nil，导致崩溃。
 */
- (void)testKVOCrash4 {
    // 崩溃日志： -[__NSCFConstantString characterAtIndex:]: Range or index out of bounds
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @""
              options: NSKeyValueObservingOptionNew
              context: nil];
    
//    [self removeObserver:obj forKeyPath:@""];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {

    NSLog(@"object = %@, keyPath = %@", object, keyPath);
}

#pragma mark - KVC

/**
 1. key 不是对象的属性，造成崩溃
 */
- (void)testKVCCrash1 {
    // 崩溃日志：[<KVCCrashObject 0x600000d48ee0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key XXX.;
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"value" forKey:@"address"];
}

/**
 2. keyPath 不正确，造成崩溃
 */
- (void)testKVCCrash2 {
    // 崩溃日志：[<KVCCrashObject 0x60000289afb0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key XXX.
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"后厂村路" forKeyPath:@"address.street"];
}

/**
 3. key 为 nil，造成崩溃
 */
- (void)testKVCCrash3 {
    // 崩溃日志：'-[KVCCrashObject setValue:forKey:]: attempt to set a value for a nil key

    NSString *keyName;
    // key 为 nil 会崩溃，如果传 nil 会提示警告，传空变量则不会提示警告
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"value" forKey:keyName];
}

/**
 4. value 为 nil，造成崩溃
 */
- (void)testKVCCrash4 {
    // 崩溃日志：[<KVCCrashObject 0x6000028a6780> setNilValueForKey]: could not set nil as the value for the key XXX.
    
    // value 为 nil 会崩溃
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:nil forKey:@"age"];
}

#pragma mark - Setter and Getter

- (KVOCrashObject *)objc {
    if (!_objc) {
        _objc = [[KVOCrashObject alloc]init];
    }
    return _objc;
}

@end

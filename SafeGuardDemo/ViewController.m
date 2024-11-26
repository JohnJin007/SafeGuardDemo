//
//  ViewController.m
//  SafeGuardDemo
//
//  Created by v_jinlilili on 2024/11/22.
//

#import "ViewController.h"
#import "MKKVOObjectDemo.h"

@interface MKKVOObserver : NSObject

@end

@implementation MKKVOObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}

- (void)dealloc {
    NSLog(@"========dealloc");
}

@end

@interface ViewController (){
    MKKVOObjectDemo *_kvoDemo;
    MKKVOObserver *_kvoObserver;
}

@property (nonatomic, copy) NSString* test;

@property (nonatomic, copy) NSString* test1;

@property (nonatomic, copy) NSString* demoString1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //test
    [self testSafeGuard];
    
    //Test KVO
    _kvoDemo = [MKKVOObjectDemo new];
    _kvoObserver = [MKKVOObserver new];
    [self testKVO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _kvoObserver = nil;
        self.demoString1 = @"11";
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"Observed change: %@", change);
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

- (void)testKVO {
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionNew context:nil];
    
    //crash
    [self removeObserver:self forKeyPath:@"test0" context:nil];
    
    [self addObserver:self forKeyPath:@"test2" options:NSKeyValueObservingOptionNew context:nil];
    
    [_kvoDemo addObserver:self forKeyPath:@"demoString" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserver:_kvoObserver forKeyPath:@"demoString1" options:NSKeyValueObservingOptionNew context:nil];
}

@end

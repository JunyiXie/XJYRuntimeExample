//
//  Cat.m
//  XJYRuntimeExample
//
//  Created by 谢俊逸 on 06/02/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "Cat.h"
#import <objc/runtime.h>
#import "AlternateObject.h"

@interface Cat ()


@property (nonatomic, strong) AlternateObject *alternateObject;



@end

@implementation Cat

- (instancetype)init {
    if (self = [super init]) {
        self.alternateObject = [[AlternateObject alloc] init];
        [self performSelector:@selector(mysteriousMethod:)];
    }
    return self;
}

/*
 + (BOOL)resolveInstanceMethod:(SEL)sel {
 NSString *selectorString = NSStringFromSelector(sel);
 if ([selectorString isEqualToString:@"mysteriousMethod"]) {
 class_addMethod(self.class, @selector(mysteriousMethod), (IMP)functionForMethod1, "@:");
 }
 return [super resolveInstanceMethod:sel];
 }
 */

//  第一步
//  在没有找到方法时，会先调用此方法，可用于动态添加方法
//  返回 YES 表示相应 selector 的实现已经被找到并添加到了类中，否则返回 NO
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES;
}


//  第二步
//  如果第一步的返回 NO 或者直接返回了 YES 而没有添加方法，该方法被调用
//  在这个方法中，我们可以指定一个可以返回一个可以响应该方法的对象
//  如果返回 self 就会死循环
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if(aSelector == @selector(xxx:)){
        return self.alternateObject;
    }
    return [super forwardingTargetForSelector:aSelector];
}

//  第三步
//  如果 `forwardingTargetForSelector:` 返回了 nil，则该方法会被调用，系统会询问我们要一个合法的『类型编码(Type Encoding)』
//  若返回 nil，则不会进入下一步，而是无法处理消息

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

// 当实现了此方法后，-doesNotRecognizeSelector: 将不会被调用
// 如果要测试找不到方法，可以注释掉这一个方法
// 在这里进行消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // 我们还可以改变方法选择器
    [anInvocation setSelector:@selector(notFind)];
    // 改变方法选择器后，还需要指定是哪个对象的方法
    [anInvocation invokeWithTarget:self];
}



- (void)notFind {
    NSLog(@"没有实现 -mysteriousMethod 方法，并且成功的转成了 -notFind 方法");
}


@end

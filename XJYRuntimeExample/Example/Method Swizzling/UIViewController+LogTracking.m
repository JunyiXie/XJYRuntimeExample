//
//  UIViewController+LogTracking.m
//  XJYRuntimeExample
//
//  Created by 谢俊逸 on 05/02/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "UIViewController+LogTracking.h"
#import <objc/runtime.h>

@implementation UIViewController (LogTracking)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xjy_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class,originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class,swizzledSelector);
        
        //judge the method named  swizzledMethod is already existed.
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        // if swizzledMethod is already existed.
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (void)xjy_viewWillAppear:(BOOL)animated {
    [self xjy_viewWillAppear:animated];
    NSLog(@"viewWillAppear : %@",self);
}
@end

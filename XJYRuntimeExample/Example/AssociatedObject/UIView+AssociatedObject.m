//
//  UIView+AssociatedObject.m
//  XJYRuntimeExample
//
//  Created by 谢俊逸 on 05/02/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "UIView+AssociatedObject.h"

@implementation UIView (AssociatedObject)

static char kAssociatedObjectKey;


- (void)setAssociatedObject:(id)associatedObject {
    objc_setAssociatedObject(self, &kAssociatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}

@end

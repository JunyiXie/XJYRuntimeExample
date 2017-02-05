//
//  ViewController.m
//  XJYRuntimeExample
//
//  Created by 谢俊逸 on 05/02/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import "Cat.h"

@interface ViewController ()

@property (nonatomic, strong) Person *xjy;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.xjy = [[Person alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    Cat *cat = [[Cat alloc] init];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 添加方法

- (IBAction)addMethod:(id)sender {
    [self addMethodForPerson];
    if ([self.xjy respondsToSelector:@selector(speakMyName)]) {
        [self.xjy performSelector:@selector(speakMyName)];
    } else {
        NSLog(@"未添加成功");
    }
}

- (void)addMethodForPerson {
    class_addMethod([self.xjy class], @selector(speakMyName), (IMP)speakMyName, "v@:*");
}

void speakMyName(id self,SEL _cmd) {
    NSLog(@"添加成功啊QAQ");
}



@end

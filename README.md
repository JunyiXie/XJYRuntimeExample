# XJYRuntimeExample
XJY Runtime Example Demo


[例子Demo](https://github.com/JunyiXie/XJYRuntimeExample)
欢迎给我star!我会继续分享的。

## 概述

Objc Runtime使得C具有了面向对象能力，在程序运行时创建，检查，修改类、对象和它们的方法。Runtime是C和汇编编写的，这里http://www.opensource.apple.com/source/objc4/可以下到苹果维护的开源代码，GNU也有一个开源的runtime版本，他们都努力的保持一致。

## 应用场景

1. 将某些OC代码转为运行时代码，探究底层，比如block的实现原理
2. 拦截系统自带的方法调用（Swizzle 黑魔法），比如拦截imageNamed:、viewDidLoad、alloc
3. 实现分类也可以增加属性
4. 实现NSCoding的自动归档和自动解档
5. 实现字典和模型的自动转换。(MJExtension)
6. 修BUG神器，如果大型框架的BUG 通过Runtime来解决，非常好用。

## 一些常用类型

### Method
> Method
An opaque type that represents a method in a class definition.
Declaration
typedef struct objc_method *Method;

代表类定义中的方法的不透明类型。

### Class
>Class
An opaque type that represents an Objective-C class.
Declaration
typedef struct objc_class *Class;

代表Objective-C中的类

### Ivar
>An opaque type that represents an instance variable.
Declaration
typedef struct objc_ivar *Ivar;

代表实例变量

### IMP
>IMP
A pointer to the start of a method implementation.

指向方法实现的开始的内存地址的指针。

### SEL
>SEL
Defines an opaque type that represents a method selector.
Declaration
typedef struct objc_selector *SEL;

代表方法的选择器


## 设置关联值
Example : 在category 中添加对象

```objectivec
//.h
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@interface UIView (AssociatedObject)

@property (nonatomic, strong) id associatedObject;

@end

//.m
#import "UIView+AssociatedObject.h"

@implementation UIView (AssociatedObject)

static char kAssociatedObjectKey;


- (void)setAssociatedObject:(id)associatedObject {
    objc_setAssociatedObject(self, &kAssociatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}


```
### objc_setAssociatedObject,给指定的对象设置关联值。
>objc_setAssociatedObject
Sets an associated value for a given object using a given key and association policy.
Declaration
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
Parameters
object
The source object for the association.
key
The key for the association.
value
The value to associate with the key key for object. Pass nil to clear an existing association.
policy
The policy for the association. For possible values, see Associative Object Behaviors.

- object 指定的对象
- const void *key key
- value 值
- policy 存储策略


| Behavior	| @property Equivalent	| Description |
|-----------| -----------------------|------------|
| OBJC_ASSOCIATION_ASSIGN	| @property (assign) 或 @property (unsafe_unretained)	| 指定一个关联对象的弱引用。|
| OBJC_ASSOCIATION_RETAIN_NONATOMIC	| @property (nonatomic, strong)	| 指定一个关联对象的强引用，不能被原子化使用。|
| OBJC_ASSOCIATION_COPY_NONATOMIC	| @property (nonatomic, copy)	| 指定一个关联对象的copy引用，不能被原子化使用。|
| OBJC_ASSOCIATION_RETAIN	| @property (atomic, strong) |	指定一个关联对象的强引用，能被原子化使用。|
| OBJC_ASSOCIATION_COPY	| @property (atomic, copy)	| 指定一个关联对象的copy引用，能被原子化使用。|


>objc_getAssociatedObject
Returns the value associated with a given object for a given key.
Declaration
id objc_getAssociatedObject(id object, const void *key);
Parameters
object
The source object for the association.
key
The key for the association.
Return Value
The value associated with the key key for object.

### objc_getAssociatedObject
返回给定对象的key的关联值
- object 关联的源对象
- key 关联的key
- Return Value 与对象的key相关联的值。

### objc_removeAssociatedObjects

>objc_removeAssociatedObjects
Removes all associations for a given object.
Declaration
void objc_removeAssociatedObjects(id object);
Parameters
object
An object that maintains associated objects.
Discussion
The main purpose of this function is to make it easy to return an object to a "pristine state”. You should not use this function for general removal of associations from objects, since it also removes associations that other clients may have added to the object. Typically you should use objc_setAssociatedObject with a nil value to clear an association.

删除给定对象的所有关联。
- object 对象（关联了许多值）
- 这个函数的主要目的是使对象返回一个“原始状态”，你不应该使用这个函数从对象中删除关联，因为它也删除了其他客户端可能添加到对象的关联 。通常应该使用带有nil值的objc_setAssociatedObject来清除关联。

### 优秀样例

- 添加私有属性用于更好地去实现细节。当扩展一个内建类的行为时，保持附加属性的状态可能非常必要。注意以下说的是一种非常教科书式的关联对象的用例：AFNetworking在 UIImageView 的category上用了关联对象来保持一个operation对象，用于从网络上某URL异步地获取一张图片。

- 添加public属性来增强category的功能。有些情况下这种(通过关联对象)让category行为更灵活的做法比在用一个带变量的方法来实现更有意义。在这些情况下，可以用关联对象实现一个一个对外开放的属性。回到上个AFNetworking的例子中的 UIImageView category，它的 imageResponseSerializer方法允许图片通过一个滤镜来显示、或在缓存到硬盘之前改变图片的内容。

- 创建一个用于KVO的关联观察者。当在一个category的实现中使用KVO时，建议用一个自定义的关联对象而不是该对象本身作观察者。ng an associated observer for KVO**. When using KVO in a category implementation, it is recommended that a custom associated-object be used as an observer, rather than the object observing itself.

### 反例
- 当值不需要的时候建立一个关联对象。一个常见的例子就是在view上创建一个方便的方法去保存来自model的属性、值或者其他混合的数据。如果那个数据在之后根本用不到，那么这种方法虽然是没什么问题的，但用关联到对象的做法并不可取。

- 当一个值可以被其他值推算出时建立一个关联对象。例如：在调用 cellForRowAtIndexPath: 时存储一个指向view的 UITableViewCell 中accessory view的引用，用于在 tableView:accessoryButtonTappedForRowWithIndexPath: 中使用。

- 用关联对象替代X，这里的X可以代表下列含义：
  1. 当继承比扩展原有的类更方便时用子类化。
  2. 为事件的响应者添加响应动作。
  3. 当响应动作不方便使用时使用的手势动作捕捉。
  4. 行为可以在其他对象中被代理实现时要用代理(delegate)。
  5. 用NSNotification 和 NSNotificationCenter进行松耦合化的跨系统的事件通知。


## 动态添加方法

Example:
```objectivec
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
```


### class_addMethod

>class_addMethod
Adds a new method to a class with a given name and implementation.
Declaration
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
Parameters
cls
The class to which to add a method.
name
A selector that specifies the name of the method being added.
imp
A function which is the implementation of the new method. The function must take at least two arguments—self and _cmd.
types
An array of characters that describe the types of the arguments to the method. For possible values, see Objective-C Runtime Programming Guide > Type Encodings. Since the function must take at least two arguments—self and _cmd, the second and third characters must be “@:” (the first character is the return type).
Return Value
YES if the method was added successfully, otherwise NO (for example, the class already contains a method implementation with that name).

给一个类添加方法
- cls 被添加方法的类
- name 添加的方法的名称的SEL
- imp 方法的实现。该函数必须至少要有两个参数，self,_cmd.

class_addMethod添加实现将覆盖父类的实现，但不会替换此类中的现有实现。 要更改现有实现，请使用method_setImplementation。
Objective-C方法只是一个C函数，至少需要两个参数 - self和_cmd。 例如，给定以下函数：
```
void myMethodIMP（id self，SEL _cmd）
{
     // implementation ....
}}
```
你可以动态地将它添加到类作为一个方法（称为resolveThisMethodDynamically）像这样：
```
class_addMethod（[self class]，@selector（resolveThisMethodDynamically），（IMP）myMethodIMP，“v @：”);
```

### 类型编码

>Type Encodings
To assist the runtime system, the compiler encodes the return and argument types for each method in a character string and associates the string with the method selector.

为了辅助运行时系统，编译器对字符串中每个方法的返回和参数类型进行编码，并将字符串与方法选择器相关联。 它使用的编码方案在其他上下文中也很有用，因此可以通过@encode（）编译器指令公开获得。 当给定类型规范时，@encode（）返回该类型的字符串编码。 类型可以是基本类型，例如int，指针，标记结构或联合，或类名 - 实际上可以用作C sizeof（）运算符的参数的任何类型。

具体内容参见 [Objective-C Runtime Programming Guide](https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100)


## 动态交换方法实现



Example:
```objectivec
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

```
### +load vs +initialize

swizzling应该只在+load中完成。 在 Objective-C 的运行时中，每个类有两个方法都会自动调用。+load 是在一个类被初始装载时调用，+initialize 是在应用第一次调用该类的类方法或实例方法前调用的。两个方法都是可选的，并且只有在方法被实现的情况下才会被调用。



### dispatch_once

**swizzling 应该只在 dispatch_once 中完成**

由于 swizzling 改变了全局的状态，所以我们需要确保每个预防措施在运行时都是可用的。原子操作就是这样一个用于确保代码只会被执行一次的预防措施，就算是在不同的线程中也能确保代码只执行一次。Grand Central Dispatch 的 dispatch_once 满足了所需要的需求，并且应该被当做使用 swizzling 的初始化单例方法的标准。



### method_getImplementation

>method_getImplementation
Returns the implementation of a method.
Declaration
IMP method_getImplementation(Method m);
Parameters
method
The method to inspect.
Return Value
A function pointer of type IMP.

返回方法的实现
- method Method


### method_getTypeEncoding

>method_getTypeEncoding
Returns a string describing a method's parameter and return types.
Declaration
const char * method_getTypeEncoding(Method m);
Parameters
method
The method to inspect.
Return Value
A C string. The string may be NULL.

返回一个C 字符串，描述方法的参数和返回类型.
- method Method


### class_replaceMethod

>class_replaceMethod
Replaces the implementation of a method for a given class.
Declaration
IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types);
Parameters
cls
The class you want to modify.
name
A selector that identifies the method whose implementation you want to replace.
imp
The new implementation for the method identified by name for the class identified by cls.
types
An array of characters that describe the types of the arguments to the method. For possible values, see Objective-C Runtime Programming Guide > Type Encodings. Since the function must take at least two arguments—self and _cmd, the second and third characters must be “@:” (the first character is the return type).
Return Value
The previous implementation of the method identified by name for the class identified by cls.

替换指定方法的实现
- cls class
- name selector
- imp 新的IMP
- types 类型编码

此函数以两种不同的方式运行：
1. 如果通过名称标识的方法不存在，则会像调用class_addMethod一样添加它。 由类型指定的类型编码按给定使用。
2. 如果按名称标识的方法存在，那么将替换其IMP，就好像调用了method_setImplementation。 将忽略由types指定的类型编码。

### method_exchangeImplementations
>method_exchangeImplementations
Exchanges the implementations of two methods.
Declaration
void method_exchangeImplementations(Method m1, Method m2);

交换两个方法的实现.


原子版本的实现：

```
IMP imp1 = method_getImplementation(m1);
IMP imp2 = method_getImplementation(m2);
method_setImplementation(m1, imp2);
method_setImplementation(m2, imp1);
```

### Selectors, Methods, & Implementations

在 Objective-C 的运行时中，selectors, methods, implementations 指代了不同概念，然而我们通常会说在消息发送过程中，这三个概念是可以相互转换的。 下面是苹果 Objective-C Runtime Reference中的描述：

- Selector（typedef struct objc_selector *SEL）:在运行时 Selectors 用来代表一个方法的名字。Selector 是一个在运行时被注册（或映射）的C类型字符串。Selector由编译器产生并且在当类被加载进内存时由运行时自动进行名字和实现的映射。
- Method（typedef struct objc_method *Method）:方法是一个不透明的用来代表一个方法的定义的类型。
- Implementation（typedef id (*IMP)(id, SEL,...)）:这个数据类型指向一个方法的实现的最开始的地方。该方法为当前CPU架构使用标准的C方法调用来实现。该方法的第一个参数指向调用方法的自身（即内存中类的实例对象，若是调用类方法，该指针则是指向元类对象metaclass）。第二个参数是这个方法的名字selector，该方法的真正参数紧随其后。

理解 selector, method, implementation 这三个概念之间关系的最好方式是：在运行时，类（Class）维护了一个消息分发列表来解决消息的正确发送。每一个消息列表的入口是一个方法（Method），这个方法映射了一对键值对，其中键是这个方法的名字 selector（SEL），值是指向这个方法实现的函数指针 implementation（IMP）。 Method swizzling 修改了类的消息分发列表使得已经存在的 selector 映射了另一个实现 implementation，同时重命名了原生方法的实现为一个新的 selector。

### 思考

很多人认为交换方法实现会带来无法预料的结果。然而采取了以下预防措施后, method swizzling 会变得很可靠：

- 在交换方法实现后记得要调用原生方法的实现（除非你非常确定可以不用调用原生方法的实现）：APIs 提供了输入输出的规则，而在输入输出中间的方法实现就是一个看不见的黑盒。交换了方法实现并且一些回调方法不会调用原生方法的实现这可能会造成底层实现的崩溃。
- 避免冲突：为分类的方法加前缀，一定要确保调用了原生方法的所有地方不会因为你交换了方法的实现而出现意想不到的结果。
- 理解实现原理：只是简单的拷贝粘贴交换方法实现的代码而不去理解实现原理不仅会让 App 很脆弱，并且浪费了学习 Objective-C 运行时的机会。阅读 Objective-C Runtime Reference 并且浏览 能够让你更好理解实现原理。
- 持续的预防：不管你对你理解 swlzzling 框架，UIKit 或者其他内嵌框架有多自信，一定要记住所有东西在下一个发行版本都可能变得不再好使。做好准备，在使用这个黑魔法中走得更远，不要让程序反而出现不可思议的行为。

>通过Method Swizzling可以把事件代码或Logging，Authentication，Caching等跟主要业务逻辑代码解耦。这种处理方式叫做Cross Cutting Concernshttp://en.wikipedia.org/wiki/Cross-cutting_concern 用Method Swizzling动态给指定的方法添加代码解决Cross Cutting Concerns的编程方式叫Aspect Oriented Programming http://en.wikipedia.org/wiki/Aspect-oriented_programming 目前有些第三方库可以很方便的使用AOP，比如Aspects https://github.com/steipete/Aspects 这里是使用Aspects的范例https://github.com/okcomp/AspectsDemo

> 部分内容引用和翻译自
http://nshipster.cn/method-swizzling/
http://nshipster.cn/associated-objects/
https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html
https://github.com/ming1016/study/wiki/Objc-Runtime

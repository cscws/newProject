//
//  UIViewController+Swizzling.m
//  goodboy
//
//  Created by 闪闪的少女 on 2022/2/10.
//

#import "UIViewController+Swizzling.h"
#import <objc/runtime.h>
@implementation UIViewController (Swizzling)
+ (void)load{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        Class class = [self class];
        SEL originSelector= @selector(viewWillAppear:);
        SEL swizzSelector = @selector(xxxviewWillAppear:);
        Method originMethod = class_getInstanceMethod(class, originSelector);
        Method swizzMethod = class_getInstanceMethod(class, swizzSelector);
        /**
         在进行Swizzling的时候，我们需要用class_addMethod先进行判断一下原有类中是否有要替换的方法的实现。

         如果class_addMethod返回NO，说明当前类中有要替换方法的实现，所以可以直接进行替换，调用method_exchangeImplementations即可实现Swizzling。

         如果class_addMethod返回YES，说明当前类中没有要替换方法的实现，我们需要在父类中去寻找。这个时候就需要用到method_getImplementation去获取class_getInstanceMethod里面的方法实现。然后再进行class_replaceMethod来实现Swizzling。
         */
        
        BOOL addMethod = class_addMethod(class, originSelector, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
        if(addMethod){
            class_replaceMethod(class, swizzSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swizzMethod);
        }
    });
}

- (void)xxxviewWillAppear:(BOOL)animated{
    [self xxxviewWillAppear:animated];
    NSLog(@"---xxxviewWillAppear---: %@", self);
}

@end

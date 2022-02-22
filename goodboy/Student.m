//
//  Student.m
//  goodboy
//
//  Created by 闪闪的少女 on 2022/2/10.
//

#import "Student.h"
#import <objc/runtime.h>
@implementation Student

// 归档的时候，系统会使用编码器把当前对象编码成二进制流
- (void)encodeWithCoder:(NSCoder *)coder {
    unsigned int count = 0;
    // 获取所有实例变量
    Ivar *ivars = class_copyIvarList([self class], &count);
    // 遍历
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        // KVC
        id value = [self valueForKey:key];
        // 编码
        [coder encodeObject:value forKey:key];
    }
    
    // 因为是 C 语言的东西，不会自动释放，所以这里需要手动释放。
    free(ivars);
}

// 解档的时候，系统会把二进制流解码成对象
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        unsigned int count = 0;
        // 获取所有实例变量
        Ivar *ivars = class_copyIvarList([self class], &count);
        // 遍历
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [coder decodeObjectOfClasses:[NSSet setWithObject:[self class]] forKey:key];
            // KVC
            [self setValue:value forKey:key];
        }
        
        free(ivars);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

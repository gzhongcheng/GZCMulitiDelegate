//
//  GZCMulitiDelegate.m
//  MulitiDelegate
//
//  Created by ZhongCheng Guo on 2019/1/31.
//  Copyright © 2019 ZhongCheng Guo. All rights reserved.
//

#import "GZCMulitiDelegate.h"

#import <UIKit/UIKit.h>

@interface GZCMulitiDelegate()

/// 信号量
@property ( nonatomic, strong ) dispatch_semaphore_t semaphore;

/// 代理容器
@property ( nonatomic, strong ) NSHashTable *delegates;

/// 方法结果容器
@property ( nonatomic, strong ) NSMutableDictionary *resultsDictionary;

@end

@implementation GZCMulitiDelegate

/// 初始化
+ (id)alloc{
    GZCMulitiDelegate *instance = [super alloc];
    if (instance) {
        instance.semaphore = dispatch_semaphore_create(1);
        instance.delegates = [NSHashTable weakObjectsHashTable];
        instance.resultsDictionary = [NSMutableDictionary dictionary];
    }
    return instance;
}

/// 添加代理
- (void)addDelegate:(id)delegate{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates addObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

/// 移除代理
- (void)removeDelete:(id)delegate{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates removeObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - 消息转发部分
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMethodSignature *methodSignature;
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:selector]) {
            methodSignature = [delegate methodSignatureForSelector:selector];
            break;
        }
    }
    dispatch_semaphore_signal(_semaphore);
    if (methodSignature){
        return methodSignature;
    }
    // 未找到方法时，返回默认方法 "- (void)method"，防止崩溃
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    // 为了避免造成递归死锁，copy一份delegates而不是直接用信号量将for循环包裹
    NSHashTable *copyDelegates = [_delegates copy];
    dispatch_semaphore_signal(_semaphore);
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    SEL selector = invocation.selector;
    NSMutableArray *results = [NSMutableArray array];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (id delegate in copyDelegates) {
        if ([delegate respondsToSelector:selector]) {
            // 异步调用时，拷贝一个Invocation，以免意外修改target导致crash
            NSInvocation *dupInvocation = [self copyInvocation:invocation];
            dupInvocation.target = delegate;
            // 异步调用多代理方法，以免响应不及时
            dispatch_group_enter(group);
            dispatch_group_async(group,queue, ^{
                // 获取返回值类型
                const char* returnValueType = dupInvocation.methodSignature.methodReturnType;
                [dupInvocation invoke];
                // returnValue在64位系统下的值见文件底部
                if(strcmp(returnValueType,@encode(void))) {
                    // 返回值类型不为空
                    // 声明一个返回值变量
                    __autoreleasing id returnValue;
                    if(!strcmp(returnValueType,@encode(id))) {
                        // 如果返回值为对象，那么为变量赋值
                        [dupInvocation getReturnValue:&returnValue];
                    }else{
                        // 如果返回值为普通类型，如NSInteger， NSUInteger ，BOOL等
                        // 首先获取返回值长度
                        NSUInteger returnValueLenth = dupInvocation.methodSignature.methodReturnLength;
                        // 根据长度申请内存
                        void* retValue = (void*)malloc(returnValueLenth);
                        // 为retValue赋值
                        [dupInvocation getReturnValue:retValue];
                        // 将类型转换为可以保存在NSArray中的对象 看这一排的else if 怕不怕 ->.->
                        if(!strcmp(returnValueType,@encode(BOOL))) {
                            returnValue = [NSNumber numberWithBool:*((BOOL*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(short))) {
                            returnValue = [NSNumber numberWithShort:*((short*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(unsigned short))) {
                            returnValue = [NSNumber numberWithUnsignedShort:*((unsigned short*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(int))) {
                            returnValue = [NSNumber numberWithInt:*((int*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(unsigned int))) {
                            returnValue = [NSNumber numberWithFloat:*((unsigned int*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(long))) {
                            returnValue = [NSNumber numberWithLong:*((long*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(unsigned long))) {
                            returnValue = [NSNumber numberWithUnsignedLong:*((unsigned long*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(long long))) {
                            returnValue = [NSNumber numberWithLongLong:*((long long*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(unsigned long long))) {
                            returnValue = [NSNumber numberWithUnsignedLongLong:*((unsigned long long*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(float))) {
                            returnValue = [NSNumber numberWithFloat:*((float*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(double))) {
                            returnValue = [NSNumber numberWithDouble:*((double*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(char))) {
                            returnValue = [NSString stringWithFormat:@"%c",*((char*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(unsigned char))) {
                            returnValue = [NSString stringWithFormat:@"%c",*((unsigned char*)retValue)];
                        }else if(!strcmp(returnValueType,@encode(char *))) {
                            returnValue = [NSString stringWithFormat:@"%s",*((char **)retValue)];
                        }else if(!strcmp(returnValueType,@encode(Class))) {
                            returnValue = *((Class *)retValue);
                        }else if(!strcmp(returnValueType,@encode(SEL))) {
                            returnValue = NSStringFromSelector(*((SEL *)retValue));
                        }else if(!strcmp(returnValueType,"@?")) {
                            returnValue = (__bridge id)(_Block_copy(*((const void * *)retValue)));
                        }
                    }
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [results addObject:returnValue];
                    dispatch_semaphore_signal(semaphore);
                }
                dispatch_group_leave(group);
            });
        }
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [self.resultsDictionary setObject:[results copy] forKey:NSStringFromSelector(selector)];
    dispatch_semaphore_signal(_semaphore);
}

- (NSInvocation *)copyInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    NSMethodSignature *methodSignature = invocation.methodSignature;
    NSInvocation *copyInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    copyInvocation.selector = selector;
    
    NSUInteger count = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < count; i++) {
        void *value;
        [invocation getArgument:&value atIndex:i];
        [copyInvocation setArgument:&value atIndex:i];
    }
    [copyInvocation retainArguments];
    return copyInvocation;
}

@end

/** returnValue在64位系统下的值：
 v ==> void
 c ==> char
 C ==> unsigned char
 * ==> char *
 B ==> BOOL
 i ==> int
 I ==> unsigned int
 s ==> short
 S ==> unsigned short
 q ==> long/long long/NSInteger
 Q ==> unsigned long/unsigned long long/NSUInteger
 f ==> float
 d ==> double / CGFloat
 @ ==> id
 @? ==> block
 # ==> Class
 : ==> SEL
 **/

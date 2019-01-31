//
//  DemoManager.m
//  MulitiDelegateDemo
//
//  Created by ZhongCheng Guo on 2019/1/31.
//  Copyright © 2019 ZhongCheng Guo. All rights reserved.
//

#import "DemoManager.h"
#import "GZCMulitiDelegate.h"

@interface DemoManager()

/// 多播代理
@property ( nonatomic, strong ) GZCMulitiDelegate *delegateProxy;

@end

@implementation DemoManager
@synthesize themesColor = _themesColor;

static DemoManager *_manager = nil;

+ (instancetype)sharedManager{
    return [[self alloc]init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_manager == nil) {
            _manager = [super allocWithZone:zone];
        }
    });
    return _manager;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _manager;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _manager;
}

- (GZCMulitiDelegate *)delegateProxy{
    if (!_delegateProxy) {
        _delegateProxy = [GZCMulitiDelegate alloc];
    }
    return _delegateProxy;
}

- (void)addDelegate:(id<DemoDelegate>)delegate {
    [self.delegateProxy addDelegate:delegate];
}

- (void)removeDelegate:(id<DemoDelegate>)delegate {
    [self.delegateProxy removeDelete:delegate];
}

- (void)setThemesColor:(UIColor *)themesColor{
    _themesColor = [themesColor copy];
    [(id<DemoDelegate>)self.delegateProxy themesColorChanged:_themesColor];
    NSLog(@"%@",[self.delegateProxy.resultsDictionary objectForKey:NSStringFromSelector(@selector(themesColorChanged:))]);
}

- (CGFloat)getProgress{
    [(id<DemoDelegate>)self.delegateProxy somethingProgress];
    NSArray *results = [self.delegateProxy.resultsDictionary objectForKey:NSStringFromSelector(@selector(somethingProgress))];
    NSLog(@"%@",results);
    __block CGFloat total = 0.0;
    __block CGFloat progress = 0.0;
    [results enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        progress += [obj floatValue];
        total += 100.0;
    }];
    return progress/total;
}

- (UIColor *)themesColor{
    if (!_themesColor) {
        // 默认颜色
        _themesColor = [UIColor colorWithWhite:0.8f alpha:1.f];
    }
    return _themesColor;
}

@end

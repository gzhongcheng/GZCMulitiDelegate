//
//  DemoManager.h
//  MulitiDelegateDemo
//
//  Created by ZhongCheng Guo on 2019/1/31.
//  Copyright © 2019 ZhongCheng Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BLOCK)(void);
@protocol DemoDelegate <NSObject>

/**
 主题颜色改变（测试无返回值的多播代理分发事件）
 
 @param themesColor 改变后的主题色
 @return 是否改变成功
 */
- (int)themesColorChanged:(UIColor *)themesColor;

/**
 获取进度（测试有返回值的多播代理分发事件,这里假设需有个地方要所有代理返回进度进行计算）
 
 @return 代理对象的进度
 */
- (CGFloat)somethingProgress;

@end

@interface DemoManager : NSObject

/// 主题颜色，通过set方法改变时会分发给所有的delegate
@property ( nonatomic, copy ) UIColor *themesColor;

/// 获取单例
+ (instancetype)sharedManager;

/// 添加、移除代理
- (void)addDelegate:(id<DemoDelegate>)delegate;
- (void)removeDelegate:(id<DemoDelegate>)delegate;


/**
 获取某事的总进度(0-1)

 @return 进度
 */
- (CGFloat)getProgress;

@end

NS_ASSUME_NONNULL_END

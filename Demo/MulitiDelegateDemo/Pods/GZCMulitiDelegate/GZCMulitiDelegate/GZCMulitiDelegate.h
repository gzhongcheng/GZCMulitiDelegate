//
//  GZCMulitiDelegate.h
//  MulitiDelegate
//
//  Created by ZhongCheng Guo on 2019/1/31.
//  Copyright © 2019 ZhongCheng Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZCMulitiDelegate : NSProxy

/**
 调用代理方法时，如果方法有返回值，则返回值会以代理方法名称为Key，以NSArray作为Value的形式存储在这个字典中。
 */
@property (readonly) NSMutableDictionary *resultsDictionary;

/**
 添加代理
 */
- (void)addDelegate:(id)delegate;

/**
 移除代理
 */
- (void)removeDelete:(id)delegate;

@end

NS_ASSUME_NONNULL_END

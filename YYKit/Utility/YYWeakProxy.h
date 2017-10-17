//
//  YYWeakProxy.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 使用proxy避免循环引用
 问题：
 计时器常见的内存泄露原因如下，因为初始化NSTimer时指定了触发事件为self,所以说self被NSTimer强引用了，而NSTimer对象又被加
 入了当前的RunLoop，出现了循环引用
 解决思路：
 1 runtime解决
 指定target为一个单独的对象，利用runTime在target对象中动态的创建SEL方法，然后target对象关联当前视图self,当target对象执行SEL方法
 时，取出关联对象self，然后让self执行该方法；
 2 proxy解决
 proxy持有当前试图self,将target指定为proxy,方法会转发给self,销毁时，timer不直接持有self,可以避免循环引用
 A proxy used to hold a weak object.
 It can be used to avoid retain cycles, such as the target in NSTimer or CADisplayLink.
 
 sample code:
 
     @implementation MyView {
        NSTimer *_timer;
     }
     
     - (void)initTimer {
        YYWeakProxy *proxy = [YYWeakProxy proxyWithTarget:self];
        _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
     }
     
     - (void)tick:(NSTimer *)timer {...}
     @end
 */
@interface YYWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END

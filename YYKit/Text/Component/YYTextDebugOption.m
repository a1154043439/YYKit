//
//  YYTextDebugOption.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/4/8.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextDebugOption.h"
#import "YYKitMacro.h"
#import "UIColor+YYAdd.h"
#import "YYWeakProxy.h"


static pthread_mutex_t _sharedDebugLock;
static CFMutableSetRef _sharedDebugTargets = nil;
static YYTextDebugOption *_sharedDebugOption = nil;

// void *表示空类型指针，，该指针与一地址值相关，但是不清楚在此地址上的对象的类型
static const void* _sharedDebugSetRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void _sharedDebugSetRelease(CFAllocatorRef allocator, const void *value) {
}

//C语言的语法，在.m文件以外
void _sharedDebugSetFunction(const void *value, void *context) {
    //value bridge 为 target对象
    id<YYTextDebugTarget> target = (__bridge id<YYTextDebugTarget>)(value);
    [target setDebugOption:_sharedDebugOption];
}

static void _initSharedDebug() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化锁
        pthread_mutex_init(&_sharedDebugLock, NULL);
        //CFSetCallBacks structure initialized with the callbacks to use to retain, release, describe, and compare values in set.
        CFSetCallBacks callbacks = kCFTypeSetCallBacks;
        //定义retain和release的函数回调，在item进set和出set的时候自动回调
        //啥也没做啊，所以类似于弱引用的实现，此容器持有该target，但是不增加target的引用计数
        callbacks.retain = _sharedDebugSetRetain;
        callbacks.release = _sharedDebugSetRelease;
        //创建一个CFSet
        //第三个参数，A pointer to a CFSetCallBacks structure initialized with the callbacks to use to retain, release, describe, and compare values in the set. A copy of the contents of the callbacks structure is made, so that a pointer to a structure on the stack can be passed in or can be reused for multiple collection creations. This parameter may be NULL, which is treated as if a valid structure of version 0 with all fields NULL had been passed in.
        _sharedDebugTargets = CFSetCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
    });
}

static void _setSharedDebugOption(YYTextDebugOption *option) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    _sharedDebugOption = option.copy;
    //第二个参数用来表示
    //The callback function to call once for each value in the theSet.
    //此方法用来将set中的每个target执行_sharedDebugSetFunction的方法
    CFSetApplyFunction(_sharedDebugTargets, _sharedDebugSetFunction, NULL);
    pthread_mutex_unlock(&_sharedDebugLock);
}

static YYTextDebugOption *_getSharedDebugOption() {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    YYTextDebugOption *op = _sharedDebugOption;
    pthread_mutex_unlock(&_sharedDebugLock);
    return op;
}

static void _addDebugTarget(id<YYTextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    //将target bridge一下（OC->>>Core Foudation）,
    CFSetAddValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}

static void _removeDebugTarget(id<YYTextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetRemoveValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}


@implementation YYTextDebugOption

- (id)copyWithZone:(NSZone *)zone {
    YYTextDebugOption *op = [self.class new];
    op.baselineColor = self.baselineColor;
    op.CTFrameBorderColor = self.CTFrameBorderColor;
    op.CTFrameFillColor = self.CTFrameFillColor;
    op.CTLineBorderColor = self.CTLineBorderColor;
    op.CTLineFillColor = self.CTLineFillColor;
    op.CTLineNumberColor = self.CTLineNumberColor;
    op.CTRunBorderColor = self.CTRunBorderColor;
    op.CTRunFillColor = self.CTRunFillColor;
    op.CTRunNumberColor = self.CTRunNumberColor;
    op.CGGlyphBorderColor = self.CGGlyphBorderColor;
    op.CGGlyphFillColor = self.CGGlyphFillColor;
    return op;
}

- (BOOL)needDrawDebug {
    if (self.baselineColor ||
        self.CTFrameBorderColor ||
        self.CTFrameFillColor ||
        self.CTLineBorderColor ||
        self.CTLineFillColor ||
        self.CTLineNumberColor ||
        self.CTRunBorderColor ||
        self.CTRunFillColor ||
        self.CTRunNumberColor ||
        self.CGGlyphBorderColor ||
        self.CGGlyphFillColor) return YES;
    return NO;
}

- (void)clear {
    self.baselineColor = nil;
    self.CTFrameBorderColor = nil;
    self.CTFrameFillColor = nil;
    self.CTLineBorderColor = nil;
    self.CTLineFillColor = nil;
    self.CTLineNumberColor = nil;
    self.CTRunBorderColor = nil;
    self.CTRunFillColor = nil;
    self.CTRunNumberColor = nil;
    self.CGGlyphBorderColor = nil;
    self.CGGlyphFillColor = nil;
}

+ (void)addDebugTarget:(id<YYTextDebugTarget>)target {
    if (target) _addDebugTarget(target);
}

+ (void)removeDebugTarget:(id<YYTextDebugTarget>)target {
    if (target) _removeDebugTarget(target);
}

+ (YYTextDebugOption *)sharedDebugOption {
    return _getSharedDebugOption();
}

+ (void)setSharedDebugOption:(YYTextDebugOption *)option {
    YYAssertMainThread();
    _setSharedDebugOption(option);
}

@end


//
//  YYTextRunDelegate.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/14.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapper for CTRunDelegateRef.
 CTRunDelegateRef的包装类，封装了创建方法，在内部使用callbacks
 普通CTRunDelegateRef的使用如下：
 Example:
 
 unichar objectReplacementChar           = 0xFFFC;
 NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
 NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
 
 CTRunDelegateCallbacks callbacks;
 callbacks.version       = kCTRunDelegateVersion1;
 callbacks.getAscent     = ascentCallback;
 callbacks.getDescent    = descentCallback;
 callbacks.getWidth      = widthCallback;
 callbacks.dealloc       = deallocCallback;
 //创建delegate,参数为CTRunDelegateCallbacks和RefCon
 CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)attachment);
 //将delegate赋给字典
 NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
 //将指定富文本的字段范围设置该delegate
 [attachText setAttributes:attr range:NSMakeRange(0, 1)];
 //释放该delegate
 CFRelease(delegate);
 
 包装优化后使用如下
 Example:
 
     YYTextRunDelegate *delegate = [YYTextRunDelegate new];
     delegate.ascent = 20;
     delegate.descent = 4;
     delegate.width = 20;
     CTRunDelegateRef ctRunDelegate = delegate.CTRunDelegate;
     if (ctRunDelegate) {
         /// add to attributed string
         CFRelease(ctRunDelegate);
     }
 
 */
@interface YYTextRunDelegate : NSObject <NSCopying, NSCoding>

/**
 Creates and returns the CTRunDelegate.
 
 @discussion You need call CFRelease() after used.
 The CTRunDelegateRef has a strong reference to this YYTextRunDelegate object.
 In CoreText, use CTRunDelegateGetRefCon() to get this YYTextRunDelegate object.
 
 @return The CTRunDelegate object.
 */
- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

/**
 Additional information about the the run delegate.
 */
@property (nullable, nonatomic, strong) NSDictionary *userInfo;

/**
 The typographic ascent of glyphs in the run.
 */
@property (nonatomic) CGFloat ascent;

/**
 The typographic descent of glyphs in the run.
 */
@property (nonatomic) CGFloat descent;

/**
 The typographic width of glyphs in the run.
 */
@property (nonatomic) CGFloat width;

@end

NS_ASSUME_NONNULL_END

//
//  ParcoaInput.h
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/28.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParcoaInput : NSObject

@property (nonatomic, weak, readonly) NSString *string;
@property (nonatomic, readonly) NSUInteger length;

- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithString:(NSString *)string residual:(NSRange)residual;

- (BOOL)isEqualToString:(NSString *)aString;

- (BOOL)hasPrefix:(NSString *)aString;

- (unichar)characterAtIndex:(NSUInteger)index;

- (instancetype)substringFromIndex:(NSUInteger)index;

- (instancetype)substringToIndex:(NSUInteger)index;

- (instancetype)stringByAppendingString:(ParcoaInput *)input;

@end

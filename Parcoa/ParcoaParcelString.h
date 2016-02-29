//
//  ParcoaParcelString.h
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/28.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParcoaParcelString : NSObject
{
@protected
    NSString *_string;
    NSRange _range;
}

@property (nonatomic, readonly) NSString *string;

@property (nonatomic, readonly) NSRange range;

- (NSString *)stringValue;

- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithString:(NSString *)string range:(NSRange)range;

- (NSUInteger)length;

- (BOOL)isEqualToString:(NSString *)aString;

- (BOOL)hasPrefix:(NSString *)aString;

- (unichar)characterAtIndex:(NSUInteger)index;

- (instancetype)substringFromIndex:(NSUInteger)index;

- (instancetype)substringToIndex:(NSUInteger)index;

- (instancetype)stringByAppendingString:(ParcoaParcelString *)aPercelString;

@end

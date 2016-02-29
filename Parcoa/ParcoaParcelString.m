//
//  ParcoaParcelString.m
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/28.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaParcelString.h"

@interface ParcoaParcelString ()

@property (nonatomic, readwrite) NSString *string;
@property (nonatomic, readwrite) NSRange range;

@end

@implementation ParcoaParcelString

- (instancetype)initWithString:(NSString *)string
{
    return [self initWithString:string range:NSMakeRange(0, string.length)];
}

- (instancetype)initWithString:(NSString *)string range:(NSRange)range
{
    self = [super init];
    if(self){
        self.string = string;
        self.range = range;
    }
    return self;
}

- (NSString *)stringValue
{
    return [self.string substringWithRange:self.range];
}

- (NSUInteger)length
{
    return self.range.length;
}

- (BOOL)hasPrefix:(NSString *)aString
{
    NSString *string = self.string;
    NSRange residual = self.range;
    if(string.length < residual.location + aString.length){
        return NO;
    }
    
    for(int i = 0; i < aString.length; i++){
        if([string characterAtIndex:residual.location + i] != [aString characterAtIndex:i]){
            return NO;
        }
    }
    
    return YES;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return [self.string characterAtIndex:self.range.location + index];
}

- (instancetype)substringFromIndex:(NSUInteger)index
{
    if(index > self.range.length){
        NSString *reason = [NSString stringWithFormat:@"index %ld beyond bounds [0 .. %ld", index, self.range.length - 1];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    NSRange r = NSMakeRange(index + self.range.location, self.range.length - index);
    return [[self.class alloc] initWithString:self.string range:r];
}

- (instancetype)substringToIndex:(NSUInteger)index
{
    if(index > self.range.length){
        NSString *reason = [NSString stringWithFormat:@"index %ld beyond bounds [0 .. %ld", index, self.range.length - 1];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    
    NSRange r = NSMakeRange(self.range.location, index);
    return [[self.class alloc] initWithString:self.string range:r];
}

- (NSUInteger)hash
{
    return self.string.hash ^ self.range.length ^ self.range.location;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if([object isKindOfClass:NSString.class]){
        return [self isEqualToString:object];
    }
    
    return [self isEqualToParcelString:object];
}

- (BOOL)isEqualToParcelString:(ParcoaParcelString *)parcelString
{
    if(!parcelString){
        return NO;
    }
    
    return [parcelString.string isEqualToString:self.string] && parcelString.range.location == self.range.location && parcelString.range.length == parcelString.range.length;
}

- (BOOL)isEqualToString:(NSString *)aString
{    
    return [aString isEqualToString:[self.string substringWithRange:self.range]];
}

- (instancetype)stringByAppendingString:(ParcoaParcelString *)aPercelString
{
    NSString *aString = [aPercelString.string substringWithRange:aPercelString.range];
    NSString *string = [self.string substringToIndex:self.range.location + self.range.length];
    self.string = [string stringByAppendingString:aString];
    self.range = NSMakeRange(self.range.location, string.length + aString.length);
    
    return self;
}

@end

//
//  ParcoaInput.m
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/28.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaInput.h"

@interface ParcoaInput ()

@property (nonatomic) NSString *string;
@property (nonatomic, readwrite) NSRange residual;

@end

@implementation ParcoaInput

- (instancetype)initWithString:(NSString *)string
{
    return [self initWithString:string residual:NSMakeRange(0, string.length)];
}

- (instancetype)initWithString:(NSString *)string residual:(NSRange)residual
{
    self = [super init];
    if(self){
        self.string = string;
        self.residual = residual;
    }
    return self;
}

- (NSString *)stringValue
{
    return [self.string substringWithRange:self.residual];
}

- (NSUInteger)length
{
    return self.residual.length;
}

- (BOOL)hasPrefix:(NSString *)aString
{
    NSString *string = self.string;
    NSRange residual = self.residual;
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
    return [self.string characterAtIndex:self.residual.location + index];
}

- (instancetype)substringFromIndex:(NSUInteger)index
{
    if(index > self.residual.length){
        NSString *reason = [NSString stringWithFormat:@"index %ld beyond bounds [0 .. %ld", index, self.residual.length - 1];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    NSRange r = NSMakeRange(index + self.residual.location, self.residual.length - index);
    return [[self.class alloc] initWithString:self.string residual:r];
}

- (instancetype)substringToIndex:(NSUInteger)index
{
    if(index > self.residual.length){
        NSString *reason = [NSString stringWithFormat:@"index %ld beyond bounds [0 .. %ld", index, self.residual.length - 1];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    
    NSRange r = NSMakeRange(self.residual.location, index);
    return [[self.class alloc] initWithString:self.string residual:r];
}

- (NSUInteger)hash
{
    return self.string.hash ^ self.residual.length ^ self.residual.location;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if([object isKindOfClass:NSString.class]){
        return [self isEqualToString:object];
    }
    
    return [self isEqualToInput:object];
}

- (BOOL)isEqualToInput:(ParcoaInput *)aInput
{
    if(!aInput){
        return NO;
    }
    
    return [aInput.string isEqualToString:self.string] && aInput.residual.location == self.residual.location && aInput.residual.length == aInput.residual.length;
}

- (BOOL)isEqualToString:(NSString *)aString
{    
    return [aString isEqualToString:[self.string substringWithRange:self.residual]];
}

- (instancetype)stringByAppendingString:(ParcoaInput *)anInput
{
    NSString *aString = [anInput.string substringWithRange:anInput.residual];
    NSString *sourceString = [self.string substringToIndex:self.residual.location + self.residual.length];
    self.string = [sourceString stringByAppendingString:aString];
    self.residual = NSMakeRange(self.residual.location, sourceString.length + aString.length);
    
    return self;
}

@end

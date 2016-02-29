//
//  ParcoaMutableParcelString.m
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/29.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaMutableParcelString.h"

@implementation ParcoaMutableParcelString

- (instancetype)initWithPercelString:(ParcoaParcelString *)parcelString
{
    self = [super init];
    if(self) {
        _string = parcelString.string;
        _range = parcelString.range;
    }    
    return self;
}

- (BOOL)concatPercelString:(ParcoaParcelString *)aPercelString
{
    BOOL canConcat = (self.range.location + self.range.length == aPercelString.range.location);
    if(!canConcat){
        return NO;
    }
    
    _range = NSMakeRange(self.range.location, self.range.length + aPercelString.range.length);
    return YES;
}

@end

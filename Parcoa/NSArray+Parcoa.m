//
//  NSArray+Parcoa.m
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/28.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import "NSArray+Parcoa.h"
#import "ParcoaMutableParcelString.h"

@implementation NSArray (Parcoa)

- (instancetype)arrayByConcatPercelStrings {
    NSMutableArray *mArray = [NSMutableArray new];
    ParcoaMutableParcelString *lastPercelString = nil;

    for(id element in self) {
        if(![element isKindOfClass:ParcoaParcelString.class]) {
            lastPercelString = nil;
            [mArray addObject:element];
            continue;
        }
        
        if([lastPercelString concatPercelString:element]) {
            continue;
        }

        if(lastPercelString){
            [mArray addObject:lastPercelString.stringValue];
        }        
        lastPercelString = [[ParcoaMutableParcelString alloc] initWithPercelString:element];
    }
    
    if(lastPercelString){
        [mArray addObject:lastPercelString.stringValue];
    }
    
    return mArray.copy;
}

@end

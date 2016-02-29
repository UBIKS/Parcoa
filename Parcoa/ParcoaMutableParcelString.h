//
//  ParcoaMutableParcelString.h
//  Parcoa
//
//  Created by KATAOKA,Atsushi on 2016/02/29.
//  Copyright © 2016年 Factorial Products Pty. Ltd. All rights reserved.
//

#import "ParcoaParcelString.h"

@interface ParcoaMutableParcelString : ParcoaParcelString

- (instancetype)initWithPercelString:(ParcoaParcelString *)parcelString;

- (BOOL)concatPercelString:(ParcoaParcelString *)aPercelString;

@end

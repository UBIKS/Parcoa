/*
   ____
  |  _ \ __ _ _ __ ___ ___   __ _   Parcoa - Objective-C Parser Combinators
  | |_) / _` | '__/ __/ _ \ / _` |
  |  __/ (_| | | | (_| (_) | (_| |  Copyright (c) 2012,2013 James Brotchie
  |_|   \__,_|_|  \___\___/ \__,_|  https://github.com/brotchie/Parcoa


  The MIT License
  
  Copyright (c) 2012,2013 James Brotchie
    - brotchie@gmail.com
    - @brotchie
  
  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:
  
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#import "ParcoaResult.h"
#import "NSString+Parcoa.h"
#import "NSArray+Parcoa.h"
#import "ParcoaParcelString.h"

@interface ParcoaResult ()
- (id)initOK:(id)value input:(NSString *)input residual:(NSRange)residual expectation:(ParcoaExpectation *)expectation;
- (id)initFail:(ParcoaExpectation *)expectation;
@end

@implementation ParcoaResult

@synthesize type = _type; 
@synthesize value = _value;
@synthesize input = _input;
@synthesize residualRange = _residualRange;
@synthesize expectation = _expectation;

- (id)initOK:(id)value input:(NSString *)input residual:(NSRange)residual expectation:(ParcoaExpectation *)expectation{
    self = [super init];
    if (self) {
        _type = ParcoaResultOK;
        _value = value;
        _input = input;
        _residualRange = residual;
        _expectation = expectation;
    }
    return self;
}

- (id)initFail:(ParcoaExpectation *)expectation {
    self = [super init];
    if (self) {
        _type = ParcoaResultFail;
        _value = nil;
        _residualRange = NSMakeRange(NSNotFound, 0);
        _expectation = expectation;
    }
    return self;
}

+ (ParcoaResult *)ok:(id)value input:(NSString *)input residual:(NSRange)residual expected:(NSString *)expected{
    return [[ParcoaResult alloc] initOK:value input:input residual:residual expectation:[ParcoaExpectation expectationWithInput:input remaining:residual expected:expected children:nil]];
}

+ (ParcoaResult *)ok:(id)value input:(NSString *)input residual:(NSRange)residual expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult ok:value input:input residual:residual expected:expected];
}

+ (ParcoaResult *)okWithChildren:(NSArray *)children value:(id)value input:(NSString *)input residual:(NSRange)residual expected:(NSString *)expected {
    NSArray *expectations = [children valueForKey:@"expectation"];
    return [[ParcoaResult alloc] initOK:value input:input residual:residual expectation:[ParcoaExpectation expectationWithInput:input remaining:residual expected:expected children:expectations]];
}

+ (ParcoaResult *)failWithInput:(NSString *)input remaining:(NSRange)remaining expected:(NSString *)expected {
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithInput:input remaining:remaining expected:expected children:nil]];
}

+ (ParcoaResult *)failWithInput:(NSString *)input remaining:(NSRange)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [ParcoaResult failWithInput:input remaining:remaining expected:expected];
}

+ (ParcoaResult *)failWithChildren:(NSArray *)children input:(NSString *)input remaining:(NSRange)remaining expected:(NSString *)expected {
    NSArray *expectations = [children valueForKey:@"expectation"];
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithInput:input remaining:remaining expected:expected children:expectations]];
}

- (ParcoaResult *)prependExpectationWithInput:(NSString *)input remaining:(NSRange)remaining expected:(NSString *)expected {
    return [[ParcoaResult alloc] initFail:[ParcoaExpectation expectationWithInput:input remaining:remaining expected:expected children:@[self.expectation]]];
}

- (ParcoaResult *)prependExpectationWithInput:(NSString *)input remaining:(NSRange)remaining expectedWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *expected = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self prependExpectationWithInput:input remaining:remaining expected:expected];
}

- (BOOL)isFail {
    return _type == ParcoaResultFail;
}

- (BOOL)isOK {
    return _type == ParcoaResultOK;
}

- (id)value {
    if([_value isKindOfClass:ParcoaParcelString.class]){
        return [(ParcoaParcelString *)_value stringValue];
    }
    
    if([_value isKindOfClass:NSArray.class]){
        return [(NSArray *)_value arrayByConcatPercelStrings];
    }    
    return _value;
}

- (NSString *)residual
{
    return [self.input substringWithRange:self.residualRange];
}

- (NSString *)description {
    if ([self isOK]) {
        return [NSString stringWithFormat:@"ParcoaResult(OK,%@,%@[%lud-%lud])", self.value, self.input, self.residualRange.location, self.residualRange.location + self.residual.length - 1];
    } else {
        return [NSString stringWithFormat:@"ParcoaResult(Fail,%@)", self.expectation];
    }
}

#pragma mark - Traceback Generation

- (NSString *)traceback:(ParcoaParcelString *)input {
    return [self traceback:input full:NO];
}

- (NSString *)traceback:(ParcoaParcelString *)input full:(BOOL)full {
    NSUInteger targetMinCharactersRemaining = full ? NSUIntegerMax : self.expectation.minCharactersRemaining;
    return [self reduceTraceback:input expectation:self.expectation targetMinCharactersRemaining:targetMinCharactersRemaining indent:0];
}

- (NSString *)reduceTraceback:(ParcoaParcelString *)input expectation:(ParcoaExpectation *)expectation targetMinCharactersRemaining:(NSUInteger)targetMinCharactersRemaining indent:(NSUInteger)indent {
    NSMutableString *tb = [NSMutableString string];
    
    BOOL isSatisfiable = ![expectation.expected isEqualToString:[ParcoaExpectation unsatisfiable]];
    
    if (isSatisfiable)
        [tb appendString:[self formatTraceback:input expectation:expectation indent:indent]];
    
    [expectation.children enumerateObjectsUsingBlock:^(ParcoaExpectation *obj, NSUInteger idx, BOOL *stop) {
        if (obj.minCharactersRemaining <= targetMinCharactersRemaining) 
            [tb appendString:[self reduceTraceback:input expectation:obj targetMinCharactersRemaining:targetMinCharactersRemaining indent:indent+isSatisfiable]];
    }];
    
    return tb;
}

- (NSString *)formatTraceback:(ParcoaParcelString *)input expectation:(ParcoaExpectation *)expectation indent:(NSUInteger)indent {
    ParcoaLineColumn position = [input.stringValue lineAndColumnForIndex:input.length - expectation.charactersRemaining];
    NSString *tabs = [@"" stringByPaddingToLength:indent withString:@"\t" startingAtIndex:0];
    return [NSString stringWithFormat:@"%@Line %lu Column %lu: Expected %@.\n", tabs, (unsigned long)position.line, (unsigned long)position.column, expectation.expected];
}

@end

#import "VENMoneyCalculator.h"
#import "NSString+VENCalculatorInputView.h"

@interface VENMoneyCalculator ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation VENMoneyCalculator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locale = [NSLocale currentLocale];
    }
    return self;
}

- (NSString *)evaluateExpression:(NSString *)expressionString {

    NSNumber *result = [self numberWithEvaluateExpression:expressionString exception:nil];

    NSInteger integerExpression = [result integerValue];
    CGFloat floatExpression = [result floatValue];
    if (integerExpression == floatExpression) {
        return [result stringValue];
    } else if (floatExpression >= CGFLOAT_MAX || floatExpression <= CGFLOAT_MIN || isnan(floatExpression)) {
        return @"0";
    } else {
        NSString *moneyFormattedNumber = [[self numberFormatter] stringFromNumber:@(floatExpression)];
        return [moneyFormattedNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

- (NSNumber *)numberWithEvaluateExpression:(NSString *)expressionString exception:(NSException **)outException {
    if (!expressionString) {
        return nil;
    }
    NSString *sanitizedString = [self sanitizedString:expressionString];
    NSString *floatString = [NSString stringWithFormat:@"1.0*%@", sanitizedString];
    NSExpression *expression;
    id result;
    @try {
        expression = [NSExpression expressionWithFormat:floatString];
        result = [expression expressionValueWithObject:nil context:nil];
    }
    @catch (NSException *exception) {
        if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
            return nil;
        } else {
            if (outException == nil) {
                [exception raise];
            } else {
                *outException = exception;
            }
        }
    }
    if ([result isKindOfClass:[NSNumber class]]) {
        return result;
    } else {
        return nil;
    }
}

- (void)setLocale:(NSLocale *)locale {
    _locale = locale;
    self.numberFormatter.locale = locale;
}


#pragma mark - Private

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [NSNumberFormatter new];
        [_numberFormatter setLocale:self.locale];
        [_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_numberFormatter setCurrencySymbol:@""];
    }
    return _numberFormatter;
}

- (NSString *)sanitizedString:(NSString *)string {
    NSString *groupingSeperator = [self.locale objectForKey:NSLocaleGroupingSeparator];
    NSString *withoutGroupingSeperator = [string stringByReplacingOccurrencesOfString:groupingSeperator withString:@""];
    return [[self replaceOperandsInString:withoutGroupingSeperator] stringByReplacingCharactersInSet:[self illegalCharacters] withString:@""];
}

- (NSString *)replaceOperandsInString:(NSString *)string {
    NSString *subtractReplaced = [string stringByReplacingOccurrencesOfString:@"−" withString:@"-"];
    NSString *divideReplaced = [subtractReplaced stringByReplacingOccurrencesOfString:@"÷" withString:@"/"];
    NSString *multiplyReplaced = [divideReplaced stringByReplacingOccurrencesOfString:@"×" withString:@"*"];

    return [multiplyReplaced stringByReplacingOccurrencesOfString:[self decimalSeparator] withString:@"."];
}

- (NSCharacterSet *)illegalCharacters {
    return [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-/*.+()"] invertedSet];
}

- (NSString *)decimalSeparator {
    return [self.locale objectForKey:NSLocaleDecimalSeparator];
}

@end

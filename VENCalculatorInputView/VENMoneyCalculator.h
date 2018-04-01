#import <Foundation/Foundation.h>

@interface VENMoneyCalculator : NSObject

@property (strong, nonatomic) NSLocale *locale;

/**
 * Evaluates a mathematical expression containing +, −, ×, and ÷.
 * @param expression The expression to evaluate
 * @return The evaluated expression. Returns nil if the expression is invalid.
 */
- (NSString *)evaluateExpression:(NSString *)expression;

/**
 * Evaluates a mathematical expression containing +, −, ×, and ÷.
 * @param expressionString The expression to evaluate
 * @return The evaluated number. Returns nil if the expression is invalid.
 */
- (NSNumber *)numberWithEvaluateExpression:(NSString *)expressionString exception:(NSException **)outException;

@end

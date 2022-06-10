//
//  TBFullTokenizer.h
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBFullTokenizer : NSObject

- (instancetype)initWithVocab:(NSArray *)vocab;
- (NSArray <NSString *> *)tokenize:(NSString *)text;
- (NSArray <NSNumber *> *)convertTokensToIds:(NSArray *)tokens;

+ (NSArray <NSString *> *)tokenize:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

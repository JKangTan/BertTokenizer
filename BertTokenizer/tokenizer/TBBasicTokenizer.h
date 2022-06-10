//
//  TBBasicTokenizer.h
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBBasicTokenizer : NSObject

@property (nonatomic, strong) NSArray *never_split;

- (NSArray <NSString *> *)tokenize:(NSString *)text never_split:(NSArray *)neverSplit;
- (NSArray <NSString *> *)tokenize:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

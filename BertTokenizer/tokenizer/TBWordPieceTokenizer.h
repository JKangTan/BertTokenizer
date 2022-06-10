//
//  TBWordPieceTokenizer.h
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBWordPieceTokenizer : NSObject

- (instancetype)initWithVocab:(NSArray *)vocab;
/**
 Tokenizes a piece of text into its word pieces. This uses a greedy longest-match-first algorithm to perform
 tokenization using the given vocabulary.

 For example, :obj:`input = "unaffable"` wil return as output :obj:`["un", "##aff", "##able"]`.

 Args:
   text: A single token or whitespace separated tokens. This should have
     already been passed through `BasicTokenizer`.

 Returns:
   A list of wordpiece tokens.
 */
- (NSArray <NSString *> *)tokenize:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

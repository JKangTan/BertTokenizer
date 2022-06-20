//
//  TBWordPieceTokenizer.m
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/24.
//

#import "TBWordPieceTokenizer.h"
#import "NSString+TBTokenizer.h"

#define TB_UNKTOKEN  @"[UNK]"
#define TB_MaxInputCharsPerWord  512

@interface TBWordPieceTokenizer ()

@property (nonatomic, strong) NSArray *vocab;
@property (nonatomic, assign) NSUInteger maxInputCharsPerWord;

@end

@implementation TBWordPieceTokenizer

- (instancetype)initWithVocab:(NSArray *)vocab {
    if (self = [super init]) {
        _vocab = vocab;
        _maxInputCharsPerWord = 512;
    }
    return self;
}

- (void)tb_wordPieceTokenizer:(NSArray *)vocab {
 
}

- (NSArray <NSString *> *)tokenize:(NSString *)text {
    NSArray *tokens = [text tb_whiteSpaceTokenize];
    
    NSMutableArray *outputTokens = [NSMutableArray array];
    for (NSString *token in tokens) {
        NSUInteger length = token.length;
        if (length > self.maxInputCharsPerWord) {
            [outputTokens addObject:TB_UNKTOKEN];
            continue;
        }
        
        BOOL isBad = NO;
        NSUInteger start = 0;
        NSMutableArray *subTokens = [NSMutableArray array];
        while (start < length) {
            NSUInteger end = length;
            NSString *cur_substr = nil;
            
            while (start < end) {
                NSString *substr = [token substringWithRange:NSMakeRange(start, end - start)];
                if (start > 0) {
                    substr = [NSString stringWithFormat:@"##%@",substr];
                }
                if ([self.vocab containsObject:substr]) {
                    cur_substr = substr;
                    break;
                }
                end--;
            }
            if (cur_substr == nil) {
                isBad = YES;
                break;
            }
            [subTokens addObject:cur_substr];
            start = end;
        }
        
        if (isBad) {
            [outputTokens addObject:TB_UNKTOKEN];
        }else {
            [outputTokens addObjectsFromArray:subTokens];
        }
    }
    return outputTokens;
}

@end

//
//  TBFullTokenizer.m
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/23.
//

#import "TBFullTokenizer.h"
#import "TBBasicTokenizer.h"
#import "TBWordPieceTokenizer.h"
#import "NSString+TBTokenizer.h"

@interface TBAddedToken: NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL normalized;
@property (nonatomic, assign) BOOL single_word;
@property (nonatomic, assign) BOOL lstrip;
@property (nonatomic, assign) BOOL rstrip;

@end

@implementation TBAddedToken

- (instancetype)init {
    if (self = [super init]) {
        _normalized = YES;
        _single_word = NO;
        _lstrip = NO;
        _rstrip = NO;
    }
    return self;
}

@end

@interface TBFullTokenizer ()

@property (nonatomic, strong) TBBasicTokenizer *basicTokenizer;
@property (nonatomic, strong) TBWordPieceTokenizer *wordPieceTokenizer;

@property (nonatomic, strong) NSArray *vocab;
@property (nonatomic, strong) NSArray *all_special_tokens;
@property (nonatomic, strong) NSDictionary *all_special_tokens_extended;
@property (nonatomic, strong) NSArray *unique_no_split_tokens;

@property (nonatomic, assign) BOOL do_basic_tokenize;
@property (nonatomic, assign) BOOL do_lower_case;
@end

@implementation TBFullTokenizer

- (instancetype)initWithVocab:(NSArray *)vocab {
    if (self = [super init]) {
        _vocab = vocab;
        _basicTokenizer = [[TBBasicTokenizer alloc] init];
        _wordPieceTokenizer = [[TBWordPieceTokenizer alloc] initWithVocab:_vocab];
        _do_basic_tokenize = YES;
        _do_lower_case = YES;
        _all_special_tokens = @[@"[UNK]", @"[SEP]", @"[PAD]", @"[CLS]", @"[MASK]"];
        _unique_no_split_tokens = @[@"[CLS]", @"[MASK]", @"[PAD]", @"[SEP]", @"[UNK]"];
    }
    return self;
}
+ (NSArray<NSString *> *)tokenize:(NSString *)text {
    NSString *labels  = [[NSBundle mainBundle] pathForResource:@"vocab" ofType:@"txt"];
    NSString *dataFile = [NSString stringWithContentsOfFile:labels encoding:NSUTF8StringEncoding error:nil];
    NSArray *dataArr = [dataFile componentsSeparatedByString:@"\n"];
    
    TBFullTokenizer *tokenizer = [[TBFullTokenizer alloc] initWithVocab:dataArr];
    return [tokenizer tokenize:text];
}
- (NSArray <NSString *> *)tokenize:(NSString *)text {
    NSMutableString *letters = [[NSMutableString alloc] init];
    if (self.do_lower_case) {
        NSString *regString = [NSString stringWithFormat:@"(%@)(.+?)",[self.all_special_tokens componentsJoinedByString:@"|"]];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regString options:0 error:nil];
        NSArray *array = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        // 利用数组中的位置将所有符合条件的字符拼接起来
        for (NSTextCheckingResult *result in array) {
            NSRange range = [result range];
            [letters appendString:[text substringWithRange:range]];
        }
        text = text.lowercaseString;
    }
    NSArray *texts = [self tb_splitOnTokens:self.unique_no_split_tokens text:text];
    return texts;
//    return [self _tokenize:text];
}

- (NSArray <NSString *> *)_tokenize:(NSString *)text {
    NSMutableArray *splitTokens = [NSMutableArray array];
    if (self.do_basic_tokenize) {
        for (NSString *token in [self.basicTokenizer tokenize:text never_split:self.all_special_tokens]) {
            if ([self.basicTokenizer.never_split containsObject:token]) {
                [splitTokens addObject:token];
            } else {
                [splitTokens addObjectsFromArray:[self.wordPieceTokenizer tokenize:token]];
            }
        }
    }else {
        splitTokens = [NSMutableArray arrayWithArray:[self.wordPieceTokenizer tokenize:text]];
    }
    return splitTokens;
}

- (NSArray *)tb_splitOnTokens:(NSArray *)tok_list  text:(NSString *)text {
    // whitespaceCharacter
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return @[];
    }
    if (tok_list.count == 0) {
        return @[];
    }
    NSMutableArray *tokenized_text = [NSMutableArray array];
    NSArray *text_list = @[text];
    for (NSString *tok in tok_list) {
        [tokenized_text removeAllObjects];
        for (NSString *sub_text in text_list) {
            if (![self.unique_no_split_tokens containsObject:sub_text]) {
                NSArray *tokenResult = [self tb_splitOnToken:tok text:sub_text];
                [tokenized_text addObjectsFromArray:tokenResult];
            }else {
                [tokenized_text addObject:sub_text];
            }
        }
        text_list = [tokenized_text copy];
    }
    NSMutableArray * add = [NSMutableArray array];
    for (NSString *token in tokenized_text) {
        if ([self.unique_no_split_tokens containsObject:token]) {
            [add addObject:token];
        }else {
            [add addObjectsFromArray:[self _tokenize:token]];
        }
    }
    return  [add copy];
}

- (NSArray *)tb_splitOnToken:(NSString *)tok  text:(NSString *)text {
    NSMutableArray *result = [NSMutableArray array];
    id tok_extended = self.all_special_tokens_extended[tok];
    NSArray *split_text = [text componentsSeparatedByString:tok];
    NSMutableString *full_word = [NSMutableString string];
    for (int i = 0; i < split_text.count; i++) {
        NSString *sub_text = split_text[i];
        if ([tok_extended isMemberOfClass:[TBAddedToken class]]) {
            
        }else {
            // We strip left and right by default
            if (i < split_text.count) {
                sub_text = [sub_text tb_rstrip];
            }else {
                sub_text = [sub_text tb_lstrip];
            }
        }
        
        if (i == 0 && [sub_text isEqualToString:@" "]) {
            [result addObject:tok];
        } else if ( i == split_text.count - 1 && ![sub_text isEqualToString:@" "]) {
            [result addObject:sub_text];
        } else {
            if (![sub_text isEqualToString:@" "]) {
                [result addObject:sub_text];
            }
            [result addObject:tok];
        }
    }
    return  [result copy];
}

- (NSArray <NSNumber *> *)convertTokensToIds:(NSArray *)tokens {
    NSMutableArray *outputIds = [NSMutableArray array];
    
    for (NSString *token in tokens) {
        [outputIds addObject:[NSNumber numberWithInteger:[self.vocab indexOfObject:token]]];
    }
    return outputIds;
}

@end

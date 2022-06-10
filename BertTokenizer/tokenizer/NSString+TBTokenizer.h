//
//  NSString+TBTokenizer.h
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TBTokenizer)

//根据空格分割
- (NSArray <NSString *> *)tb_whiteSpaceTokenize;
//根据特殊字符分割
- (NSArray <NSString *> *)tb_runSplitOnPunc;
//是否是中文
- (BOOL)tb_isChineseChar;
// 字符是否是中文
- (BOOL)tb_isWhiteSpace;
// 全角转半角
- (NSString *)tb_convertFullWidthToHalfWidth;
// 去右空格
- (NSString *)tb_rstrip;
// 去左空格
- (NSString *)tb_lstrip;
// 去除前后空格
- (NSString *)tb_strip;
// 根据正则匹配到的字符组合成新的字符串
- (NSString *)tb_getLettersWithRegularExpression:(NSString *)expr;
// 字符串分割成字符数组
- (NSMutableArray <NSString *> *)tb_split;
// 字符是否是英文
- (BOOL)tb_isEnglishWord;
// 把字符串的非中文去除
- (NSString *)tb_keepChineseOnly;

@end

NS_ASSUME_NONNULL_END

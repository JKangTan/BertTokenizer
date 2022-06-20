//
//  TBBasicTokenizer.m
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/23.
//

#import "TBBasicTokenizer.h"
#import "NSString+TBTokenizer.h"
@interface TBBasicTokenizer ()

@end


@implementation TBBasicTokenizer

- (NSArray <NSString *> *)tokenize:(NSString *)text never_split:(NSArray *)neverSplit {
    self.never_split = [neverSplit copy];
    NSString *cleanText = [self tb_cleanText:text];
    NSString *chineseTest = [self tb_tokenizeChineseText:cleanText];
    NSArray <NSString *> *origToken = [self tb_whiteSpaceTokenize:chineseTest];
    
    NSMutableString *str = [NSMutableString string];
    for (NSString *token in origToken) {
        NSString *aToken = token;
        if ([aToken isEqualToString:@""] || aToken == nil) {
            continue;
        }
        if (![neverSplit containsObject:aToken]) {
            if (self.doLowerCase) {
                aToken = aToken.lowercaseString;
            }else if (true) {
                
            }
        }
        NSArray *res_list = [self tb_runSplitOnPunc:aToken];
        for (NSString *sub in res_list) {
            [str appendFormat:@"%@ ",sub];
        }
    }
    NSArray <NSString *> *resToken = [self tb_whiteSpaceTokenize:str];
    return resToken;
}

- (NSArray <NSString *> *)tokenize:(NSString *)text {
    return [self tokenize:text never_split:@[]];
}

- (NSString *)tb_cleanText:(NSString *)text {
    NSRange range = NSMakeRange(0, 1);
    NSMutableString *outString = [NSMutableString string];
    for(int i = 0; i < text.length; i += range.length){
        range = [text rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [text substringWithRange:range];
        if ([character tb_isWhiteSpace]) {
            [outString appendString:@" "];
        } else {
            [outString appendString:character];
        }
    }
    return outString;
}

- (NSString *)tb_tokenizeChineseText:(NSString *)clenText {
    NSRange range = NSMakeRange(0, 1);
    NSMutableString *outString = [NSMutableString string];
    for(int i = 0; i < clenText.length; i += range.length){
        range = [clenText rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [clenText substringWithRange:range];
        if ([self tb_isChineseChar:character]) {
            [outString appendString:@" "];
            [outString appendString:character];
            [outString appendString:@" "];
        } else {
            [outString appendString:character];
        }
        
    }
    return outString;
}


- (NSArray <NSString *> *)tb_whiteSpaceTokenize:(NSString *)text {
    NSString *commentContent = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    NSRegularExpression *regular;
//    regular = [[NSRegularExpression alloc] initWithPattern:@"\\s{1,}"
//                                                               options:NSRegularExpressionCaseInsensitive
//                                                                 error:nil];
//    NSString* result = [regular stringByReplacingMatchesInString:commentContent options:NSMatchingReportProgress  range:NSMakeRange(0, [str length]) withTemplate:@" "];
    return [commentContent componentsSeparatedByString:@" "];
}

- (NSArray <NSString *> *)tb_runSplitOnPunc:(NSString *)token {
    NSMutableArray *result = [NSMutableArray array];
    BOOL startNewWord = true;
    NSRange range = NSMakeRange(0, 1);
    for(int i = 0; i < token.length; i += range.length){
        range = [token rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [token substringWithRange:range];
        BOOL isPunc = [self tb_isPunctuation:character];
        if (isPunc) {
            [result addObject:@[character]];
            startNewWord = true;
        }else {
            if (startNewWord) {
                [result addObject:[NSMutableArray array]];
            }
            startNewWord = false;
            if ([result.lastObject isKindOfClass:NSArray.class]) {
                NSMutableArray *arr = [result.lastObject mutableCopy];
                [arr addObject:character];
                [result replaceObjectAtIndex:result.count-1 withObject:arr];
            }
        }
    }
    NSMutableArray *res = [NSMutableArray array];
    for (NSArray *arr in result) {
        [res addObject:[arr componentsJoinedByString:@""]];
    }
    return [res copy];
}

- (BOOL)tb_isPunctuation:(NSString *)chs {
    NSRange range = [chs rangeOfComposedCharacterSequenceAtIndex:0];
    unichar c;
    [chs getCharacters:&c range:range];
//    NSString *asc_string = @"!\"#$%&'()*+,-./:;<=>?@[\\]^_`";
//    NSString *che_string = @"“”、《》。；【】";
    if ((c>=33 && c<=47) || (c>=58 && c<=64) || (c>=91 && c<=96) || (c>=123 && c<=126)) {
        return YES;
    }
    
    if(ispunct(c)){
        return true;
    }
    return false;
}

-(BOOL)tb_isChineseChar:(NSString *)character
{
    unichar a = [character characterAtIndex:0];
    if( a > 0x4e00 && a < 0x9fff)//判断输入的是否是中文
    {
        return YES;
    }
    return NO;
}

- (BOOL)tb_isWhiteSpace:(NSString *)charater {
    if ([charater isEqualToString:@" "]) {
        return YES;
    }
    return NO;
}

@end

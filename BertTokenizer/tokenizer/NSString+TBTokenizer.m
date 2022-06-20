//
//  NSString+TBTokenizer.m
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/24.
//

#import "NSString+TBTokenizer.h"

@implementation NSString (TBTokenizer)

- (NSArray <NSString *> *)tb_whiteSpaceTokenize {
    NSString *commentContent = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    NSRegularExpression *regular;
//    regular = [[NSRegularExpression alloc] initWithPattern:@"\\s{1,}"
//                                                               options:NSRegularExpressionCaseInsensitive
//                                                                 error:nil];
//    NSString* result = [regular stringByReplacingMatchesInString:commentContent options:NSMatchingReportProgress  range:NSMakeRange(0, [str length]) withTemplate:@" "];
    return [commentContent componentsSeparatedByString:@" "];
}

- (NSArray <NSString *> *)tb_runSplitOnPunc {
    NSMutableArray *result = [NSMutableArray array];
    BOOL startNewWord = true;
    NSRange range = NSMakeRange(0, 1);
    for(int i = 0; i < self.length; i += range.length){
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [self substringWithRange:range];
        if ([self tb_isPunctuation]) {
            [result addObject:@[character]];
            startNewWord = true;
        }else {
            if (startNewWord) {
                [result addObject:@[]];
            }
            startNewWord = false;
            [result addObject:character];
        }
    }
    
    return @[[result componentsJoinedByString:@""]];
}

- (BOOL)tb_isPunctuation {
    NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:0];
    unichar c;
    [self getCharacters:&c range:range];
    if ((c>=33 && c<=47) || (c>=58 && c<=64) || (c>=91 && c<=96) || (c>=123 && c<=126)) {
        return YES;
    }
    
    if(ispunct(c)){
        return true;
    }
    return false;
}

-(BOOL)tb_isChineseWord {
    NSString *match = @"(^[\u4e00-\u9fff\u2A700-\u2CEAF\u3400-\u4DBF\u20000-\u2A6DF\uF900-\uFAFF\u2F800-\u2FA1F]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    BOOL predicateResult = [predicate evaluateWithObject:self];
    const char * cStringFromstr=[self UTF8String];
    
//    NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:0];
//    int c;
//    [self getCharacters:&c range:range];
//    if( c > 0x4e00 && c < 0x9fff)//判断输入的是否是中文
//    {
//        NSLog(@"is chinese");
//    }
    return predicateResult || strlen(cStringFromstr)>3;
}

- (BOOL)tb_isWhiteSpace {
//    const char * cStringFromstr=[self UTF8String];
    if (isspace([self characterAtIndex:0])) {
        return YES;
    }
    return NO;
}

- (NSString *)tb_convertFullWidthToHalfWidth{
    NSMutableString *convertedString = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)convertedString,NULL,kCFStringTransformFullwidthHalfwidth,false);
    return convertedString;
}

- (NSString *)tb_rstrip {
    NSRange range = NSMakeRange(0, 1);
    NSMutableString *copy = [self mutableCopy];
    for(unsigned long i = self.length - 1; i >= 0; i--){
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [self substringWithRange:range];
        if ([character isEqualToString:@" "]) {
            copy = [NSMutableString stringWithString:[copy substringToIndex:i]];
        }else {
            break;
        }
    }
    return copy;
}
- (NSString *)tb_strip {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *)tb_lstrip {
    NSRange range = NSMakeRange(0, 1);
    NSString *copy = @"";
    for(int i = 0; i < self.length; i++){
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [self substringWithRange:range];
        if (![character isEqualToString:@" "]) {
            copy = [NSMutableString stringWithString:[self substringFromIndex:i]];
            break;
        }else {
            continue;
        }
    }
    return copy;
}

- (NSString *)tb_getLettersWithRegularExpression:(NSString *)expr {
    NSMutableString *letters = [[NSMutableString alloc] init];
    // 正则
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expr options:0 error:nil];
    NSArray *array = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    // 利用数组中的位置将所有符合条件的字符拼接起来
    for (NSTextCheckingResult *result in array) {
        NSRange range = [result range];
        [letters appendString:[self substringWithRange:range]];
    }
    return [letters copy];
}

- (NSMutableArray <NSString *> *)tb_split {
    NSRange range = NSMakeRange(0, 1);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < self.length; i++) {
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *word = [self substringWithRange:range];
        [result addObject:word];
    }
    return result;
}

- (BOOL)tb_isEnglishWord {
    unichar c = [self characterAtIndex:0];
    if ((97<= c && c <= 122) || (65 <= c && c <= 90) ) {
        return YES;
    }
    return NO;
}
- (NSString *)tb_keepChineseOnly {
    NSString *regExpString  = @"[^\u4e00-\u9fa5]+";
    NSString *template      = @"";
    return [self stringByReplacingOccurrencesOfString:regExpString
                                             withString:template
                                                options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                  range:NSMakeRange (0, self.length)];
}

- (NSString *)tb_replaceWordWithDictionary:(NSDictionary *)dic {
    NSString *mstr = [self mutableCopy];
    for (NSString *key in dic.allKeys) {
        mstr = [self stringByReplacingOccurrencesOfString:key withString:dic[key]];
    }
    return mstr;
}

@end

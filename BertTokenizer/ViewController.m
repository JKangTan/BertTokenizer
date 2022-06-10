//
//  ViewController.m
//  BertTokenizer
//
//  Created by 谭健康 on 2022/5/23.
//

#import "ViewController.h"
#import "TBFullTokenizer.h"
#import "NSString+TBTokenizer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *newarr = [@[@1,@5,@4,@6,@2,@3] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 intValue] < [obj2 intValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    NSLog(@"%@", newarr);
//    [self loadVocab];
//    [self testDate];
}

- (void)testDate {
    NSString *string = @"ss2021-05-13 11:23:20";
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:&error];
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeDate) {
            NSDate *date = [match date];
            NSDateFormatter *formatter;
            NSString        *dateString;
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
            dateString = [formatter stringFromDate:date];
            NSLog(@"Date: %@",dateString);
        }}
}

- (void)testRegExp {

    NSString *r = @"\\d{4}-\\d{2}-\\d{2}至\\d{4}-\\d{2}-\\d{2}";
    
    
    NSString *orginalString = @"'2020-06-05至2030-06-05'";
    NSString *regExpString  = @"[^\u4e00-\u9fa5]+";
    NSString *template      = @"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options: NSRegularExpressionCaseInsensitive error:nil];
    if(regex!=nil){
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:orginalString options:0 range: NSMakeRange(0, [orginalString length])];
        if(firstMatch){
            NSRange resultRange = [firstMatch rangeAtIndex: 0];
            // 截取数据
            NSString *result = [orginalString substringWithRange:resultRange];
            NSLog(@"%@",result);
        }
    }

    NSString *result =
    [orginalString stringByReplacingOccurrencesOfString:r
                                             withString:template
                                                options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                  range:NSMakeRange (0, orginalString.length)];
    NSLog (@"\nsearchStr = %@\nresultStr = %@", orginalString, result);
}



- (void)touches
{
    NSString *str = @"证  号 340827199109251325";
    // 4.手机号码匹配
    NSString *pattern = @"\\s?";

    NSError *error = nil;
 /*
typedef NS_OPTIONS(NSUInteger, NSRegularExpressionOptions) {
   NSRegularExpressionCaseInsensitive             = 1 << 0, //不区分字母大小写的模式
   NSRegularExpressionAllowCommentsAndWhitespace  = 1 << 1, //忽略掉正则表达式中的空格和#号之后的字符
   NSRegularExpressionIgnoreMetacharacters        = 1 << 2, //将正则表达式整体作为字符串处理
   NSRegularExpressionDotMatchesLineSeparators    = 1 << 3, //允许.匹配任何字符，包括换行符
   NSRegularExpressionAnchorsMatchLines           = 1 << 4, //允许^和$符号匹配行的开头和结尾
   NSRegularExpressionUseUnixLineSeparators       = 1 << 5, //设置\n为唯一的行分隔符，否则所有的都有效。
   NSRegularExpressionUseUnicodeWordBoundaries    = 1 << 6 //使用Unicode TR#29标准作为词的边界，否则所有传统正则表达式的词边界都有效
};
*/
    NSRegularExpression *regular;
                  
    regular = [[NSRegularExpression alloc] initWithPattern:@"\\s{1,}"
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
     str = [regular stringByReplacingMatchesInString:str options:NSMatchingReportProgress  range:NSMakeRange(0, [str length]) withTemplate:@" "];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (result) {
        for (int i = 0; i<result.count; i++) {
            NSTextCheckingResult *res = result[i];
            NSLog(@"str == %@", [str substringWithRange:res.range]);
        }
    }else{
        NSLog(@"error == %@",error.description);
    }
}

- (void)C_String {
    NSString *s = @"趯 𬺓罍鼱鳠鳡鳣爟爚灈韂糵礵鹴皭龢鳤亹籥𫚭玃醾齇觿";
//    s = @"证 号340827199109251325";
    s = @"大傻逼；？】";
    NSRange range = NSMakeRange(0, 1);
    for(int i=0; i<s.length; i+=range.length){
        range = [s rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [s substringWithRange:range];
        NSLog(@"%@",character);
       
        const char *cstr = [character UTF8String];
//        printf("%s,%d",cstr, cstr == " ");
//        char c = [s characterAtIndex:i];
//        printf("ss:%d \n",cstr == '】');
        NSString *asc_string = @"!\"#$%&'()*+,-./:;<=>?@[\\]^_`";
        NSString *che_string = @"“”、《》。；【】";
        printf("contain?::%d\n",[asc_string containsString:character]);
    }
    

    NSLog(@"%@",[@[@"aaa",@"ccc",@"ddd"] componentsJoinedByString:@""]);
}


- (void)loadVocab {
    NSTimeInterval begin = NSDate.timeIntervalSinceReferenceDate;
    NSString *labels  = [[NSBundle mainBundle] pathForResource:@"vocab" ofType:@"txt"];
    NSString *dataFile   = [NSString stringWithContentsOfFile:labels encoding:NSUTF8StringEncoding error:nil];// stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *dataArr = [dataFile componentsSeparatedByString:@"\n"];
    
    TBFullTokenizer *tokenizer = [[TBFullTokenizer alloc] initWithVocab:dataArr];
    NSArray *bert = [tokenizer tokenize:@"证号340827199109251325"];
    NSArray *bert2 = [tokenizer tokenize:@"Driving License of the People's Republic of China "];
    NSArray *bert3 = [tokenizer tokenize:@"有效期限2020-06-05至2030-06-05"];
    NSTimeInterval end = NSDate.timeIntervalSinceReferenceDate;
    NSLog(@"%f",end-begin);
    
    NSString *sepcial_chars = @"āáǎàēéěèêīíǐìōóǒòūúǔùǖǘǚǜü";
    NSString *new_chars = @"aaaaeeeeeiiiioooouuuuuuuuu";
    
    NSRange range = NSMakeRange(0, 1);
    for(int i=0; i<sepcial_chars.length; i++){
        range = [sepcial_chars rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *character = [sepcial_chars substringWithRange:range];
    }
}
@end

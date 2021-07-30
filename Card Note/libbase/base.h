//
//  base.h
//  baseSDK
//
//  Created by 施润 on 29/8/19.
//  Copyright © 2019 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordHelper : NSObject
+ (NSURL *)getDeepLink:(NSString *)word;//获取有道词典deeplink
+ (BOOL)openDeepLink:(NSString *)word;//打开有道词典deeplink
+ (NSURL *)getDetailUrl:(NSString *)word;//获取有道词典webUrl
+ (void)openWordBrowser:(NSString *)word;//打开有道词典webUrl
+ (void)openMore:(NSString *)word;//查看更多，若有词典，则跳转到词典，否则打开web页
@end

@class YDTranslate;

@interface YDOnlineLanguageTool : NSObject
/**
 有道SDK中已经将语言存在数组中，映射关系存在可变字典内，用户可自行重写，也可直接调用
 */
@property(nonatomic, strong)NSArray *streamTransFromLanguage;
@property(nonatomic, strong)NSArray *streamTransToLanguage;
@property(nonatomic, strong)NSArray *streamTransFromCode;
@property(nonatomic, strong)NSArray *streamTransToCode;
@property(nonatomic, strong)NSMutableDictionary *languageStreamTransCode;
@property(nonatomic, strong)NSArray *ASRLanguage;
@property(nonatomic, strong)NSArray *toLanguage;
@property(nonatomic, strong)NSArray *fromLanguage;
@property(nonatomic, strong)NSMutableDictionary *languageFanYiCode;
@property(nonatomic, strong)NSMutableDictionary *languageYuYinCode;
@property(nonatomic, strong)NSArray *textLanguage;
@property(nonatomic, strong)NSArray *textLanguageCode;
@property(nonatomic, copy)NSArray *ocrLanguage;
@property(nonatomic, copy)NSArray *ocrLanguageCode;
@end

@class CLLocation;

/**
 * The `YDTranslateParameters` class is used to attach targeting information to
 * `YDTranslateRequest` objects.
 */

@interface YDTranslateParameters : NSObject

typedef NS_ENUM(NSInteger, YDLanguageType) {
    YDLanguageTypeAuto = 0,
    YDLanguageTypeChinese, //中文
    YDLanguageTypeEnglish, //英文
    YDLanguageTypeJapanese, //日文
    YDLanguageTypeKorean, //韩文
    YDLanguageTypeFrench, //法文
    YDLanguageTypeRussian, //俄文
    YDLanguageTypePortuguese, //葡萄牙文
    YDLanguageTypeSpanish, //西班牙文
    YDLanguageTypeVietnamese, //越南文
    YDLanguageTypeChineseT, //中文繁体
    YDLanguageTypeGerman, //德文
    YDLanguageTypeArabic, //阿拉伯文
    YDLanguageTypeIndonesian //印尼文
};

/** @name Creating a Targeting Object */

/**
 * Creates and returns an empty YDTranslateParameters object.
 *
 * @return A newly initialized YDTranslateParameters object.
 */
+ (YDTranslateParameters *)targeting;

@property (nonatomic, copy) NSString *source;

@property (nonatomic, assign) YDLanguageType from;

@property (nonatomic, assign) YDLanguageType to;
//发音选项
@property (nonatomic, copy) NSString * voice;

@property (nonatomic, copy) NSString *textFrom;

@property (nonatomic, copy) NSString *textTo;

@property (nonatomic, assign) BOOL offLine;

@end

@interface YDTranslate : NSObject

@property (retain,nonatomic)NSString *query;
@property (retain,nonatomic)NSString *usPhonetic;
@property (retain,nonatomic)NSString *ukPhonetic;
@property (retain,nonatomic)NSString *phonetic;

@property (retain,nonatomic)NSArray *translation;
@property (retain,nonatomic)NSArray *explains;
@property (retain,nonatomic)NSArray *webExplains;

@property (retain,nonatomic)NSString *from;
@property (retain,nonatomic)NSString *to;
@property (retain,nonatomic)NSString *l; //针对国内请求，服务器新增l字段（查询from和to）
@property (retain,nonatomic)NSDictionary *webdict;//针对海外请求，服务器新增webdict字段（词典海外web页面）
@property (retain,nonatomic)NSDictionary *dict;
@property (retain,nonatomic)NSString *tspeakurl;
@property (retain,nonatomic)NSString *speakurl;
@property (retain,nonatomic)NSString *UKSpeakurl;//原始词英音（针对英语查询）
@property (retain,nonatomic)NSString *USSpeakurl;//原始词美音（针对英语查询）
@property (assign,atomic)int errorCodes;

@property (retain,nonatomic)NSArray *wfs; // 不知道wfs是什么的缩写，它的含义是变形词，里面包括复数、比较级、最高级、过去式这些变形
@property (retain,nonatomic)NSString *json; // 原始json数据
- (void)openMore;
- (void)formData;

@end

@interface YDWebExplain : NSObject

@property (retain,nonatomic)NSArray *value;
@property (retain,nonatomic)NSString *key;

- (void)formData:(NSDictionary *) dict;
@end

@interface YDWfExplain : NSObject

@property (retain,nonatomic)NSArray *name;
@property (retain,nonatomic)NSString *value;

- (void)formData:(NSDictionary *) dict;
@end


#pragma mark - 全局设置
@interface YDTranslateInstance : NSObject

+ (YDTranslateInstance*)sharedInstance;
- (BOOL)checkAppkey;

@property (nonatomic, copy) NSString *appKey;


/**
 有道SDK的数据库存储路径，默认为document路径
 */
@property (nonatomic, copy) NSString *ydDBPath;
@property (nonatomic, assign) BOOL isHaiWai;
@property (nonatomic, assign) BOOL isTestMode;
@end

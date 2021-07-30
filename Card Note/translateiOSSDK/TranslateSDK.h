//
//  FanYiSDK.h
//  FanYiSDK
//
//  Created by 白静 on 11/18/16.
//  Copyright © 2016 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "base.h"


@class YDTranslate;
@class YDTranslateRequest;
@class YDTranslateParameters;


#pragma mark - 在线查词
typedef void(^YDTranslateRequestHandler)(YDTranslateRequest *request,
                                         YDTranslate *translte,
                                         NSError *error) ;

@interface YDTranslateRequest : NSObject

@property (nonatomic, strong) YDTranslateParameters *translateParameters;
@property (nonatomic, strong) NSArray *supportLanguages;

+ (YDTranslateRequest *)request;

//查询
- (void)lookup:(NSString *) input WithCompletionHandler:(YDTranslateRequestHandler)handler;
//词库初始化，词库放工程中
- (BOOL) initOffline;
//词库初始化，指定词库目录
- (BOOL) initOfflineWithPath:(NSString *)path;
@end

@class CLLocation;

#pragma mark - 在线语音翻译
@class YDSpeechOnlineParam, YDSpeechOnlineRequest;

typedef void(^YDSpeechOnlineRequestHandler)(YDSpeechOnlineRequest *request,NSDictionary *info, NSError *error) ;

@interface YDSpeechOnlineRequest : NSObject
@property (nonatomic, strong) YDSpeechOnlineParam *param;
+ (instancetype)request;
//查询
- (void)lookup:(NSString *)input WithCompletionHandler:(YDSpeechOnlineRequestHandler)handler;
@end

@interface YDSpeechOnlineParam : NSObject
/* 源语言 */
@property (nonatomic, copy) NSString *from;
/* 目标语言 */
@property (nonatomic, copy) NSString *to;
/* 采样率 */
@property (nonatomic, copy) NSString *rate;
/* 声道数，仅支持单声道，请填写固定值1 */
@property (nonatomic, copy) NSString *channel;
/* 翻译结果发音 */
@property (nonatomic, copy) NSString *voice;
+ (instancetype)param;
@end



#pragma mark - 在线图片翻译
@interface YDOCRTransParameter : NSObject
/* 文件上传类型，目前支持base64（1）和图片上传方式（2） */
@property (nonatomic, copy) NSString *type;
/* 源语言 */
@property (nonatomic, copy) NSString *from;
/* 目标语言 */
@property (nonatomic, copy) NSString *to;
///  服务端渲染翻译结果
@property (nonatomic, assign) BOOL serverRenderImage;
+ (instancetype)param;
@end

@class YDOCRTransRequest, YDOCRTransParameter;

typedef void(^YDOCRTransRequestHandler)(YDOCRTransRequest *request,NSDictionary *result, NSError *error) ;

@interface YDOCRTransRequest : NSObject
@property (nonatomic, strong) YDOCRTransParameter *param;
+ (instancetype)request;
//查询
- (void)lookup:(NSString *)input WithCompletionHandler:(YDOCRTransRequestHandler)handler;
@end

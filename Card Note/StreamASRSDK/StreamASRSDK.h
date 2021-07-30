//
//  FanYiSDK.h
//  FanYiSDK
//
//  Created by 白静 on 11/18/16.
//  Copyright © 2016 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "base.h"

#pragma mark - 获取流式语音识别支持的域名
@interface YDASRDomainRequest : NSObject
/* 所支持的域名列表 */
@property (nonatomic, copy, readonly) NSArray *domains;
/* 匹配的域名, 也可根据域名列表自行匹配 */
@property (nonatomic, copy, readonly) NSString *matchDomain;

+ (instancetype)sharedInstance;

/*
 查询支持的域名
 可根据 completion 中返回的数据自行处理
 **/
- (void)lookupCompletion:(void(^)(NSDictionary *, NSError *))completion;

@end

#pragma mark - 在线流式语音识别
@interface YDSpeechRecognizerParam : NSObject
/* 源语言类型,目前支持两种,中文:@"zh-CHS",英文:@"en" */
@property (nonatomic, copy) NSString *langType;
/* 语音文件格式,pcm、wav;默认wav */
@property (nonatomic, copy) NSString *format;
/* 采样率 默认16000 */
@property (nonatomic, copy) NSString *rate;
/* 长/短语音标识, 长语音:long, 短语音:short, 默认长语音 */
@property (nonatomic, copy) NSString *durationType;
/*
 前端点静音检测时长: 即开启识别后用户一直不说话持续多长时间判定为前端点；
 单位为 ms，默认值为 2000
 要求设置为 200 的倍数
 最小值为 1000
 检测到前端点时通过 `- (void)onConstantlyQuietIsBOS:(BOOL)isBOS;` 方法回调
 */
@property (nonatomic, assign) NSInteger vadBOS;
/*
 后端点静音检测时长: 即用户停止说话持续多长时间判定为后端点；
 单位为 ms，默认值为 2000
 要求设置为 200 的倍数
 最小值为 1000
 检测到后端点时通过 `- (void)onConstantlyQuietIsBOS:(BOOL)isBOS;` 方法回调
 */
@property (nonatomic, assign) NSInteger vadEOS;
+ (instancetype)param;
@end

@class YDSpeechRecognizerParam;
@protocol YDSpeechRecognizerDelegate;

@interface YDSpeechRecognizer : NSObject

/* 参数 */
@property (nonatomic, strong) YDSpeechRecognizerParam *param;

/* 接收识别回调的代理对象 */
@property (nonatomic, weak) id<YDSpeechRecognizerDelegate> delegate;

/* 是否正在识别 */
@property (nonatomic, readonly, assign) BOOL isListening;

/* 配置域名 */
@property (nonatomic, copy) NSString *domain;

/**
 获取 YDSR 单例
 
 @return YDSR 单例
 */
+ (instancetype)sharedRecognizer;

/**
 设置代理回调队列，建议设置为串行队列。
 不设置的话默认主队列回调。
 */
- (void)setDelegateOperationQueue:(NSOperationQueue *)delegateOperationQueue;

/**
 开始识别
 涉及网络连接等过程，此处为同步方法，会快速返回
 是否成功开启的结果在代理中接收
 */
- (void)startListening;

/**
 停止识别
 主动结束当前会话时使用，未来得及返回的结果仍然会后续返回
 */
- (void)stopListening;

/**
 取消本次识别
 未来得及返回的识别结果不再继续返回
 */
- (void)cancel;

/**
 销毁识别单例，长时间不使用应调用此销毁方法
 */
- (void)destory;

@end


/**
 语音识别代理协议，回调语音识别过程中各种状态、数据
 */
@protocol YDSpeechRecognizerDelegate <NSObject>

@required

/**
 开始录音回调
 调用了`startListening`之后，正常开始录音则回调此方法，否则回调`onCompleted:`
 */
- (void)onBeginOfSpeech;

/**
 识别结束回调
 
 @param speechError error为空时表示用户调用 cancel 正常结束，否则发生错误
 错误码： 1201 ： 网络连接失败
 1202 ： 音频录制开启失败
 1203 ： 网络断开
 */
- (void)onCompleted:(nullable NSError *)speechError;

/**
 识别结果的回调
 
 在识别过程中会回调多次
 
 @param result 识别结果
 @param isLast 是否是本句最终结果
 */
- (void)onResults:(NSDictionary *)result isLast:(BOOL)isLast;

@optional

/**
 音量变化回调
 
 @param volume 音量数值
 */
- (void)onVolumeChanged:(double)volume;

/**
 正常结束录音回调
 调用了`stopListening` 正常结束则回调此方法，否则回调`onCompleted:`
 */
- (void)onEndOfSpeech;

/**
 
 取消识别回调
 调用了`cancel`之后，会回调此方法，在调用了 cancel 方法和回调 onCompleted 之前会有一个短暂
 间隔，您可以在此方法中实现对这段时间的界面显示。
 */
- (void)onCancel;

/**
 检测到连续静音的回调
 
 @param isBOS 此次连续静音是否是前端点（开启识别后就一直静音）
 否则是后端点（用户自上一次说话后已经多久没说话）
 */
- (void)onConstantlyQuietIsBOS:(BOOL)isBOS;

@end

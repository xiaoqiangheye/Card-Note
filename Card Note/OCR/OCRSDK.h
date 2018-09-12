//
//  FanYiSDK.h
//  FanYiSDK
//
//  Created by 白静 on 11/18/16.
//  Copyright © 2016 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - 全局设置
/*
@interface YDTranslateInstance : NSObject

+ (YDTranslateInstance*) sharedInstance;
- (BOOL) checkAppkey;

@property (nonatomic, copy) NSString *appKey;

@end
*/

#pragma mark - 在线OCR
@class YDOCRRequest, YDOCRResult, YDOCRParameter;

typedef void(^YDOCRRequestHandler)(YDOCRRequest *request,YDOCRResult *result, NSError *error) ;

@interface YDOCRRequest : NSObject
@property (nonatomic, strong) YDOCRParameter *param;
+ (instancetype)request;
//查询
- (void)lookup:(NSString *)input WithCompletionHandler:(YDOCRRequestHandler)handler;
@end

@interface YDOCRParameter : NSObject
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *langType;
@property (nonatomic, copy) NSString *detectType;
+ (instancetype)param;
@end

@interface YDOCRResult : NSObject
@property (nonatomic, copy) NSString *orientation;
@property (nonatomic, copy) NSString *textAngle;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) NSArray *regions; //YDOCRRegion数组
+ (instancetype)initWithDict:(NSDictionary *)info;
@end

@interface YDOCRRegion : NSObject
@property (nonatomic, copy) NSString *boundingBox;
@property (nonatomic, strong) NSArray *lines;//YDOCRLine数组
+ (instancetype)initWithDict:(NSDictionary *)info;
@end

@interface YDOCRLine : NSObject
@property (nonatomic, copy) NSString *boundingBox;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSArray *words;//YDOCRWord数组
+ (instancetype)initWithDict:(NSDictionary *)info;
@end

@interface YDOCRWord : NSObject
@property (nonatomic, copy) NSString *boundingBox;
@property (nonatomic, copy) NSString *text;
+ (instancetype)initWithDict:(NSDictionary *)info;

@end

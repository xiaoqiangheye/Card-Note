//
//  FanYiSDK.h
//  FanYiSDK
//
//  Created by 白静 on 11/18/16.
//  Copyright © 2016 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "base.h"
#pragma mark - 全局设置


#pragma mark - 在线OCR
@class YDOCRRequest, YDOCRParameter;

typedef void(^YDOCRRequestHandler)(YDOCRRequest *request,NSDictionary *result, NSError *error) ;

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

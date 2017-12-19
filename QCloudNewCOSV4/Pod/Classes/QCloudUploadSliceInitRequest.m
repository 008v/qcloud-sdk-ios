//
//  UploadSliceInit.m
//  UploadSliceInit
//
//  Created by tencent
//  Copyright (c) 2015年 tencent. All rights reserved.
//
//   ██████╗  ██████╗██╗      ██████╗ ██╗   ██╗██████╗     ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗         ██╗      █████╗ ██████╗
//  ██╔═══██╗██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║         ██║     ██╔══██╗██╔══██╗
//  ██║   ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║         ██║     ███████║██████╔╝
//  ██║▄▄ ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║         ██║     ██╔══██║██╔══██╗
//  ╚██████╔╝╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗    ███████╗██║  ██║██████╔╝
//   ╚══▀▀═╝  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═════╝
//
//
//                                                                              _             __                 _                _
//                                                                             (_)           / _|               | |              | |
//                                                          ___  ___ _ ____   ___  ___ ___  | |_ ___  _ __    __| | _____   _____| | ___  _ __   ___ _ __ ___
//                                                         / __|/ _ \ '__\ \ / / |/ __/ _ \ |  _/ _ \| '__|  / _` |/ _ \ \ / / _ \ |/ _ \| '_ \ / _ \ '__/ __|
//                                                         \__ \  __/ |   \ V /| | (_|  __/ | || (_) | |    | (_| |  __/\ V /  __/ | (_) | |_) |  __/ |  \__
//                                                         |___/\___|_|    \_/ |_|\___\___| |_| \___/|_|     \__,_|\___| \_/ \___|_|\___/| .__/ \___|_|  |___/
//    ______ ______ ______ ______ ______ ______ ______ ______                                                                            | |
//   |______|______|______|______|______|______|______|______|                                                                           |_|
//








#import "QCloudUploadSliceInitRequest.h"
#import "QCloudObjectModel.h"
#import "QCloudSignatureFields.h"
#import <QCloudCore/QCloudCore.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import "QCloudCOSV4Error.h"
#import "QCloudUploadSliceInitRequest+Custom.h"
#import "QCloudUploadSliceInitResult.h"
#import "QCloudSHAPart.h"

@class QCloudSHAPart;

NS_ASSUME_NONNULL_BEGIN
@implementation QCloudUploadSliceInitRequest
- (void) dealloc
{
}
-  (instancetype) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}
- (void) configureReuqestSerializer:(QCloudRequestSerializer *)requestSerializer  responseSerializer:(QCloudResponseSerializer *)responseSerializer
{
    NSArray* customRequestSerilizers = @[
                                        QCloudURLFuseSimple,
                                        QCloudFuseParamtersASMultiData,
                                        QCloudFuseMultiFormData,
                                        ];

    NSArray* responseSerializers = @[
                                    QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), @(201), @(202), @(203), @(204), @(205), @(206), @(207), @(208), @(226),nil], QCloudCOSV4Error.class),
                                    QCloudResponseJSONSerilizerBlock,

                                    QCloudResponseCOSNormalRSPSerilizerBlock,

                                    QCloudResponseObjectSerilizerBlock([QCloudUploadSliceInitResult class])
                                    ];
    [requestSerializer setSerializerBlocks:customRequestSerilizers];
    [responseSerializer setSerializerBlocks:responseSerializers];

    requestSerializer.HTTPMethod = @"post";
}



- (BOOL) buildRequestData:(NSError *__autoreleasing *)error
{
    if (![super buildRequestData:error]) {
        return NO;
    }
    if (!self.bucket || ([self.bucket isKindOfClass:NSString.class] && ((NSString*)self.bucket).length == 0)) {
        if (error != NULL) {
            *error = [NSError qcloud_errorWithCode:QCloudNetworkErrorCodeParamterInvalid message:[NSString stringWithFormat:@"paramter[bucket] is invalid (nil), it must have some value. please check it"]];
            return NO;
        }
    }
    NSURL* __serverURL = [self.runOnService.configuration.endpoint serverURLWithBucket:self.bucket appID:self.runOnService.configuration.appID];
    self.requestData.serverURL = __serverURL.absoluteString;
    [self.requestData setValue:__serverURL.host forHTTPHeaderField:@"Host"];
    if (!self.fileName || ([self.fileName isKindOfClass:NSString.class] && ((NSString*)self.fileName).length == 0)) {
        if (error != NULL) {
            *error = [NSError qcloud_errorWithCode:QCloudNetworkErrorCodeParamterInvalid message:[NSString stringWithFormat:@"paramter[fileName] is invalid (nil), it must have some value. please check it"]];
            return NO;
        }
    }
    [self.requestData setNumberParamter:@(self.fileSize) withKey:@"filesize"];
    [self.requestData setNumberParamter:@(self.sliceSize) withKey:@"slice_size"];
    [self.requestData setParameter:self.bizAttribute withKey:@"biz_attr"];
    [self.requestData setNumberParamter:@(self.insertOnly) withKey:@"insertOnly"];
    if (!self.sha || ([self.sha isKindOfClass:NSString.class] && ((NSString*)self.sha).length == 0)) {
        if (error != NULL) {
            *error = [NSError qcloud_errorWithCode:QCloudNetworkErrorCodeParamterInvalid message:[NSString stringWithFormat:@"paramter[sha] is invalid (nil), it must have some value. please check it"]];
            return NO;
        }
    }
    [self.requestData setParameter:self.sha withKey:@"sha"];
    if (!self.uploadParts) {
        if (error != NULL) {
            *error = [NSError qcloud_errorWithCode:QCloudNetworkErrorCodeParamterInvalid message:[NSString stringWithFormat:@"paramter[uploadParts] is invalid (nil), it must have some value. please check it"]];
            return NO;
        }
    }
      [self.requestData setParameter:[self.uploadParts qcloud_modelToJSONObject]  withKey:@"uploadparts"];
    [self.requestData setParameter:@"upload_slice_init" withKey:@"op"];
    NSMutableArray* __pathComponents = [NSMutableArray arrayWithArray:self.requestData.URIComponents];
    if (self.runOnService.configuration.appID) {
        [__pathComponents addObject:self.runOnService.configuration.appID];
    }
    if(self.bucket) [__pathComponents addObject:self.bucket];
    if(self.directory) [__pathComponents addObject:self.directory];
    if(self.fileName) [__pathComponents addObject:self.fileName];
    self.requestData.URIComponents = __pathComponents;
    if (![self customBuildRequestData:error]) return NO;
    return YES;
}
- (void) setFinishBlock:(void (^)(QCloudUploadSliceInitResult* result, NSError * error))QCloudRequestFinishBlock
{
    [super setFinishBlock:QCloudRequestFinishBlock];
}

- (QCloudSignatureFields*) signatureFields
{
    QCloudSignatureFields* fileds = [QCloudSignatureFields new];

    fileds.bucket = self.bucket;
    fileds.directory = self.directory;
    fileds.fileName = self.fileName;
    return fileds;
}

@end
NS_ASSUME_NONNULL_END

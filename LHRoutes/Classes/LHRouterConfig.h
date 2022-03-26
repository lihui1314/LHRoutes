//
//  LHRouterConfig.h
//  Router
//
//  Created by 李辉 on 2022/3/26.
//

#import <Foundation/Foundation.h>
#import "LHRDefines.h"
NS_ASSUME_NONNULL_BEGIN

#define LHRouterConfigInstance [LHRouterConfig shareInstance]

@interface LHRouterConfig : NSObject
+ (instancetype)shareInstance;


/// 注册跳转host
- (void)registerJumpHost:(NSString *)host;

/// 注册服务通信host
- (void)registerServiceHost:(NSString *)host;

- (void)unregisterHost:(NSString *)host;
- (LHRouterHostType)getRouterHostType:(NSString *)host;

@end

NS_ASSUME_NONNULL_END

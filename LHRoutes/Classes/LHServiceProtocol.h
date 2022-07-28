//
//  LHServiceProtocol.h
//  Router
//
//  Created by 李辉 on 2022/3/21.
//

#import <Foundation/Foundation.h>
#import "LHRDefines.h"
NS_ASSUME_NONNULL_BEGIN

@protocol LHServiceProtocol <NSObject>
+ (BOOL)isSingleton;
+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END

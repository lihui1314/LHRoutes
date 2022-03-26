//
//  LHServiceManager.h
//  Router
//
//  Created by 李辉 on 2022/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHServiceManager : NSObject

+ (instancetype)shareInstance;

- (void)unregisterService:(NSString *)serviceName;
- (void)registerService:(NSString *)serviceName shouldCache:(BOOL)shouldCache;
- (id)getService:(NSString *)serviceName;
@end

NS_ASSUME_NONNULL_END

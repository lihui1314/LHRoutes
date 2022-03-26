//
//  LHServiceProtocol.h
//  Router
//
//  Created by 李辉 on 2022/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    const char *serviceName;
    const BOOL shouleCache;
}LHRegisterServiceStruct;

#define LHR_SERVICE_EXPORT(serviceName,shouleCache) \
__attribute__((used, section("__DATA , lh_sv_export"))) \
static const LHRegisterServiceStruct __##lh_sv_export_##serviceName##__ = {#serviceName,shouleCache};

@protocol LHServiceProtocol <NSObject>
+ (BOOL)isSingleton;
+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END

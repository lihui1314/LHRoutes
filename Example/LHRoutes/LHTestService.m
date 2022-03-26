//
//  LHTestService.m
//  Router
//
//  Created by 李辉 on 2022/3/24.
//

#import "LHTestService.h"
#import "LHServiceProtocol.h"


@interface LHTestService()<LHServiceProtocol>

@end

LHR_SERVICE_EXPORT(LHTestService,YES)
@implementation LHTestService

+ (BOOL)isSingleton {
    return YES;
}

+ (instancetype)shareInstance {
    static LHTestService *__ts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __ts = [[LHTestService alloc] init];
    });
    return __ts;
}

- (int)sum:(int)a b:(int)b {
    return a + b;
}

@end

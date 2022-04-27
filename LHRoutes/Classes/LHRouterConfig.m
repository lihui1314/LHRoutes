//
//  LHRouterConfig.m
//  Router
//
//  Created by 李辉 on 2022/3/26.
//



#import "LHRouterConfig.h"

@interface LHRouterHostElement : NSObject
@property (nonatomic, assign) LHRouterHostType hostType;
@property (nonatomic, copy) NSString *host;

@end

@implementation LHRouterHostElement

@end

@interface LHRouterConfig ()
@property (nonatomic, strong) NSMutableDictionary *confDic;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation LHRouterConfig

+ (instancetype)shareInstance {
    static LHRouterConfig *__config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __config = [[LHRouterConfig alloc] init];
        [__config registerHost:LHRURLHostJumpViewController type:(LHRouterHostTypeJumpVC)];
        [__config registerHost:LHRURLHostCallService type:(LHRouterHostTypeCallService)];
    });
    return __config;
}

- (void)registerJumpHost:(NSString *)host {
    [self registerHost:host type:(LHRouterHostTypeJumpVC)];
}

- (void)registerServiceHost:(NSString *)host {
    [self registerHost:host type:(LHRouterHostTypeCallService)];
}

- (void)registerHost:(NSString *)host type:(LHRouterHostType)type {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    if (!host && ![host isKindOfClass:[NSString class]]) {
        return;
    }
    LHRouterHostElement *element = [[LHRouterHostElement alloc] init];
    element.host = host;
    element.hostType = type;
    [self.confDic setValue:element forKey:host];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)unregisterHost:(NSString *)host {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.confDic setValue:nil forKey:host];
    dispatch_semaphore_signal(self.semaphore);
}

- (LHRouterHostType)getRouterHostType:(NSString *)host {
    LHRouterHostElement *ele = self.confDic[host];
    if (!ele) {
        return LHRouterHostTypeNone;
    }
    return ele.hostType;
}

- (NSMutableDictionary *)confDic {
    if (_confDic == nil) {
        _confDic = [NSMutableDictionary dictionary];
    }
    return _confDic;
}
- (dispatch_semaphore_t)semaphore {
    if (_semaphore == nil) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}
@end

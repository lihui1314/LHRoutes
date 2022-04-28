//
//  LHServiceManager.m
//  Router
//
//  Created by 李辉 on 2022/3/21.
//

#import "LHServiceManager.h"
#import <dlfcn.h>
#include <mach-o/getsect.h>
#import "LHServiceProtocol.h"


static NSString *const kLHServiceName = @"serviceName";
static NSString *const kLHShouleCache = @"shouuldCache";

@interface LHServiceCache: NSObject

+ (instancetype)cache;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *serviceCache;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
- (void)removeService:(NSString *)serviceName;
- (void)addService:(id)service serviceName:(NSString *)serviceName;
- (id)getService:(NSString *)serviceName;

@end

@implementation LHServiceCache

+ (instancetype)cache {
    static LHServiceCache *__cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __cache = [[LHServiceCache alloc] init];
    });
    return __cache;
}

- (void)addService:(id)service serviceName:(NSString *)serviceName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.serviceCache setValue:service forKey:serviceName];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)removeService:(NSString *)serviceName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.serviceCache setValue:nil forKey:serviceName];
    dispatch_semaphore_signal(self.semaphore);
}

- (id)getService:(NSString *)serviceName {
    if (!serviceName && ![serviceName isKindOfClass:[NSString class]]) {
        return nil;
    }
    return self.serviceCache[serviceName];
}

- (NSMutableDictionary<NSString *,id> *)serviceCache {
    if (_serviceCache == nil) {
        _serviceCache = [NSMutableDictionary dictionary];
    }
    return _serviceCache;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return  _semaphore;
}

@end


#pragma mark LHServiceManager
@interface LHServiceManager ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *registeredServiceMap;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation LHServiceManager
static LHServiceManager *__manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[LHServiceManager alloc] init];
    });
    return __manager;
}

- (void)registerService:(NSString *)serviceName shouldCache:(BOOL)shouldCache {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    if (!serviceName && ![serviceName isKindOfClass:[NSString class]]) {
        return;
    }
    NSDictionary *dic = @{kLHServiceName:serviceName,kLHShouleCache:@(shouldCache)};
    [self.registeredServiceMap setValue:dic forKey:serviceName];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)unregisterService:(NSString *)serviceName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    if (!serviceName && ![serviceName isKindOfClass:[NSString class]]) {
        return;
    }
    [self.registeredServiceMap setValue:nil forKey:serviceName];
    [[LHServiceCache cache] removeService:serviceName];
    dispatch_semaphore_signal(self.semaphore);
}

- (id)getService:(NSString *)serviceName {
    id service = [[LHServiceCache cache] getService:serviceName];
    if (service) {
        return  service;
    }
    if (!serviceName && ![serviceName isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (!self.registeredServiceMap[serviceName]) {
        return nil;
    }
    
    Class cls = NSClassFromString(serviceName);
    if (!cls) {
        NSAssert(NO, @"can not find class serviceName");
        return nil;
    }
    if ([cls conformsToProtocol:@protocol(LHServiceProtocol)]) {
        if ([cls respondsToSelector:@selector(isSingleton)]) {
            if ([cls performSelector:@selector(isSingleton)]) {
                if ([cls respondsToSelector:@selector(shareInstance)]) {
                    service = [cls shareInstance];
                } else {
                    service = [[cls alloc] init];
                }
            }
        }
    } else {
        service = [[cls alloc] init];
    }
    NSDictionary *dic = self.registeredServiceMap[serviceName];
    if ([dic[@"shouldCache"] boolValue]) {
        [[LHServiceCache cache] addService:service serviceName:serviceName];
    }
    return service;
}

- (NSMutableDictionary *)registeredServiceMap {
    if (_registeredServiceMap == nil || _registeredServiceMap.count == 0) {
        _registeredServiceMap = [[NSMutableDictionary alloc] init];
        Dl_info info;
        dladdr(&__manager, &info);
#ifdef __LP64__
        uint64_t addr = 0;
        const uint64_t  mach_header = (uint64_t)info.dli_fbase;
        const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "lh_sv_export");
#else
        uint32_t addr = 0;
        const uint32_t mach_header = (uint32_t)info.dli_fbase;
        const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "lh_sv_export");
#endif
        if (section == NULL) {
            return nil;
        }
        for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(LHRegisterServiceStruct)) {
            LHRegisterServiceStruct *service =(LHRegisterServiceStruct *)(mach_header + addr);
            NSString *serviceName = [NSString stringWithUTF8String:service->serviceName];
            BOOL shouldCache = service->shouleCache;
            NSDictionary *dic = @{kLHServiceName:serviceName,kLHShouleCache:@(shouldCache)};
            if (serviceName && NSClassFromString(serviceName)) {
                _registeredServiceMap[serviceName] = dic;
            } else {
                NSAssert(NO, @"%@ is not exist",serviceName);
            }
        }
        
    }
    return _registeredServiceMap;
}

-(dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}

@end

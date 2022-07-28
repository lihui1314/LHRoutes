//
//  LHRPageManager.m
//  LHRoutes
//
//  Created by 李辉 on 2022/7/28.
//

#import "LHRPageManager.h"
#import <dlfcn.h>
#include <mach-o/getsect.h>
#import "LHRDefines.h"

@interface LHRPageManager ()
@property (nonatomic, copy) NSDictionary *registeredPageMap;
@end

@implementation LHRPageManager

static LHRPageManager *__manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[LHRPageManager alloc] init];
    });
    return  __manager;
}

- (Class)getPageCls:(NSString *)key {
    NSString *clsName = self.registeredPageMap[key];
    if (clsName != nil) {
        Class cls =  NSClassFromString(clsName);
        if (cls) {
            return cls;
        }
        return  nil;
    }
    NSAssert(NO, @"%@ is not registered",key);
    return  nil;
}

- (NSDictionary *)registeredPageMap {
    if (_registeredPageMap) {
        return _registeredPageMap;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    Dl_info info;
    dladdr(&__manager, &info);
#ifdef __LP64__
    uint64_t addr = 0;
    const uint64_t  mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "lh_pg_export");
#else
    uint32_t addr = 0;
    const uint32_t mach_header = (uint32_t)info.dli_fbase;
    const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "lh_pg_export");
#endif
    if (section == NULL) {
        return nil;
    }
    for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(LHRegisterPageStruct)) {
        LHRegisterPageStruct *page =(LHRegisterPageStruct *)(mach_header + addr);
        NSString *pageKey = [NSString stringWithUTF8String:page->pageKey];
        NSString *pageName = [NSString stringWithUTF8String:page->pageName];
        
        if (pageName && NSClassFromString(pageName)) {
            dic[pageKey] = pageName;
        } else {
            NSAssert(NO, @"%@ is not exist",pageName);
        }
    }
    _registeredPageMap = [dic copy];
    return _registeredPageMap;
}

@end

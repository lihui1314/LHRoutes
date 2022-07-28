//
//  LHRDefines.h
//  Router
//
//  Created by 李辉 on 2022/3/19.
//

#import <Foundation/Foundation.h>

typedef struct {
    const char *pageKey;
    const char *pageName;
}LHRegisterPageStruct;

#define LHR_PAGE_EXPORT(pageKey,pageName) \
__attribute__((used, section("__DATA , lh_pg_export"))) \
static const LHRegisterPageStruct __##lh_pg_export##pageKey##__ = {#pageKey,#pageName};



typedef struct {
    const char *serviceName;
    const BOOL shouleCache;
}LHRegisterServiceStruct;

#define LHR_SERVICE_EXPORT(serviceName,shouleCache) \
__attribute__((used, section("__DATA , lh_sv_export"))) \
static const LHRegisterServiceStruct __##lh_sv_export_##serviceName##__ = {#serviceName,shouleCache};


typedef NS_ENUM(NSInteger, LHRouterHostType) {
    LHRouterHostTypeJumpVC = 1,
    LHRouterHostTypeCallService,
    LHRouterHostTypeNone
};

typedef NS_ENUM(NSInteger,LHVCJumpMode ) {
    LHVCJumpModePush = 1,
    LHVCJumpModeMode
};

extern NSString *const LHRURLHostJumpViewController;
extern NSString *const LHRURLHostCallService;
extern NSString *const LHRURLFragmentViewControlerEnterModePush;
extern NSString *const LHRURLFragmentViewControlerEnterModeModal;
extern NSString *const LHRURLJumpViewControllerAnimatedYES;
extern NSString *const LHRURLJumpViewControllerAnimatedNO;

//
//  LHRDefines.h
//  Router
//
//  Created by 李辉 on 2022/3/19.
//

#import <Foundation/Foundation.h>

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

//
//  LHRouter.m
//  Router
//
//  Created by 李辉 on 2022/3/18.
//

#import "LHRouter.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LHServiceManager.h"
#import "LHRPageManager.h"
#import "LHRouterConfig.h"

@implementation LHRouter

#pragma mark -public
+ (void)openURL:(NSURL *)URL {
    [self openURL:URL withParams:nil];
}

+ (void)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, id> *)params {
    [self openURL:URL withParams:params callBack:nil];
}
+ (void)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *,id> *)params
       callBack:(void (^)(NSString *, id, id))callBack {
    if (![self canOpenURL:URL]) {
        return;
    }
    NSDictionary *qDic = [self queryParamsWithURL:URL];
    NSMutableDictionary *fianlParams = @{}.mutableCopy;
    [fianlParams addEntriesFromDictionary:params];
    [fianlParams addEntriesFromDictionary:qDic];
    switch ([LHRouterConfigInstance getRouterHostType:URL.host]) {
        case LHRouterHostTypeJumpVC:{
            [self jumpJumpViewControllerWithURL:URL params:fianlParams callBack:callBack];
        }
            break;
        case LHRouterHostTypeCallService:{
            [self callService:URL withParams:params callBack:callBack];
        }
            break;
            
        case LHRouterHostTypeNone:{
            NSAssert(NO, @"host did not register");
        }
            break;
        default:
            break;
    }
}

#pragma mark -private
+ (BOOL)canOpenURL:(NSURL *)URL {
    if (URL.scheme.length == 0) {
        return NO;
    }
    LHRouterHostType type = [LHRouterConfigInstance getRouterHostType:URL.host];
    if (type == LHRouterHostTypeJumpVC) {
        if (URL.pathComponents.count >= 2) {
            NSString *key = URL.pathComponents[1];
            Class vcClass = [[LHRPageManager shareInstance] getPageCls:key];
            if (vcClass) {
                if (![vcClass isSubclassOfClass:[UIViewController class]]) {
                    NSAssert(NO, @"%@ class should be subclass of class UIViewController",NSStringFromClass(vcClass));
                    return NO;
                }
            } else {
                return NO;
            }
            return YES;
        }
        return NO;
    } else if(type == LHRouterHostTypeCallService) {
        if (URL.pathComponents.count >= 3) {
            NSString *cls = URL.pathComponents[1];
            Class clazz = NSClassFromString(cls);
            if (!clazz) {
                return NO;
            }
            SEL sel = NSSelectorFromString(URL.pathComponents[2]);
            if (sel && [clazz instancesRespondToSelector:sel]) {
                return YES;
            }
            return NO;
            
        }
        return NO;
    }
    return NO;
}

+ (void)jumpJumpViewControllerWithURL:(NSURL *)URL
                               params:(NSMutableDictionary *)params
                             callBack:(void (^)(NSString *, id, id))callBack{
    if (URL.pathComponents.count >= 2) {
        BOOL animated = YES;
        if (URL.pathComponents.count >= 3) {
            NSString *animatedString = URL.pathComponents[2];
            if ([animatedString isEqualToString:LHRURLJumpViewControllerAnimatedNO]) {
                animated = NO;
            }
        }
        NSString *key = URL.pathComponents[1];
        Class clss = [[LHRPageManager shareInstance] getPageCls:key];
        UIViewController *obj = [[clss alloc] init];
        
        [self setAllValues:obj withParams:params];
        LHVCJumpMode jumpMode = [self getJumpModeWith:URL.fragment];
        UIViewController *vc = [self currentViewController];
        switch (jumpMode) {
            case LHVCJumpModePush: {
                [vc.navigationController pushViewController:obj animated:animated];
            }
                break;
            case LHVCJumpModeMode: {
                UIViewController *objVc = obj;
                objVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [vc presentViewController:obj animated:YES completion:nil];
            }
            default:
                break;
        }
        if (callBack) {
            callBack(URL.pathComponents[1],obj,nil);
        }
    }
}

/// 属性过滤&赋值
+ (void)setAllValues:(id)obj withParams:(NSMutableDictionary *)params {
    [params.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        objc_property_t prop = class_getProperty([obj class], key.UTF8String);
        if (!prop) {
            [params removeObjectForKey:key];
        } else {
            [obj setValue:params[key] forKey:key];
        }
    }];
}


+ (NSDictionary *)queryParamsWithURL:(NSURL *)URL {
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL
                                                resolvingAgainstBaseURL:NO];
    NSArray *queryItems = URLComponents.queryItems;
    NSMutableDictionary *dic = @{}.mutableCopy;
    for (NSURLQueryItem *item in queryItems) {
        if (item.name && item.value) {
            [dic setObject:item.value forKey:item.name];
        }
    }
    return  dic;
}

+ (LHVCJumpMode) getJumpModeWith:(NSString *)fragment {
    if ([fragment isEqualToString:LHRURLFragmentViewControlerEnterModePush]) {
        return  LHVCJumpModePush;
    }
    
    if ([fragment isEqualToString:LHRURLFragmentViewControlerEnterModeModal]) {
        return  LHVCJumpModeMode;
    }
    return LHVCJumpModePush;
}

+ (UIViewController *)currentViewController {
    UIWindow *w = [self rootWindow];
    UIViewController *viewController = w.rootViewController;
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbvc = (UITabBarController*)viewController;
            viewController = tbvc.selectedViewController;
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)viewController;
            viewController = nvc.topViewController;
        } else if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:[UISplitViewController class]] &&
                   ((UISplitViewController *)viewController).viewControllers.count > 0) {
            UISplitViewController *svc = (UISplitViewController *)viewController;
            viewController = svc.viewControllers.lastObject;
        } else  {
            return viewController;
        }
    }
    return viewController;
}

+ (UIWindow *)rootWindow {
    UIWindow *w = nil;
    if (@available(iOS 13.0, *)) {
        if ([UIApplication sharedApplication].supportsMultipleScenes) {
            for (UIWindowScene *sc in [UIApplication sharedApplication].connectedScenes) {
                if (sc.activationState == UISceneActivationStateForegroundActive) {
                    w = sc.windows.firstObject;
                }
            }
        } else {
            w = [UIApplication sharedApplication].windows.firstObject;
        }
    } else {
        w = [UIApplication sharedApplication].keyWindow;
    }
    return  w;
}

#pragma mark - service communicate

+ (void)callService:(NSURL *)URL withParams:(NSDictionary *)params callBack:(void(^)(NSString *pathComponentKey, id obj, id returnValue))callBack{
    if (URL.pathComponents.count >= 3) {
        id obj = [[LHServiceManager shareInstance] getService:URL.pathComponents[1]];
        SEL sel = NSSelectorFromString(URL.pathComponents[2]);
        id rv = [self performSel:sel forTarget:obj withParams:params];
        if (callBack) {
            callBack(URL.pathComponents[1], obj, rv);
        }
    }
}

#define LHR_OBJCTYPE_SKIP_CHAR(objcType) while(*objcType == 'r' || *objcType == 'n' || *objcType == 'N' || *objcType == 'o' || *objcType == 'O' || *objcType == 'R' || *objcType == 'v') {\
objcType++;\
}

#define LHR_OBJCTYPE_BLOCK(objcType, encode, _type)\
if(strncmp(objcType, encode, 2) == 0) {\
_type block = [value copy]; \
[invocation setArgument:(void *)&block atIndex:i];\
}

#define LHR_OBJCTYPE_C_CHR(objcType, _type)\
else if(*objcType == _C_CHR){\
_type v = [value charValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_C_UCHR(objcType, _type)\
else if(*objcType == _C_UCHR){\
_type v = [value unsignedCharValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}


#define LHR_OBJCTYPE_C_SHT(objcType, _type)\
else if(*objcType == _C_SHT){\
_type v = [value shortValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

//_C_USHT
#define LHR_OBJCTYPE_C_USHT(objcType, _type)\
else if(*objcType == _C_USHT){\
_type v = [value unsignedShortValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_INT
#define LHR_OBJCTYPE_C_INT(objcType, _type)\
else if(*objcType == _C_INT){\
_type v = [value intValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

//_C_UINT
#define LHR_OBJCTYPE_C_UINT(objcType, _type)\
else if(*objcType == _C_UINT){\
_type v = [value unsignedIntValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_LNG
#define LHR_OBJCTYPE_C_LNG(objcType, _type)\
else if(*objcType == _C_LNG){\
_type v = [value longValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_ULNG
#define LHR_OBJCTYPE_C_ULNG(objcType, _type)\
else if(*objcType == _C_ULNG){\
_type v = [value unsignedLongValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_LNG_LNG
#define LHR_OBJCTYPE_C_LNG_LNG(objcType, _type)\
else if(*objcType == _C_LNG_LNG){\
_type v = [value longLongValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_ULNG_LNG
#define LHR_OBJCTYPE_C_ULNG_LNG(objcType, _type)\
else if(*objcType == _C_LNG_LNG){\
_type v = [value unsignedLongLongValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_FLT
#define LHR_OBJCTYPE_C_FLT(objcType, _type)\
else if(*objcType == _C_FLT){\
_type v = [value longLongValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_DBL
#define LHR_OBJCTYPE_C_DBL(objcType, _type)\
else if(*objcType == _C_DBL){\
_type v = [value doubleValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}
//_C_BOOL
#define LHR_OBJCTYPE_C_BOOL(objcType, _type)\
else if(*objcType == _C_BOOL){\
_type v = [value boolValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

//_C_ID
#define LH_OBJCTYPE_C_ID(objcType)\
else if(*objcType == _C_ID){\
[invocation setArgument:(void *)&value atIndex:i];\
}
//_C_PTR
#define LH_OBJCTYPE_C_PTR(objcType)\
else if(*objcType == _C_ID){\
[invocation setArgument:(void *)&value atIndex:i];\
}


#define LHR_OBJCTYPE_CGPoint(objcType, _type)\
else if(strcmp(objcType, @encode(CGPoint)) == 0){\
_type v = [value CGPointValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_CGVector(objcType, _type)\
else if(strcmp(objcType, @encode(CGVector)) == 0){\
_type v = [value CGVectorValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_CGSize(objcType, _type)\
else if(strcmp(objcType, @encode(CGSize)) == 0){\
_type v = [value CGSizeValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_CGRect(objcType, _type)\
else if(strcmp(objcType, @encode(CGRect)) == 0){\
_type v = [value CGRectValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_CGAffineTransform(objcType, _type)\
else if(strcmp(objcType, @encode(CGAffineTransform)) == 0){\
_type v = [value CGAffineTransformValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

#define LHR_OBJCTYPE_UIEdgeInsets(objcType, _type)\
else if(strcmp(objcType, @encode(CGAffineTransform)) == 0){\
_type v = [value UIEdgeInsetsValue];\
[invocation setArgument:(void *)&v atIndex:i];\
}

+ (id)performSel:(SEL)sel forTarget:(NSObject *)target withParams:(NSDictionary *)params {
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    if (!sig) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    if (!invocation) {
        return nil;
    }
    [invocation setTarget:target];
    [invocation setSelector:sel];
    NSArray<NSString *> *keys = params.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        if (obj1 < obj2) {
            return NSOrderedAscending;
        } else if (obj1.integerValue == obj2.integerValue) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[key];
        char *objcType = (char *)[sig getArgumentTypeAtIndex:idx + 2];
        NSUInteger i = idx + 2;
        LHR_OBJCTYPE_SKIP_CHAR(objcType)
        LHR_OBJCTYPE_BLOCK(objcType, "@?", id)
        LHR_OBJCTYPE_C_CHR(objcType, char)
        LHR_OBJCTYPE_C_UCHR(objcType, unsigned char)
        LHR_OBJCTYPE_C_SHT(objcType, short)
        LHR_OBJCTYPE_C_USHT(objcType, unsigned short)
        LHR_OBJCTYPE_C_INT(objcType, int)
        LHR_OBJCTYPE_C_UINT(objcType, unsigned int)
        LHR_OBJCTYPE_C_LNG(objcType, long)
        LHR_OBJCTYPE_C_ULNG(objcType, unsigned long)
        LHR_OBJCTYPE_C_LNG_LNG(objcType, long long)
        LHR_OBJCTYPE_C_ULNG_LNG(objcType, unsigned long long)
        LHR_OBJCTYPE_C_FLT(objcType, float)
        LHR_OBJCTYPE_C_DBL(objcType, double)
        LHR_OBJCTYPE_C_BOOL(objcType, BOOL)
        LH_OBJCTYPE_C_ID(objcType)
        LH_OBJCTYPE_C_PTR(objcType)
        LHR_OBJCTYPE_CGPoint(objcType, CGPoint)
        LHR_OBJCTYPE_CGVector(objcType, CGVector)
        LHR_OBJCTYPE_CGSize(objcType, CGSize)
        LHR_OBJCTYPE_CGRect(objcType, CGRect)
        LHR_OBJCTYPE_CGAffineTransform(objcType, CGAffineTransform)
        LHR_OBJCTYPE_UIEdgeInsets(objcType, UIEdgeInsets)
        else {
            NSAssert(NO, @"objcType does not support ");
        }
    }];
    [invocation invoke];
    return  [self getReturnValueFromInv:invocation withSig:sig];

}

+ (id)getReturnValueFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger len = [sig methodReturnLength];
    if (len == 0) {
        return nil;
    }
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
#define return_with_number(_type_)\
do { \
_type_ ret; \
[inv getReturnValue:&ret];\
return @(ret); \
} while(0)
    switch (*type) {
        case 'v': return nil;
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            id ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            char *buf = calloc(1, len);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:type];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

@end

//
//  LHRouter.h
//  Router
//
//  Created by 李辉 on 2022/3/18.
//


#import <Foundation/Foundation.h>



//NS_ASSUME_NONNULL_BEGIN

@interface LHRouter : NSObject

+ (void)openURL:(NSURL *)URL;
+ (void)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, id> *)params;
+ (void)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, id> *)params
        callBack:(void(^)(NSString *pathComponentKey, id obj, id returnValue))callBack;

@end

//NS_ASSUME_NONNULL_END

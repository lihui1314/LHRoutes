//
//  LHRPageManager.h
//  LHRoutes
//
//  Created by 李辉 on 2022/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHRPageManager : NSObject
+ (instancetype)shareInstance;

- (Class)getPageCls:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

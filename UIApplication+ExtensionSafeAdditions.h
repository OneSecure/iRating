//
//  UIApplication+ExtensionSafeAdditions.h
//  iRating
//
//  Created by OneSecure on 2020/3/31.
//  Copyright © 2020 onesecure. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (ExtensionSafeAdditions)

+ (UIApplication *) iRating_sharedApplication;

- (BOOL) iRating_openURL:(NSURL *)url;

- (BOOL) iRating_canOpenURL:(NSURL *)url;

- (UIWindow *) iRating_window;

@end

NS_ASSUME_NONNULL_END

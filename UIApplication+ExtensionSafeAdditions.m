//
//  UIApplication+ExtensionSafeAdditions.m
//  iRating
//
//  Created by OneSecure on 2020/3/31.
//  Copyright © 2020 onesecure. All rights reserved.
//

#import "UIApplication+ExtensionSafeAdditions.h"

@implementation UIApplication (ExtensionSafeAdditions)

+ (BOOL) iRating_isRunningExtension {
    return [[[NSBundle mainBundle] executablePath] containsString:@".appex/"];
}

+ (UIApplication *) iRating_sharedApplication {
    UIApplication *application = nil;
    if ([UIApplication iRating_isRunningExtension] == NO) {
        // If we are compiling from a non-extension target, use the regular sharedApplication.
        application = [UIApplication performSelector:@selector(sharedApplication)];
    }
    return application;
}
         
- (BOOL) iRating_canOpenURL:(NSURL *)url {
    BOOL result = NO;
    if ([UIApplication iRating_isRunningExtension] == NO) {
        // If we are compiling from a non-extension target, use the regular sharedApplication.
        UIApplication *application = [[self class] iRating_sharedApplication];
        if ([application respondsToSelector:@selector(canOpenURL:)]) {
            // Although `performSelector:` is declared to return an `id`, it is in practice castable to a `BOOL` when the
            // selector returns one.
            result = (BOOL)[application performSelector:@selector(canOpenURL:) withObject:url];
        }
    }
    
    return result;
}

- (BOOL) iRating_openURL:(NSURL*)url {
    BOOL result = NO;
    if ([UIApplication iRating_isRunningExtension] == NO) {
        // If we are compiling from a non-extension target, use the regular sharedApplication.
        UIApplication *application = [[self class] iRating_sharedApplication];
        if ([application respondsToSelector:@selector(openURL:)]) {
            // Although `performSelector:` is declared to return an `id`, it is in practice castable to a `BOOL` when the
            // selector returns one.
            result = (BOOL)[application performSelector:@selector(openURL:) withObject:url];
        }
    }
    
    return result;
}

- (UIWindow *) iRating_window {
    UIWindow *window = nil;
    if ([UIApplication iRating_isRunningExtension] == NO) {
        // If we are compiling from a non-extension target, use the regular sharedApplication.
        UIApplication *application = [[self class] iRating_sharedApplication];
        if ([application respondsToSelector:@selector((delegate))]) {
            id <UIApplicationDelegate> delegate = [application performSelector:@selector((delegate))];
            if ([delegate respondsToSelector:@selector(window)]) {
                window = [delegate performSelector:@selector(window)];
            }
        }
    }
    
    return window;
}


@end

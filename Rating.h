//
//  Rating.h
//  OneSecure
//
//  Created by OneSecure on 3/4/15.
//  Copyright (c) 2015 OneSecure. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(NSError* error, BOOL updateAvailable);


@interface Rating : NSObject

@property(nonatomic, assign) CGFloat remindIntervalDays;
@property(nonatomic, assign, readonly) BOOL ignoreRateThisVersion;
@property(nonatomic, assign) BOOL currentVersionRated;
@property(nonatomic, assign) BOOL existNewVersion;
@property(nonatomic, weak) UIViewController *rootCtrl;
@property(nonatomic, assign) BOOL jumpToAppStore;

- (void) excuteRatingTasks:(UIViewController *)rootCtrl;

- (void) promptForRating:(UIViewController *)rootCtrl;
- (void) promptForNewVersion:(BOOL)refresh rootController:(UIViewController *)rootController;

- (void) checkNow:(BOOL)refresh completion:(CompletionBlock)completion;

+ (instancetype) sharedInstance;

@end

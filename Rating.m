//
//  Rating.m
//  OneSecure
//
//  Created by OneSecure on 3/4/15.
//  Copyright (c) 2015 OneSecure. All rights reserved.
//

#import "Rating.h"
#import "AppStoreViewController.h"
#import <StoreKit/StoreKit.h>


static NSString *const kAppLookupUrl = @"https://itunes.apple.com/lookup?bundleId=%@";
static NSString *const kRemindIntervalDays = @"remindIntervalDays";
static NSString *const kIgnoreRateThisVersion = @"ignoreRateThisVersion";
static NSString *const kIgnoreUpdateThisVersion = @"ignoreUpdateThisVersion";
static NSString *const kCurrentVersionRated = @"currentVersionRated";
static NSString *const kTimingBeginning = @"timingBeginning";

NSString *const RatingMessageTitleKey = @"RatingMessageTitle";
NSString *const RatingGameMessageKey = @"RatingGameMessage";
NSString *const RatingAppMessageKey = @"RatingAppMessage";
NSUInteger const RatingAppStoreGameGenreID = 6014;
NSString *const RatingCancelButtonKey = @"RatingCancelButton";
NSString *const RatingRateButtonKey = @"RatingRateButton";
NSString *const RatingRemindButtonKey = @"RatingRemindButton";
NSString *const RatingNewVerionKey = @"RatingNewVerion";
NSString *const RatingUpToDateKey = @"RatingUpToDate";
NSString *const RatingCancelKey = @"Cancel";
NSString *const RatingOkKey = @"OK";

static NSString *const RatingiOSAppStoreURLScheme = @"itms-apps";
static NSString *const RatingiOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
static NSString *const RatingiOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
static NSString *const RatingiOSAppStoreURLFormat2 = @"https://itunes.apple.com/app/id%@?mt=8&action=write-review";

static CGFloat defaultRemindIntervalDays = 5.0f;

#define SECONDS_IN_A_DAY  86400.0
#define SECONDS_IN_A_WEEK 604800.0


@interface Rating() {
    NSBundle *_mainBundle;
    NSString *_appName;
    NSString *_bundleID;
    NSString *_thisVersion;
    NSString *_trackViewUrl;
    NSInteger _appStoreGenreID;
    NSString *_newVersion;
}

@property(nonatomic, assign) NSInteger appStoreID;
@property(nonatomic, strong) NSDate *timingBeginning;
@property(nonatomic, assign) BOOL ignoreUpdateThisVersion;

@end



@implementation Rating {
    NSUserDefaults *_userDefaults;
    AppStoreViewController *_appStoreView;
}

+ (void) load {
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (instancetype) sharedInstance {
    static Rating *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Rating alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _mainBundle = [NSBundle mainBundle];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        _appName = [_mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([_appName length] == 0) {
            _appName = [_mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        }
        
        _bundleID = [_mainBundle bundleIdentifier];
        _thisVersion = [_mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        self.remindIntervalDays = defaultRemindIntervalDays;
        
        [self checkNow:YES completion:nil];
    }
    
    return self;
}

- (UIViewController *) topMostController {
    UIViewController *topController = _rootCtrl;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

- (CGFloat) remindIntervalDays {
    id value = [_userDefaults objectForKey:kRemindIntervalDays];
    if (value) {
        return [value floatValue];
    }
    return defaultRemindIntervalDays;
}

- (void) setRemindIntervalDays:(CGFloat)remindIntervalDays {
    [_userDefaults setFloat:remindIntervalDays forKey:kRemindIntervalDays];
    [_userDefaults synchronize];
}

- (BOOL) ignoreRateThisVersion {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kIgnoreRateThisVersion, _thisVersion];
    return [[_userDefaults objectForKey:key] integerValue];
}

- (void) setIgnoreRateThisVersion:(BOOL)ignoreRateThisVersion {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kIgnoreRateThisVersion, _thisVersion];
    [_userDefaults setInteger:ignoreRateThisVersion forKey:key];
    [_userDefaults synchronize];
}

- (BOOL) ignoreUpdateThisVersion {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kIgnoreUpdateThisVersion, _thisVersion];
    return [[_userDefaults objectForKey:key] integerValue];
}

- (void) setIgnoreUpdateThisVersion:(BOOL)ignoreUpdateThisVersion {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kIgnoreUpdateThisVersion, _thisVersion];
    [_userDefaults setInteger:ignoreUpdateThisVersion forKey:key];
    [_userDefaults synchronize];
}

- (BOOL) currentVersionRated {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kCurrentVersionRated, _thisVersion];
    return [[_userDefaults objectForKey:key] integerValue];
}

- (void) setCurrentVersionRated:(BOOL)currentVersionRated {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kCurrentVersionRated, _thisVersion];
    [_userDefaults setInteger:currentVersionRated forKey:key];
    [_userDefaults synchronize];
}

- (NSInteger) appStoreID {
    return [[_userDefaults objectForKey:@"appStoreID"] integerValue];
}

- (void) setAppStoreID:(NSInteger)appStoreID {
    [_userDefaults setInteger:appStoreID forKey:@"appStoreID"];
}

- (NSDate *) timingBeginning {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kTimingBeginning, _thisVersion];
    NSDate *r = [_userDefaults objectForKey:key];
    if ([r isKindOfClass:[NSDate class]] == NO) {
        r = [NSDate date];
    }
    return r;
}

- (void) setTimingBeginning:(NSDate *)timingBeginning {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kTimingBeginning, _thisVersion];
    [_userDefaults setObject:timingBeginning forKey:key];
    [_userDefaults synchronize];
}


#pragma mark -

- (NSString *) localizedStringForKey:(NSString *)key withDefault:(NSString*)defaultString {
    static NSBundle *bundle = nil;
    NSBundle *mainBundle = [NSBundle mainBundle];
    if (bundle == nil) {
        NSString *bundlePath = [mainBundle pathForResource:@"Rating" ofType:@"bundle"];
        
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages count] ? languages[0] : @"en";
        if (![[bundle localizations] containsObject:language]) {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language]) {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        
        bundle = [NSBundle bundleWithPath:bundlePath] ?:mainBundle;
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [mainBundle localizedStringForKey:key value:defaultString table:nil];
}

- (NSString *) messageTitle {
    NSString *fmt = [self localizedStringForKey:RatingMessageTitleKey withDefault:@"Rate %@"];
    return [fmt stringByReplacingOccurrencesOfString:@"%@" withString:_appName];
}

- (NSString *) message {
    NSString *message = nil;
    
    NSString *msg1 = @"If you enjoy playing %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!";
    NSString *msg2 = @"If you enjoy using %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!";
    if (_appStoreGenreID == RatingAppStoreGameGenreID) {
        message = [self localizedStringForKey:RatingGameMessageKey withDefault:msg1];
    } else {
        message = [self localizedStringForKey:RatingAppMessageKey withDefault:msg2];
    }
    return [message stringByReplacingOccurrencesOfString:@"%@" withString:_appName];
}

- (NSString *) cancelButtonLabel {
    return [self localizedStringForKey:RatingCancelButtonKey withDefault:@"No, Thanks"];
}

- (NSString *) rateButtonLabel {
    return [self localizedStringForKey:RatingRateButtonKey withDefault:@"Rate It Now"];
}

- (NSString *) remindButtonLabel {
    return [self localizedStringForKey:RatingRemindButtonKey withDefault:@"Remind Me Later"];
}

- (void) promptForRating:(UIViewController *)rootCtrl {
    _rootCtrl = rootCtrl;
    if ([NSThread mainThread] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self promptForRating:rootCtrl];
        });
        return;
    }
    
    NSString * messageTitle = self.messageTitle;
    NSString * message = self.message;
    NSString * rateButtonLabel = self.rateButtonLabel;
    NSString * cancelButtonLabel = self.cancelButtonLabel;
    NSString * remindButtonLabel = self.remindButtonLabel;

        UIAlertController * alert =
        [UIAlertController alertControllerWithTitle:messageTitle message:message preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* rateAction =
        [UIAlertAction actionWithTitle:rateButtonLabel
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
         {
             [self doOpenRatingsPageInAppStore];
             [alert dismissViewControllerAnimated:YES completion:nil];
         }];
        [alert addAction:rateAction];

        UIAlertAction* cancelAction =
        [UIAlertAction actionWithTitle:cancelButtonLabel
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
         {
             [self doIgnoreRateThisVersion];
             [alert dismissViewControllerAnimated:YES completion:nil];
         }];
        [alert addAction:cancelAction];

        UIAlertAction* remindAction =
        [UIAlertAction actionWithTitle:remindButtonLabel
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
         {
             [self doRemindLater];
             [alert dismissViewControllerAnimated:YES completion:nil];
         }];
        [alert addAction:remindAction];

        [[self topMostController] presentViewController:alert animated:YES completion:nil];
}

- (void) promptForNewVersion:(BOOL)refresh rootController:(UIViewController *)rootController{
    _rootCtrl = rootController;
    if ([NSThread mainThread] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self promptForNewVersion:refresh rootController:rootController];
        });
        return;
    }
    
    [self checkNow:refresh completion:^(NSError *error, BOOL updateAvailable) {
        NSString *ok = [self localizedStringForKey:RatingOkKey withDefault:@"OK"];
        NSString *fmt = nil;
        if (updateAvailable) {
            NSString *cancel = [self localizedStringForKey:RatingCancelKey withDefault:@"Cancel"];
            fmt = [self localizedStringForKey:RatingNewVerionKey withDefault:@"A new version %@ released.\nWill you want to get it?"];
            NSString *msg = [NSString stringWithFormat:fmt, self->_newVersion];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController * alert =
                [UIAlertController alertControllerWithTitle:self->_appName message:msg preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction* okAction =
                [UIAlertAction actionWithTitle:ok
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                 {
                     [self doOpenRatingsPageInAppStore];
                     [alert dismissViewControllerAnimated:YES completion:nil];
                 }];
                [alert addAction:okAction];

                UIAlertAction* cancelAction =
                [UIAlertAction actionWithTitle:cancel
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                 {
                     self.ignoreUpdateThisVersion = YES;
                     [alert dismissViewControllerAnimated:YES completion:nil];
                 }];
                [alert addAction:cancelAction];

                [[self topMostController] presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            NSString *msg = [self localizedStringForKey:RatingUpToDateKey withDefault:@"You're up to date!"];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController * alert =
                [UIAlertController alertControllerWithTitle:self->_appName message:msg preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction* okAction =
                [UIAlertAction actionWithTitle:ok
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                 {
                     [alert dismissViewControllerAnimated:YES completion:nil];
                 }];
                [alert addAction:okAction];

                [[self topMostController] presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

#pragma mark - User's actions

- (void) doIgnoreRateThisVersion {
    // ignore this version
    self.ignoreRateThisVersion = YES;
}

- (void) doRemindLater {
    self.timingBeginning = [NSDate date];
}

- (void) doOpenRatingsPageInAppStore {
#if !defined(TARGE_APP_EXTENSION)
    NSURL *ratingsURL = [self ratingsURL]; // [NSURL URLWithString:_trackViewUrl];
    
    if ([[UIApplication sharedApplication] canOpenURL:ratingsURL]) {
        NSLog(@"Rating will open the App Store ratings page using the following URL: %@", ratingsURL);
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.timingBeginning];
        if ((interval > self.remindIntervalDays * SECONDS_IN_A_DAY) &&
            self.currentVersionRated &&
            [NSClassFromString(@"SKStoreReviewController") class])
        {
            [SKStoreReviewController requestReview];
        } else {
#if 0
        [[UIApplication sharedApplication] openURL:ratingsURL];
#else
        NSString *appID = [NSString stringWithFormat:@"%ld", (long)self.appStoreID];
        _appStoreView = [[AppStoreViewController alloc] initWithAppID:appID];
        [_appStoreView popup:_rootCtrl finish:^{
        }];
#endif
        }
        self.currentVersionRated = YES;
    }
    else {
        NSString *fmt = @"Rating was unable to open the specified ratings URL: %@";
        NSString *message = [NSString stringWithFormat:fmt, ratingsURL];
        
#if TARGET_IPHONE_SIMULATOR
        if ([[ratingsURL scheme] isEqualToString:RatingiOSAppStoreURLScheme]) {
            message = @"Rating could not open the ratings page because the App Store is not available on the iOS simulator";
        }
#endif
        
        NSLog(@"%@", message);
    }
#endif
}

- (NSURL *) ratingsURL {
    NSString *urlString;
    /*
    float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (7.0f <= iOSVersion && iOSVersion < 7.1f) {
        urlString = RatingiOS7AppStoreURLFormat;
    } else {
        urlString = RatingiOSAppStoreURLFormat;
    } */
    urlString = RatingiOSAppStoreURLFormat2;

    return [NSURL URLWithString:[NSString stringWithFormat:urlString, @(self.appStoreID)]];
}

#pragma mark -
#pragma mark appDate functions

- (NSComparisonResult) compareVersions:(NSString*)version1 version2:(NSString*)version2 {
    NSComparisonResult result = NSOrderedSame;
    
    NSMutableArray* a = (NSMutableArray*) [version1 componentsSeparatedByString: @"."];
    NSMutableArray* b = (NSMutableArray*) [version2 componentsSeparatedByString: @"."];
    
    while (a.count < b.count) { [a addObject: @"0"]; }
    while (b.count < a.count) { [b addObject: @"0"]; }
    
    for (int i = 0; i < a.count; ++i) {
        if ([[a objectAtIndex: i] integerValue] < [[b objectAtIndex: i] integerValue]) {
            result = NSOrderedAscending;
            break;
        }
        else if ([[b objectAtIndex: i] integerValue] < [[a objectAtIndex: i] integerValue]) {
            result = NSOrderedDescending;
            break;
        }
    }
    
    return result;
}

- (void) excuteRatingTasks:(UIViewController *)rootCtrl {
    _rootCtrl = rootCtrl;
    [self checkNow:NO completion:^(NSError *error, BOOL updateAvailable) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.timingBeginning];
        if (error) {
            return;
        }
        if (self->_existNewVersion && (self.ignoreUpdateThisVersion==NO)) {
            [self promptForNewVersion:NO rootController:rootCtrl];
            return;
        }
        else if (self.ignoreRateThisVersion) {
            return;
        }
        else if (interval < self.remindIntervalDays * SECONDS_IN_A_DAY) {
            return;
        }
        else if (self.currentVersionRated){
            return;
        }
        else {
            [self promptForRating:rootCtrl];
            return;
        }
    }];
}

- (void) checkNow:(BOOL)refresh completion:(CompletionBlock)completion {
    if (refresh == NO) {
        if (self.appStoreID != 0) {
            if (completion) {
                completion(nil, _existNewVersion);
            }
            return;
        }
    }

#if !defined(TARGE_APP_EXTENSION)
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
#endif

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kAppLookupUrl, _bundleID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            [self connectionDidReceiveData:data error:&error];
        }
        if (completion != nil) {
            completion(error, self->_existNewVersion);
        }
#if !defined(TARGE_APP_EXTENSION)
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
#endif
    }];
    [task resume];
}

- (void) connectionDidReceiveData:(NSData*)data error:(NSError **)error{
    NSDictionary* object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:error];
    NSDictionary* jsonData = nil;
    if (*error == nil) {
        NSArray* results = [object objectForKey: @"results"];
        if (results.count > 0) {
            jsonData = [results objectAtIndex: 0];
            _newVersion = [jsonData objectForKey: @"version"];
            
            _existNewVersion = ([self compareVersions:_thisVersion version2:_newVersion] == NSOrderedAscending);
            _trackViewUrl = [jsonData objectForKey:@"trackViewUrl"];
            _appStoreGenreID = [jsonData[@"primaryGenreId"] integerValue];
            NSInteger appStoreID = [jsonData[@"trackId"] integerValue];
            if (appStoreID) {
                self.appStoreID = appStoreID;
            }
        }
    }
}

@end

/*
    File: BannerViewController.m
Abstract: A container view controller that manages an ADBannerView and a content view controller

*/

#import "AppStoreViewController.h"
#import <StoreKit/StoreKit.h>


@interface AppStoreViewController () <SKStoreProductViewControllerDelegate>
@end

@implementation AppStoreViewController

- (instancetype) initWithAppID:(const NSString *)appID {
    if (self = [super init]) {
        _appID = appID.copy;
    }
    return self;
}

- (void) goAppStoreInOutside {
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", _appID];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

//
// http://code.tutsplus.com/tutorials/displaying-app-store-products-in-app--mobile-15055
// http://code.tutsplus.com/tutorials/ios-6-sdk-displaying-app-store-products-in-app--mobile-15055
//
- (void) popup:(UIViewController *)parent finish:(dispatch_block_t)finish {
    _parent = parent;
    _finish = finish;

    // Initialize Product View Controller
    SKStoreProductViewController *controller = [[SKStoreProductViewController alloc] init];

    // Configure View Controller
    [controller setDelegate:self];
    NSDictionary<NSString *, id> *parameters = @{SKStoreProductParameterITunesItemIdentifier:_appID};
    
    // FIXME: when application:supportedInterfaceOrientationsForWindow:
    //        returns UIInterfaceOrientationMaskLandscape,
    //        presentViewController:animated:completion: will crash in iphone
    @try {
        [_parent presentViewController:controller animated:YES completion:^{
            [controller loadProductWithParameters:parameters completionBlock:nil];
        }];
    } @catch (NSException *exception) {
        [self goAppStoreInOutside];
        if (_finish) {
            _finish();
        }
    }
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [_parent dismissViewControllerAnimated:YES completion:nil];
    if (_finish) {
        _finish();
    }
}

@end

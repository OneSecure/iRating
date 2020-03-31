//
//    File: AppStoreViewController.h
//

#import <UIKit/UIKit.h>

@interface AppStoreViewController : NSObject

@property(nonatomic, strong) NSString *appID;
@property(nonatomic, strong, readonly) dispatch_block_t finish;
@property(nonatomic, weak, readonly) UIViewController *parent;

- (instancetype) initWithAppID:(const NSString *)appID;
- (void) popup:(UIViewController *)parent finish:(dispatch_block_t)finish;

@end

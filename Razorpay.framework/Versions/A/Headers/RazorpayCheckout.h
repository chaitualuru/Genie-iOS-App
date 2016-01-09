
#import <UIKit/UIKit.h>

@interface RazorpayCheckout : UIViewController

- (void)failureHandler:(int) code description:(nonnull NSString *) str;

- (void)successHandler:(nonnull NSString*) payment_id;

- (void)setDelegate:(nonnull id)delegate;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)open:(nonnull NSDictionary*) options;

- (void)close;

- (nonnull id)initWithKey:(nonnull NSString *) key;

- (void)authorize:(nonnull NSDictionary*) options;

@end

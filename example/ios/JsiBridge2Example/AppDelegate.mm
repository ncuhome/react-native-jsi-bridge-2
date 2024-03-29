#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#include "JsiBridgeEmitter.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"JsiBridge2Example";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  [[CustomJsiBridgeEmitter shared] on:@"jsData" with:^(NSDictionary *data) {
    NSLog(@"😃jsData %@", (NSString *)[data objectForKey:@"user"]);

    [[CustomJsiBridgeEmitter shared] emit:@"onData" with:data];
  }];

  [[CustomJsiBridgeEmitter shared] on:@"jsData" with:^(NSString *data) {
    [[CustomJsiBridgeEmitter shared] emit:@"onData" with:data];
  }];

  [[CustomJsiBridgeEmitter shared] on:@"jsData" with:^(NSNumber *data) {
    [[CustomJsiBridgeEmitter shared] emit:@"onData" with:data];
  }];

  [[CustomJsiBridgeEmitter shared] off:@""];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

/// This method controls whether the `concurrentRoot`feature of React18 is turned on or off.
///
/// @see: https://reactjs.org/blog/2022/03/29/react-v18.html
/// @note: This requires to be rendering on Fabric (i.e. on the New Architecture).
/// @return: `true` if the `concurrentRoot` feature is enabled. Otherwise, it returns `false`.
- (BOOL)concurrentRootEnabled
{
  return true;
}

@end

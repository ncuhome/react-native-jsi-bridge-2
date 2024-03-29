#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>

@interface CustomJsiBridge : NSObject <RCTBridgeModule>

- (void)emitJs:(NSString *)name with:(id)data;

@end

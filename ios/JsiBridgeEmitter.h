//
//  JsiBrigeEmitter.h
//  JsiBridge
//
//  Created by Sergei Golishnikov on 08/03/2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_JsiBridge.h"

typedef void (^CustomJsiBridgeCallback)(id data);

@interface CustomJsiBridgeEmitter : NSObject

+ (CustomJsiBridgeEmitter*)shared;

- (void)registerJsiBridge:(CustomJsiBridge *)bridge;

- (void)on:(NSString *)name
      with:(CustomJsiBridgeCallback)callback;

- (void)off:(NSString *)name;

- (void)emit:(NSString *)name
        with:(id)data;

- (void)emitNative:(NSString *)name with:(id)data;

@end

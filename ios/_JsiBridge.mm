#import "_JsiBridge.h"
#import <React/RCTBridge+Private.h>
#import <ReactCommon/RCTTurboModule.h>
#import <jsi/jsi.h>
#import "JsiBridgeEmitter.mm"
#import "JsiUtils.h"

#include "iostream"
#include "map"

using namespace facebook;

@implementation JsiBridge

RCT_EXPORT_MODULE()

// js registed events store
std::map<std::string, std::shared_ptr<facebook::jsi::Function>> jsListeners_;
RCTCxxBridge *jsBridge_cxxBridge;
RCTBridge *jsBridge_bridge;
jsi::Runtime *jsBridge_runtime;

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install) {
    NSLog(@"Installing JsiBridge polyfill Bindings...");
    jsBridge_bridge = [RCTBridge currentBridge];
    jsBridge_cxxBridge = (RCTCxxBridge*)jsBridge_bridge;
    if (jsBridge_cxxBridge == nil) return @false;
    jsBridge_runtime = (jsi::Runtime*) jsBridge_cxxBridge.runtime;
    if (jsBridge_runtime == nil) return @false;
    auto& runtime = *jsBridge_runtime;
    
    [JsiBridgeEmitter.shared registerJsiBridge:self];
    
    auto registerCallback = jsi::Function::createFromHostFunction(runtime,
                                                                  jsi::PropNameID::forUtf8(runtime, "registerCallback"),
                                                                  2,
                                                                  [&](jsi::Runtime& runtime,
                                                                      const jsi::Value& thisArg,
                                                                      const jsi::Value* args,
                                                                      size_t count) -> jsi::Value {
        
        auto name = args[0].asString(runtime).utf8(runtime);
#if DEBUG
        std::cout<<"😀 addCallback " + name << std::endl;
#endif
        auto callback = args[1].asObject(runtime).asFunction(runtime);
        jsListeners_[name] = std::make_shared<jsi::Function>(std::move(callback));
        return jsi::Value::undefined();
    });
    
    auto removeCallback = jsi::Function::createFromHostFunction(runtime,
                                                                jsi::PropNameID::forUtf8(runtime, "removeCallback"),
                                                                1,
                                                                [&](jsi::Runtime& runtime,
                                                                    const jsi::Value& thisArg,
                                                                    const jsi::Value* args,
                                                                    size_t count) -> jsi::Value {
        
        auto name = args[0].asString(runtime).utf8(runtime);
#if DEBUG
        std::cout<<"😀 removecallback " + name << std::endl;
#endif
        jsListeners_.erase(name);
        return jsi::Value::undefined();
    });
    
    auto emit = jsi::Function::createFromHostFunction(runtime,
                                                      jsi::PropNameID::forUtf8(runtime, "emit"),
                                                      2,
                                                      [=](jsi::Runtime &runtime,
                                                          const jsi::Value &thisArg,
                                                          const jsi::Value *args,
                                                          size_t count) -> jsi::Value {
        
        auto name = args[0].asString(runtime).utf8(runtime);
        id data = convertJSIValueToObjCObject(runtime, args[1], jsBridge_bridge.jsCallInvoker, nil);
        
        auto nameString = [NSString stringWithUTF8String:name.c_str()];
        
        [JsiBridgeEmitter.shared emitNative:nameString with:data];
        return jsi::Value::undefined();
    });
    
    
    jsi::Object _jsiBridge = jsi::Object(runtime);
    _jsiBridge.setProperty(runtime, "registerCallback", std::move(registerCallback));
    _jsiBridge.setProperty(runtime, "removeCallback", std::move(removeCallback));
    _jsiBridge.setProperty(runtime, "emit", std::move(emit));
    _jsiBridge.setProperty(runtime, "js", std::move(emit));
    runtime.global().setProperty(runtime, "_JsiBridge", std::move(_jsiBridge));
    
    return @true;
}

- (void)emitJs:(NSString *)name with:(id)data {
    auto stdName = [name UTF8String];
    if (jsListeners_.find(stdName) != jsListeners_.end()) {
        auto& runtime = *jsBridge_runtime;
        jsBridge_bridge.jsCallInvoker->invokeAsync([&runtime, n = stdName, d = data] () {
            auto dd = convertObjCObjectToJSIValue(runtime, d);
            jsListeners_[n]->call(runtime, std::move(dd));
        });
    }
}

@end

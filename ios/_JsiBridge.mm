#import "_JsiBridge.h"
#import <React/RCTBridge+Private.h>
#import <ReactCommon/RCTTurboModule.h>
#import <jsi/jsi.h>
#import "JsiBrigeEmitter.mm"

#include "iostream"
#include "map"

using namespace facebook;

jsi::Value convertNSStringToJSIString(jsi::Runtime &runtime, NSString *value)
{
  return jsi::String::createFromUtf8(runtime, [value UTF8String] ?: "");
}

@implementation JsiBridge

RCT_EXPORT_MODULE()

std::map<std::string, std::shared_ptr<facebook::jsi::Function>> callbacks;
RCTCxxBridge *_cxxBridge;
RCTBridge *_bridge;
jsi::Runtime *_runtime;

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install) {
    NSLog(@"Installing JsiBridge polyfill Bindings...");
    _bridge = [RCTBridge currentBridge];
    _cxxBridge = (RCTCxxBridge*)_bridge;
    if (_cxxBridge == nil) return @false;
    _runtime = (jsi::Runtime*) _cxxBridge.runtime;
    if (_runtime == nil) return @false;
    auto& runtime = *_runtime;
    
    [JsiBrigeEmitter.shared registerJsiBridge:self];
    
    
    auto registerCallback = jsi::Function::createFromHostFunction(runtime,
                                                                  jsi::PropNameID::forUtf8(runtime, "registerCallback"),
                                                                  2,
                                                                  [](jsi::Runtime& runtime,
                                                                     const jsi::Value& thisArg,
                                                                     const jsi::Value* args,
                                                                     size_t count) -> jsi::Value {
        
        auto name = args[0].asString(runtime).utf8(runtime);
        std::cout<<"😀addCallback " + name << std::endl;
        auto callback = args[1].asObject(runtime).asFunction(runtime);
        callbacks[name] = std::make_shared<jsi::Function>(std::move(callback));
        return jsi::Value::undefined();
    });
    
    auto removeCallback = jsi::Function::createFromHostFunction(runtime,
                                                                jsi::PropNameID::forUtf8(runtime, "removeCallback"),
                                                                1,
                                                                [](jsi::Runtime& runtime,
                                                                   const jsi::Value& thisArg,
                                                                   const jsi::Value* args,
                                                                   size_t count) -> jsi::Value {
        
        auto name = args[0].asString(runtime).utf8(runtime);
        std::cout<<"😀removecallback " + name << std::endl;
        callbacks.erase(name);
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
        auto data = args[1].asString(runtime).utf8(runtime);
        
        auto nameString = [NSString stringWithUTF8String:name.c_str()];
        auto dataString = [NSString stringWithUTF8String:data.c_str()];
        
        [JsiBrigeEmitter.shared emitNative:nameString with:dataString];
        return jsi::Value::undefined();
    });
    
    
    jsi::Object _jsiBridge = jsi::Object(runtime);
    _jsiBridge.setProperty(runtime, "registerCallback", std::move(registerCallback));
    _jsiBridge.setProperty(runtime, "removeCallback", std::move(removeCallback));
    _jsiBridge.setProperty(runtime, "emit", std::move(emit));
    runtime.global().setProperty(runtime, "_JsiBridge", std::move(_jsiBridge));
    
    return @true;
}

- (void)emitJs:(NSString *)name with:(NSString *)data {
    
    auto stdName = [name UTF8String];
    if (callbacks.find(stdName) != callbacks.end()) {
            auto& runtime = *_runtime;
            _bridge.jsCallInvoker->invokeAsync([&runtime, n = stdName, d = data] () {
                auto dd = convertNSStringToJSIString(runtime, d);
                callbacks[n]->call(runtime, dd);
            });
        }
}

@end

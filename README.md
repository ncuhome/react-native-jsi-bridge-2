# react-native-jsi-bridge

Kl

## Installation

```sh
#add to package.json
"react-native-jsi-bridge":"sergeymild/react-native-jsi-bridge#0.5.0"
# after that make yarn install
# and npx pod-install
```

## Usage JS

on js side just import `import { JsiBridge } from 'react-native-jsi-bridge'`
and subscribe on events which will be fired from native code.
```typescript
import { JsiBridge } from 'react-native-jsi-bridge';

// for subscribe
JsiBridge.on('eventNameInJsCode', (data: string) => {

})

// for unsubscribe
JsiBridge.off('eventNameInJsCode')
```

For send event to native code
```typescript
// send event to native code
JsiBridge.emit('eventNameInNativeCode', JSON.stringify({user: "withNamr"}))
```

## Usage Native Java

On native side (Java/Kotlin)
```java

// for subscribe
JsiBridge.on('eventNameInNativeCode', someObjectSerializedToString -> {

})

// for unsubscribe
JsiBridge.off('eventNameInNativeCode')

// send event to js code
JsiBridge.emit('eventNameInJsCode', someObjectSerializedToString)
```

## Usage Native Objective-c

On native side
```
#import "JsiBrigeEmitter.h"

// for subscribe
[[JsiBrigeEmitter shared] on:@"eventNameInNativeCode" with:^(NSString *data) {
  // some logic
}];

// for unsubscribe
[[JsiBrigeEmitter shared] off:@"eventNameInNativeCode"];

// send event to js code
[[JsiBrigeEmitter shared] emit:@"eventNameInJsCode" with:@"someObjectSerializedToString"];
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

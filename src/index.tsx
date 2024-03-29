import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-jsi-bridge-2' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const _CustomJsiBridge = NativeModules.CustomJsiBridge
  ? NativeModules.CustomJsiBridge
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

_CustomJsiBridge.install();

export class CustomJsiBridge {
  static on(name: string, callback: (data: any) => void) {
    //@ts-ignore
    global._CustomJsiBridge.registerCallback(name, callback);
  }

  static off(name: string) {
    //@ts-ignore
    global._CustomJsiBridge.removeCallback(name);
  }

  static emit(name: string, data?: any) {
    //@ts-ignore
    global._CustomJsiBridge.emit(name, data);
  }
}

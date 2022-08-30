import * as React from 'react';

import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { JsiBridge } from '@ncuhomeclub/jsi-bridge';

const Btn = ({ children, onPress }: any) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.btn}>
      <Text>{children}</Text>
    </TouchableOpacity>
  );
};

const rand = Math.random;

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  React.useEffect(() => {
    JsiBridge.on('onData', (data: any) => {
      console.log('[App.onData]', typeof data, data);
      try {
        setResult(JSON.stringify(data));
      } catch (_) {
        setResult(String(data));
      }
    });

    return () => {
      JsiBridge.off('onData');
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text
        style={{
          marginBottom: 24,
          fontSize: 20,
          padding: 24,
        }}
      >
        Result: {String(result)}
      </Text>

      <Btn
        onPress={() =>
          JsiBridge.emit(
            'jsData',
            Array.from({ length: Math.ceil(rand() * 20) }).map(() =>
              (rand() * 100).toPrecision(2)
            )
          )
        }
      >
        <Text>Send event with Array</Text>
      </Btn>

      <Btn
        onPress={() =>
          JsiBridge.emit('jsData', {
            user: 'sxy',
            val: rand().toPrecision(2),
          })
        }
      >
        <Text>Send event with Object</Text>
      </Btn>

      <Btn
        onPress={() => JsiBridge.emit('jsData', 'sxy' + rand().toPrecision(1))}
      >
        <Text>Send event with String</Text>
      </Btn>

      <Btn onPress={() => JsiBridge.emit('jsData', rand() > 0.5)}>
        <Text>Send event with boolean</Text>
      </Btn>

      <Btn onPress={() => JsiBridge.emit('jsData', rand() * 10)}>
        <Text>Send event with random number</Text>
      </Btn>

      <Btn onPress={() => JsiBridge.emit('jsData')}>
        <Text>Send event with undefined</Text>
      </Btn>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  btn: {
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    margin: 8,
  },
});

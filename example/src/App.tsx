import * as React from 'react';

import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { JsiBridge } from 'react-native-jsi-bridge';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  React.useEffect(() => {
    JsiBridge.on('onData', (data: any) => {
      console.log('[App.onData]', data);
      setResult(data['xjp']);
    });

    return () => {
      JsiBridge.off('onData');
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>

      <TouchableOpacity
        onPress={() => JsiBridge.emit('jsData', { user: 'sxy' })}
      >
        <Text>Send event</Text>
      </TouchableOpacity>
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
});

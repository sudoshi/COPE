import React, { useState } from 'react';
import { View, StyleSheet, ViewStyle, PanResponder } from 'react-native';

interface SliderProps {
  defaultValue?: number[];
  min?: number;
  max?: number;
  step?: number;
  onValueChange?: (value: number[]) => void;
  style?: ViewStyle;
  trackStyle?: ViewStyle;
  activeTrackStyle?: ViewStyle;
  thumbStyle?: ViewStyle;
}

const Slider: React.FC<SliderProps> = ({
  defaultValue = [0],
  min = 0,
  max = 100,
  step = 1,
  onValueChange,
  style,
  trackStyle,
  activeTrackStyle,
  thumbStyle,
}) => {
  const [value, setValue] = useState(defaultValue);
  const [width, setWidth] = useState(0);

  const calculateValue = (x: number) => {
    const percentage = Math.max(0, Math.min(1, x / width));
    const rawValue = min + percentage * (max - min);
    const steppedValue = Math.round(rawValue / step) * step;
    return Math.max(min, Math.min(max, steppedValue));
  };

  const panResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => true,
    onMoveShouldSetPanResponder: () => true,
    onPanResponderGrant: (evt) => {
      const x = evt.nativeEvent.locationX;
      const newValue = [calculateValue(x)];
      setValue(newValue);
      onValueChange?.(newValue);
    },
    onPanResponderMove: (evt, gestureState) => {
      const newValue = [calculateValue(gestureState.moveX - gestureState.x0 + gestureState.dx)];
      setValue(newValue);
      onValueChange?.(newValue);
    },
  });

  const percentage = (value[0] - min) / (max - min);
  const position = percentage * width;

  return (
    <View
      style={[styles.container, style]}
      onLayout={(e) => setWidth(e.nativeEvent.layout.width)}
      {...panResponder.panHandlers}
    >
      <View style={[styles.track, trackStyle]} />
      <View
        style={[
          styles.activeTrack,
          { width: position },
          activeTrackStyle,
        ]}
      />
      <View
        style={[
          styles.thumb,
          { left: position - 10 },
          thumbStyle,
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    height: 20,
    justifyContent: 'center',
  },
  track: {
    height: 4,
    backgroundColor: '#e5e7eb',
    borderRadius: 9999,
  },
  activeTrack: {
    height: 4,
    backgroundColor: '#7c3aed',
    borderRadius: 9999,
    position: 'absolute',
  },
  thumb: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: 'white',
    borderWidth: 2,
    borderColor: '#7c3aed',
    position: 'absolute',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
});

export default Slider;

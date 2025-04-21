import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';

interface ProgressProps {
  value: number;
  max?: number;
  style?: ViewStyle;
  progressStyle?: ViewStyle;
}

const Progress: React.FC<ProgressProps> = ({
  value,
  max = 100,
  style,
  progressStyle,
}) => {
  const percentage = Math.min(Math.max(0, value), max) / max * 100;

  return (
    <View style={[styles.container, style]}>
      <View
        style={[
          styles.progress,
          { width: `${percentage}%` },
          progressStyle,
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    height: 4,
    backgroundColor: '#e5e7eb',
    borderRadius: 9999,
    overflow: 'hidden',
  },
  progress: {
    height: '100%',
    backgroundColor: '#7c3aed',
    borderRadius: 9999,
  },
});

export default Progress;

import React from 'react';
import { ScrollView, StyleSheet, ViewStyle } from 'react-native';

interface ScrollAreaProps {
  children: React.ReactNode;
  style?: ViewStyle;
  contentContainerStyle?: ViewStyle;
}

const ScrollArea: React.FC<ScrollAreaProps> = ({
  children,
  style,
  contentContainerStyle,
}) => {
  return (
    <ScrollView
      style={[styles.container, style]}
      contentContainerStyle={[styles.content, contentContainerStyle]}
      showsVerticalScrollIndicator={false}
      showsHorizontalScrollIndicator={false}
    >
      {children}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flexGrow: 1,
  },
});

export default ScrollArea;

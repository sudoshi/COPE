import React from 'react';
import { View, Text, StyleSheet, ViewStyle } from 'react-native';
import { useThemeColor } from '../../hooks/useThemeColor';

interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const Card: React.FC<CardProps> = ({ children, style }) => {
  const backgroundColor = useThemeColor({}, 'background');
  return (
    <View style={[styles.card, { backgroundColor }, style]}>
      {children}
    </View>
  );
};

interface CardHeaderProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const CardHeader: React.FC<CardHeaderProps> = ({ children, style }) => {
  return (
    <View style={[styles.cardHeader, style]}>
      {children}
    </View>
  );
};

interface CardTitleProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const CardTitle: React.FC<CardTitleProps> = ({ children, style }) => {
  const color = useThemeColor({}, 'text');
  return (
    <Text style={[styles.cardTitle, { color }, style]}>
      {children}
    </Text>
  );
};

interface CardContentProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const CardContent: React.FC<CardContentProps> = ({ children, style }) => {
  return (
    <View style={[styles.cardContent, style]}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    marginBottom: 16,
  },
  cardHeader: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 8,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '500',
  },
  cardContent: {
    padding: 16,
  },
});

export default { Card, CardHeader, CardTitle, CardContent };

import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { useThemeColor } from '../../hooks/useThemeColor';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  style?: ViewStyle;
  textStyle?: TextStyle;
  icon?: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'md',
  style,
  textStyle,
  icon,
}) => {
  const getButtonStyle = () => {
    switch (variant) {
      case 'primary':
        return { backgroundColor: useThemeColor({}, 'tint') };
      case 'secondary':
        return { backgroundColor: useThemeColor({}, 'tabIconDefault') };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: useThemeColor({}, 'icon'),
        };
      case 'ghost':
        return { backgroundColor: 'transparent' };
      default:
        return { backgroundColor: useThemeColor({}, 'tint') };
    }
  };

  const getTextStyle = () => {
    switch (variant) {
      case 'primary':
      case 'secondary':
        return { color: useThemeColor({}, 'text') };
      case 'outline':
      case 'ghost':
        return { color: useThemeColor({}, 'icon') };
      default:
        return { color: useThemeColor({}, 'text') };
    }
  };

  const getSizeStyle = () => {
    switch (size) {
      case 'sm':
        return styles.smallButton;
      case 'md':
        return styles.mediumButton;
      case 'lg':
        return styles.largeButton;
      default:
        return styles.mediumButton;
    }
  };

  const getTextSizeStyle = () => {
    switch (size) {
      case 'sm':
        return styles.smallText;
      case 'md':
        return styles.mediumText;
      case 'lg':
        return styles.largeText;
      default:
        return styles.mediumText;
    }
  };

  return (
    <TouchableOpacity
      style={[styles.button, getButtonStyle(), getSizeStyle(), style]}
      onPress={onPress}
    >
      {icon && icon}
      <Text style={[styles.text, getTextStyle(), getTextSizeStyle(), textStyle]}>
        {title}
      </Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
  },
  primaryButton: {
    backgroundColor: '#7c3aed',
  },
  secondaryButton: {
    backgroundColor: '#3b82f6',
  },
  outlineButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#d1d5db',
  },
  ghostButton: {
    backgroundColor: 'transparent',
  },
  smallButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
  },
  mediumButton: {
    paddingVertical: 10,
    paddingHorizontal: 16,
  },
  largeButton: {
    paddingVertical: 12,
    paddingHorizontal: 20,
  },
  text: {
    fontWeight: '600',
  },
  primaryText: {
    color: 'white',
  },
  secondaryText: {
    color: 'white',
  },
  outlineText: {
    color: '#6b7280',
  },
  ghostText: {
    color: '#6b7280',
  },
  smallText: {
    fontSize: 12,
  },
  mediumText: {
    fontSize: 14,
  },
  largeText: {
    fontSize: 16,
  },
});

export default Button;

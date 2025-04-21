import React from 'react';
import { View, Image, Text, StyleSheet, ViewStyle, ImageSourcePropType } from 'react-native';

interface AvatarProps {
  source?: ImageSourcePropType;
  fallback?: string;
  size?: 'sm' | 'md' | 'lg';
  style?: ViewStyle;
}

export const Avatar: React.FC<AvatarProps> = ({
  source,
  fallback,
  size = 'md',
  style,
}) => {
  const getSizeStyle = () => {
    switch (size) {
      case 'sm':
        return styles.small;
      case 'md':
        return styles.medium;
      case 'lg':
        return styles.large;
      default:
        return styles.medium;
    }
  };

  const getFallbackSizeStyle = () => {
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
    <View style={[styles.container, getSizeStyle(), style]}>
      {source ? (
        <Image source={source} style={styles.image} />
      ) : (
        <AvatarFallback size={size}>{fallback}</AvatarFallback>
      )}
    </View>
  );
};

interface AvatarImageProps {
  source: ImageSourcePropType;
  alt?: string;
  style?: ViewStyle;
}

export const AvatarImage: React.FC<AvatarImageProps> = ({
  source,
  alt,
  style,
}) => {
  return <Image source={source} style={[styles.image, style]} accessibilityLabel={alt} />;
};

interface AvatarFallbackProps {
  children?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg';
  style?: ViewStyle;
}

export const AvatarFallback: React.FC<AvatarFallbackProps> = ({
  children,
  size = 'md',
  style,
}) => {
  const getFallbackSizeStyle = () => {
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
    <View style={[styles.fallback, style]}>
      <Text style={[styles.fallbackText, getFallbackSizeStyle()]}>{children}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 9999,
    overflow: 'hidden',
    backgroundColor: '#e5e7eb',
  },
  small: {
    width: 32,
    height: 32,
  },
  medium: {
    width: 40,
    height: 40,
  },
  large: {
    width: 64,
    height: 64,
  },
  image: {
    width: '100%',
    height: '100%',
  },
  fallback: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#9ca3af',
  },
  fallbackText: {
    color: 'white',
    fontWeight: '600',
  },
  smallText: {
    fontSize: 12,
  },
  mediumText: {
    fontSize: 16,
  },
  largeText: {
    fontSize: 24,
  },
});

export default { Avatar, AvatarImage, AvatarFallback };

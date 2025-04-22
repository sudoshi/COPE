import React from 'react';
import { View, Image, Text, StyleSheet, ViewStyle, ImageStyle, ImageSourcePropType } from 'react-native';
import { useThemeColor } from '../../hooks/useThemeColor';

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

  const backgroundColor = useThemeColor({}, 'background');
  const containerStyle = [styles.container, { backgroundColor }, getSizeStyle()];
  // Only pass style to View, not Image
  return (
    <View style={[...containerStyle, style]}>
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
  style?: ImageStyle;
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

  const backgroundColor = useThemeColor({}, 'icon');
  return (
    <View style={[styles.fallback, { backgroundColor }, style]}>
      <Text style={[styles.fallbackText, getFallbackSizeStyle()]}>{children}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 9999,
    overflow: 'hidden',
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

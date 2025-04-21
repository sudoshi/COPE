import React, { createContext, useContext, useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ViewStyle, TextStyle } from 'react-native';

// Create context for tabs
interface TabsContextType {
  value: string;
  onValueChange: (value: string) => void;
}

const TabsContext = createContext<TabsContextType | undefined>(undefined);

interface TabsProps {
  defaultValue: string;
  value?: string;
  onValueChange?: (value: string) => void;
  children: React.ReactNode;
  style?: ViewStyle;
}

export const Tabs: React.FC<TabsProps> = ({
  defaultValue,
  value,
  onValueChange,
  children,
  style,
}) => {
  const [tabValue, setTabValue] = useState(defaultValue);

  const currentValue = value !== undefined ? value : tabValue;
  const handleValueChange = onValueChange || setTabValue;

  return (
    <TabsContext.Provider value={{ value: currentValue, onValueChange: handleValueChange }}>
      <View style={[styles.container, style]}>{children}</View>
    </TabsContext.Provider>
  );
};

interface TabsListProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const TabsList: React.FC<TabsListProps> = ({ children, style }) => {
  return <View style={[styles.list, style]}>{children}</View>;
};

interface TabsTriggerProps {
  value: string;
  children: React.ReactNode;
  style?: ViewStyle;
  activeStyle?: ViewStyle;
  textStyle?: TextStyle;
  activeTextStyle?: TextStyle;
}

export const TabsTrigger: React.FC<TabsTriggerProps> = ({
  value,
  children,
  style,
  activeStyle,
  textStyle,
  activeTextStyle,
}) => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('TabsTrigger must be used within a Tabs component');
  }

  const { value: selectedValue, onValueChange } = context;
  const isActive = selectedValue === value;

  return (
    <TouchableOpacity
      style={[styles.trigger, isActive && styles.activeTrigger, style, isActive && activeStyle]}
      onPress={() => onValueChange(value)}
    >
      <Text
        style={[
          styles.triggerText,
          isActive && styles.activeTriggerText,
          textStyle,
          isActive && activeTextStyle,
        ]}
      >
        {children}
      </Text>
    </TouchableOpacity>
  );
};

interface TabsContentProps {
  value: string;
  children: React.ReactNode;
  style?: ViewStyle;
}

export const TabsContent: React.FC<TabsContentProps> = ({ value, children, style }) => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('TabsContent must be used within a Tabs component');
  }

  const { value: selectedValue } = context;
  const isSelected = selectedValue === value;

  if (!isSelected) return null;

  return <View style={[styles.content, style]}>{children}</View>;
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  list: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  trigger: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
  },
  activeTrigger: {
    borderBottomWidth: 2,
    borderBottomColor: '#7c3aed',
  },
  triggerText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#6b7280',
  },
  activeTriggerText: {
    color: '#7c3aed',
  },
  content: {
    flex: 1,
  },
});

export default { Tabs, TabsList, TabsTrigger, TabsContent };

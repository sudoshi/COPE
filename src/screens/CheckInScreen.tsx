import React from 'react';
import { View } from 'react-native';
import { MorningCheckIn } from '../components/check-in/MorningCheckIn';
import { AfternoonCheckIn } from '../components/check-in/AfternoonCheckIn';
import { EveningCheckIn } from '../components/check-in/EveningCheckIn';
import { useAppContext } from '../context/AppContext';

const CheckInScreen = () => {
  const { dailyCheckIns } = useAppContext();
  const today = new Date();

  const getTimeOfDay = () => {
    const hour = today.getHours();
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    return 'evening';
  };

  const hasCompletedCurrentCheckIn = () => {
    const timeOfDay = getTimeOfDay();
    const todayCheckIns = dailyCheckIns.filter(
      checkIn => checkIn.date.toDateString() === today.toDateString()
    );
    return todayCheckIns.some(checkIn => checkIn.timeOfDay === timeOfDay);
  };

  const renderAppropriateCheckIn = () => {
    if (hasCompletedCurrentCheckIn()) {
      return (
        <View>
          <Text>You've completed your {getTimeOfDay()} check-in. Return later for your next check-in.</Text>
        </View>
      );
    }

    switch (getTimeOfDay()) {
      case 'morning':
        return <MorningCheckIn />;
      case 'afternoon':
        return <AfternoonCheckIn />;
      case 'evening':
        return <EveningCheckIn />;
    }
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      {renderAppropriateCheckIn()}
    </SafeAreaView>
  );
};

export default CheckInScreen;
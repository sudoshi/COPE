import * as Notifications from 'expo-notifications';

const NOTIFICATION_IDS = {
  MORNING: 'morning-check-in',
  AFTERNOON: 'afternoon-check-in',
  EVENING: 'evening-check-in',
};

export const scheduleCheckInReminders = async () => {
  // Cancel any existing notifications
  await Notifications.cancelAllScheduledNotificationsAsync();

  // Schedule Morning Check-in (8 AM)
  await Notifications.scheduleNotificationAsync({
    content: {
      title: "Morning Check-in",
      body: "How did you sleep? Take a moment to record your morning state.",
      data: { type: 'morning' },
    },
    trigger: {
      hour: 8,
      minute: 0,
      repeats: true,
    },
    identifier: NOTIFICATION_IDS.MORNING,
  });

  // Schedule Afternoon Check-in (2 PM)
  await Notifications.scheduleNotificationAsync({
    content: {
      title: "Afternoon Check-in",
      body: "How's your day going? Record your thoughts and feelings.",
      data: { type: 'afternoon' },
    },
    trigger: {
      hour: 14,
      minute: 0,
      repeats: true,
    },
    identifier: NOTIFICATION_IDS.AFTERNOON,
  });

  // Schedule Evening Check-in (8 PM)
  await Notifications.scheduleNotificationAsync({
    content: {
      title: "Evening Check-in",
      body: "Time to reflect on your day.",
      data: { type: 'evening' },
    },
    trigger: {
      hour: 20,
      minute: 0,
      repeats: true,
    },
    identifier: NOTIFICATION_IDS.EVENING,
  });
};

export const setupNotifications = async () => {
  const { status } = await Notifications.requestPermissionsAsync();
  if (status === 'granted') {
    await scheduleCheckInReminders();
  }
};
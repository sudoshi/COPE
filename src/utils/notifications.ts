import PushNotification from 'react-native-push-notification';

const NOTIFICATION_IDS = {
  MORNING: 'morning-check-in',
  AFTERNOON: 'afternoon-check-in',
  EVENING: 'evening-check-in',
};

// Initialize PushNotification (should be called once, e.g., in App.tsx)
PushNotification.configure({
  onNotification: function (notification) {
    // Handle notification
  },
  requestPermissions: true,
});

export const scheduleCheckInReminders = async () => {
  // Cancel all existing notifications
  PushNotification.cancelAllLocalNotifications();

  // Schedule Morning Check-in (8 AM)
  PushNotification.localNotificationSchedule({
    id: NOTIFICATION_IDS.MORNING,
    channelId: 'check-in-reminders',
    title: 'Morning Check-in',
    message: 'How did you sleep? Take a moment to record your morning state.',
    date: getNextTriggerDate(8, 0),
    repeatType: 'day',
    allowWhileIdle: true,
    userInfo: { type: 'morning' },
  });

  // Schedule Afternoon Check-in (2 PM)
  PushNotification.localNotificationSchedule({
    id: NOTIFICATION_IDS.AFTERNOON,
    channelId: 'check-in-reminders',
    title: 'Afternoon Check-in',
    message: "How's your day going? Record your thoughts and feelings.",
    date: getNextTriggerDate(14, 0),
    repeatType: 'day',
    allowWhileIdle: true,
    userInfo: { type: 'afternoon' },
  });

  // Schedule Evening Check-in (8 PM)
  PushNotification.localNotificationSchedule({
    id: NOTIFICATION_IDS.EVENING,
    channelId: 'check-in-reminders',
    title: 'Evening Check-in',
    message: 'Time to reflect on your day.',
    date: getNextTriggerDate(20, 0),
    repeatType: 'day',
    allowWhileIdle: true,
    userInfo: { type: 'evening' },
  });
};

// Helper to get the next trigger date for a given hour and minute
function getNextTriggerDate(hour: number, minute: number): Date {
  const now = new Date();
  const trigger = new Date();
  trigger.setHours(hour, minute, 0, 0);
  if (trigger <= now) {
    trigger.setDate(trigger.getDate() + 1);
  }
  return trigger;
}

export const setupNotifications = async () => {
  // Create channel (required for Android)
  PushNotification.createChannel(
    {
      channelId: 'check-in-reminders',
      channelName: 'Check-in Reminders',
      channelDescription: 'Reminders for daily check-ins',
      importance: 4,
      vibrate: true,
    },
    (created) => {
      // Channel created
      scheduleCheckInReminders();
    }
  );
};

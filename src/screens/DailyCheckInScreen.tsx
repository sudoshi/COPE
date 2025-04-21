import { DailyCheckIn } from '../components/DailyCheckIn';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppContext } from '../context/AppContext';
import { useToast } from '@/hooks/use-toast';

const DailyCheckInScreen = () => {
  const { addDailyCheckIn } = useAppContext();
  const { toast } = useToast();

  const handleSubmit = (checkInData: any) => {
    addDailyCheckIn({
      ...checkInData,
      date: new Date(),
    });

    toast({
      title: "Check-in Submitted",
      description: "Your daily check-in has been recorded.",
    });
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <DailyCheckIn onSubmit={handleSubmit} />
    </SafeAreaView>
  );
};

export default DailyCheckInScreen;
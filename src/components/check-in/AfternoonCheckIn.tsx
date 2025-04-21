import React from 'react';
import { Card, CardContent, CardFooter } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { useToast } from '@/hooks/use-toast';

export const AfternoonCheckIn = () => {
  const [thoughtPatterns, setThoughtPatterns] = useState<string[]>([]);
  const [physicalSensations, setPhysicalSensations] = useState<string[]>([]);
  const [behaviors, setBehaviors] = useState<string[]>([]);
  const [productivity, setProductivity] = useState<string | null>(null);
  const { toast } = useToast();

  const handleSubmit = () => {
    const afternoonData = {
      thoughtPatterns,
      physicalSensations,
      behaviors,
      productivity,
      timestamp: new Date(),
    };

    // Submit to context/API
    toast({
      title: "Afternoon Check-in Submitted",
      description: "Your afternoon check-in has been recorded.",
    });
  };

  return (
    <Card>
      <CardContent>
        {/* Afternoon-specific fields */}
        {/* Thought Patterns */}
        {/* Physical Sensations */}
        {/* Behaviors */}
        {/* Productivity */}
      </CardContent>
      <CardFooter>
        <Button onClick={handleSubmit}>Submit Afternoon Check-In</Button>
      </CardFooter>
    </Card>
  );
};
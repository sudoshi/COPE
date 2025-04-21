import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth } from './AuthContext';
import * as db from '../services/database';

// Define types for our context
type MoodEntry = {
  id: string;
  value: number;
  date: Date;
  notes?: string;
  symptoms?: string[];
};

type MedicationDose = {
  id: string;
  medicationId: string;
  taken: boolean;
  scheduledTime: Date;
  takenTime?: Date;
};

type Medication = {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
  timeOfDay: 'morning' | 'afternoon' | 'evening' | 'night';
  instructions?: string;
};

type SleepData = {
  id: string;
  date: Date;
  duration: number; // in hours
  quality: number; // 1-10
  deepSleep?: number; // in hours
  remSleep?: number; // in hours
};

type BiometricData = {
  id: string;
  date: Date;
  heartRate?: number;
  hrv?: number;
  bloodPressure?: {
    systolic: number;
    diastolic: number;
  };
};

type UserProfile = {
  id: string;
  name: string;
  email: string;
  dateOfBirth?: Date;
  joinDate: Date;
  providers?: {
    id: string;
    name: string;
    role: string;
    contactInfo?: string;
  }[];
  emergencyContacts?: {
    id: string;
    name: string;
    relationship: string;
    contactInfo: string;
  }[];
};

interface AppContextType {
  // User data
  userProfile: UserProfile | null;
  setUserProfile: (profile: UserProfile | null) => void;

  // Mood tracking
  moodEntries: MoodEntry[];
  addMoodEntry: (entry: Omit<MoodEntry, 'id'>) => void;

  // Medication tracking
  medications: Medication[];
  medicationDoses: MedicationDose[];
  addMedication: (medication: Omit<Medication, 'id'>) => void;
  updateMedicationDose: (doseId: string, taken: boolean) => void;

  // Sleep tracking
  sleepData: SleepData[];
  addSleepData: (data: Omit<SleepData, 'id'>) => void;

  // Biometric data
  biometricData: BiometricData[];
  addBiometricData: (data: Omit<BiometricData, 'id'>) => void;

  // App state
  isLoading: boolean;
  setIsLoading: (loading: boolean) => void;
  error: string | null;
  setError: (error: string | null) => void;
}

// Create the context with a default value
const AppContext = createContext<AppContextType | undefined>(undefined);

// Generate a random ID for new entries
const generateId = () => Math.random().toString(36).substring(2, 15);

// Provider component that wraps the app
export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // User data
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);

  // Mood tracking
  const [moodEntries, setMoodEntries] = useState<MoodEntry[]>([]);

  // Medication tracking
  const [medications, setMedications] = useState<Medication[]>([]);
  const [medicationDoses, setMedicationDoses] = useState<MedicationDose[]>([]);

  // Sleep tracking
  const [sleepData, setSleepData] = useState<SleepData[]>([]);

  // Biometric data
  const [biometricData, setBiometricData] = useState<BiometricData[]>([]);

  // App state
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Initialize with sample data
  useEffect(() => {
    // Sample user profile
    setUserProfile({
      id: '1',
      name: 'Emily Morgan',
      email: 'emily.morgan@example.com',
      dateOfBirth: new Date(1988, 4, 12),
      joinDate: new Date(2025, 0, 15),
      providers: [
        {
          id: '1',
          name: 'Dr. Sarah Chen',
          role: 'Psychiatrist',
          contactInfo: '+1 (555) 123-4567',
        },
        {
          id: '2',
          name: 'Dr. Michael Torres',
          role: 'Therapist (CBT)',
          contactInfo: '+1 (555) 987-6543',
        },
      ],
      emergencyContacts: [
        {
          id: '1',
          name: 'Jennifer Morgan',
          relationship: 'Sister',
          contactInfo: '+1 (555) 234-5678',
        },
      ],
    });

    // Sample mood entries
    setMoodEntries([
      {
        id: '1',
        value: 7,
        date: new Date(2025, 3, 15, 9, 30),
        notes: 'Feeling good today, had a productive morning.',
        symptoms: ['Low energy'],
      },
      {
        id: '2',
        value: 5,
        date: new Date(2025, 3, 14, 19, 45),
        notes: 'Stressful day at work, but managed to relax in the evening.',
        symptoms: ['Anxious thoughts', 'Restlessness'],
      },
      {
        id: '3',
        value: 8,
        date: new Date(2025, 3, 13, 12, 15),
        notes: 'Great day! Exercise in the morning helped a lot.',
      },
    ]);

    // Sample medications
    setMedications([
      {
        id: '1',
        name: 'Escitalopram',
        dosage: '10mg',
        frequency: 'daily',
        timeOfDay: 'evening',
        instructions: 'Take with food',
      },
      {
        id: '2',
        name: 'Lamotrigine',
        dosage: '100mg',
        frequency: 'twice daily',
        timeOfDay: 'morning',
        instructions: 'Take with water',
      },
    ]);

    // Sample medication doses
    setMedicationDoses([
      {
        id: '1',
        medicationId: '1',
        taken: false,
        scheduledTime: new Date(2025, 3, 15, 19, 0),
      },
      {
        id: '2',
        medicationId: '2',
        taken: true,
        scheduledTime: new Date(2025, 3, 15, 8, 0),
        takenTime: new Date(2025, 3, 15, 8, 15),
      },
    ]);

    // Sample sleep data
    setSleepData([
      {
        id: '1',
        date: new Date(2025, 3, 15),
        duration: 7.2,
        quality: 8,
        deepSleep: 1.8,
        remSleep: 1.5,
      },
      {
        id: '2',
        date: new Date(2025, 3, 14),
        duration: 6.5,
        quality: 6,
        deepSleep: 1.5,
        remSleep: 1.2,
      },
      {
        id: '3',
        date: new Date(2025, 3, 13),
        duration: 8.0,
        quality: 9,
        deepSleep: 2.2,
        remSleep: 1.8,
      },
    ]);

    // Sample biometric data
    setBiometricData([
      {
        id: '1',
        date: new Date(2025, 3, 15, 9, 0),
        heartRate: 72,
        hrv: 68,
        bloodPressure: {
          systolic: 120,
          diastolic: 80,
        },
      },
      {
        id: '2',
        date: new Date(2025, 3, 14, 9, 0),
        heartRate: 75,
        hrv: 65,
        bloodPressure: {
          systolic: 122,
          diastolic: 82,
        },
      },
      {
        id: '3',
        date: new Date(2025, 3, 13, 9, 0),
        heartRate: 70,
        hrv: 70,
        bloodPressure: {
          systolic: 118,
          diastolic: 78,
        },
      },
    ]);
  }, []);

  // Add a new mood entry
  const addMoodEntry = (entry: Omit<MoodEntry, 'id'>) => {
    const newEntry = { ...entry, id: generateId() };
    setMoodEntries([newEntry, ...moodEntries]);
  };

  // Add a new medication
  const addMedication = (medication: Omit<Medication, 'id'>) => {
    const newMedication = { ...medication, id: generateId() };
    setMedications([...medications, newMedication]);
  };

  // Update a medication dose
  const updateMedicationDose = (doseId: string, taken: boolean) => {
    setMedicationDoses(
      medicationDoses.map((dose) =>
        dose.id === doseId
          ? { ...dose, taken, takenTime: taken ? new Date() : undefined }
          : dose
      )
    );
  };

  // Add sleep data
  const addSleepData = (data: Omit<SleepData, 'id'>) => {
    const newData = { ...data, id: generateId() };
    setSleepData([newData, ...sleepData]);
  };

  // Add biometric data
  const addBiometricData = (data: Omit<BiometricData, 'id'>) => {
    const newData = { ...data, id: generateId() };
    setBiometricData([newData, ...biometricData]);
  };

  // Create the context value object
  const contextValue: AppContextType = {
    userProfile,
    setUserProfile,
    moodEntries,
    addMoodEntry,
    medications,
    medicationDoses,
    addMedication,
    updateMedicationDose,
    sleepData,
    addSleepData,
    biometricData,
    addBiometricData,
    isLoading,
    setIsLoading,
    error,
    setError,
  };

  return <AppContext.Provider value={contextValue}>{children}</AppContext.Provider>;
};

// Custom hook to use the app context
export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};

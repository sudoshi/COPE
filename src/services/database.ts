import { supabase } from '../lib/supabase';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Types
export type MoodEntry = {
  id: string;
  user_id: string;
  value: number;
  date: string;
  notes?: string;
  symptoms?: string[];
  created_at: string;
};

export type Medication = {
  id: string;
  user_id: string;
  name: string;
  dosage: string;
  frequency: string;
  time_of_day: 'morning' | 'afternoon' | 'evening' | 'night';
  instructions?: string;
  created_at: string;
};

export type MedicationDose = {
  id: string;
  user_id: string;
  medication_id: string;
  taken: boolean;
  scheduled_time: string;
  taken_time?: string;
  created_at: string;
};

export type SleepData = {
  id: string;
  user_id: string;
  date: string;
  duration: number;
  quality: number;
  deep_sleep?: number;
  rem_sleep?: number;
  created_at: string;
};

export type BiometricData = {
  id: string;
  user_id: string;
  date: string;
  heart_rate?: number;
  hrv?: number;
  systolic?: number;
  diastolic?: number;
  created_at: string;
};

export type UserProfile = {
  id: string;
  user_id: string;
  name: string;
  date_of_birth?: string;
  join_date: string;
  created_at: string;
};

export type Provider = {
  id: string;
  user_id: string;
  name: string;
  role: string;
  contact_info?: string;
  created_at: string;
};

export type EmergencyContact = {
  id: string;
  user_id: string;
  name: string;
  relationship: string;
  contact_info: string;
  created_at: string;
};

// Helper function to handle offline storage
const storeOfflineData = async (key: string, data: any) => {
  try {
    const existingData = await AsyncStorage.getItem(key);
    let newData = [];
    
    if (existingData) {
      newData = JSON.parse(existingData);
    }
    
    if (Array.isArray(data)) {
      newData = [...newData, ...data];
    } else {
      newData.push(data);
    }
    
    await AsyncStorage.setItem(key, JSON.stringify(newData));
    return true;
  } catch (error) {
    console.error(`Error storing offline data for ${key}:`, error);
    return false;
  }
};

const getOfflineData = async (key: string) => {
  try {
    const data = await AsyncStorage.getItem(key);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error(`Error retrieving offline data for ${key}:`, error);
    return [];
  }
};

// User Profile
export const getUserProfile = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching user profile:', error);
    
    // Try to get from offline storage
    const offlineData = await getOfflineData('user_profile');
    return offlineData.find((profile: UserProfile) => profile.user_id === userId);
  }
};

export const createUserProfile = async (profile: Omit<UserProfile, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .insert([profile])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating user profile:', error);
    
    // Store offline
    const offlineProfile = {
      ...profile,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('user_profile', offlineProfile);
    return offlineProfile;
  }
};

export const updateUserProfile = async (userId: string, updates: Partial<UserProfile>) => {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .update(updates)
      .eq('user_id', userId)
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error updating user profile:', error);
    
    // Update offline
    const offlineData = await getOfflineData('user_profile');
    const updatedData = offlineData.map((profile: UserProfile) => {
      if (profile.user_id === userId) {
        return { ...profile, ...updates };
      }
      return profile;
    });
    await AsyncStorage.setItem('user_profile', JSON.stringify(updatedData));
    return updatedData.find((profile: UserProfile) => profile.user_id === userId);
  }
};

// Mood Entries
export const getMoodEntries = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('mood_entries')
      .select('*')
      .eq('user_id', userId)
      .order('date', { ascending: false });
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching mood entries:', error);
    
    // Try to get from offline storage
    return await getOfflineData('mood_entries');
  }
};

export const createMoodEntry = async (entry: Omit<MoodEntry, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('mood_entries')
      .insert([entry])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating mood entry:', error);
    
    // Store offline
    const offlineEntry = {
      ...entry,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('mood_entries', offlineEntry);
    return offlineEntry;
  }
};

// Medications
export const getMedications = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('medications')
      .select('*')
      .eq('user_id', userId);
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching medications:', error);
    
    // Try to get from offline storage
    return await getOfflineData('medications');
  }
};

export const createMedication = async (medication: Omit<Medication, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('medications')
      .insert([medication])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating medication:', error);
    
    // Store offline
    const offlineMedication = {
      ...medication,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('medications', offlineMedication);
    return offlineMedication;
  }
};

// Medication Doses
export const getMedicationDoses = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('medication_doses')
      .select('*')
      .eq('user_id', userId)
      .order('scheduled_time', { ascending: true });
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching medication doses:', error);
    
    // Try to get from offline storage
    return await getOfflineData('medication_doses');
  }
};

export const createMedicationDose = async (dose: Omit<MedicationDose, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('medication_doses')
      .insert([dose])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating medication dose:', error);
    
    // Store offline
    const offlineDose = {
      ...dose,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('medication_doses', offlineDose);
    return offlineDose;
  }
};

export const updateMedicationDose = async (doseId: string, updates: Partial<MedicationDose>) => {
  try {
    const { data, error } = await supabase
      .from('medication_doses')
      .update(updates)
      .eq('id', doseId)
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error updating medication dose:', error);
    
    // Update offline
    const offlineData = await getOfflineData('medication_doses');
    const updatedData = offlineData.map((dose: MedicationDose) => {
      if (dose.id === doseId) {
        return { ...dose, ...updates };
      }
      return dose;
    });
    await AsyncStorage.setItem('medication_doses', JSON.stringify(updatedData));
    return updatedData.find((dose: MedicationDose) => dose.id === doseId);
  }
};

// Sleep Data
export const getSleepData = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('sleep_data')
      .select('*')
      .eq('user_id', userId)
      .order('date', { ascending: false });
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching sleep data:', error);
    
    // Try to get from offline storage
    return await getOfflineData('sleep_data');
  }
};

export const createSleepData = async (sleepData: Omit<SleepData, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('sleep_data')
      .insert([sleepData])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating sleep data:', error);
    
    // Store offline
    const offlineSleepData = {
      ...sleepData,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('sleep_data', offlineSleepData);
    return offlineSleepData;
  }
};

// Biometric Data
export const getBiometricData = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('biometric_data')
      .select('*')
      .eq('user_id', userId)
      .order('date', { ascending: false });
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching biometric data:', error);
    
    // Try to get from offline storage
    return await getOfflineData('biometric_data');
  }
};

export const createBiometricData = async (biometricData: Omit<BiometricData, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('biometric_data')
      .insert([biometricData])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating biometric data:', error);
    
    // Store offline
    const offlineBiometricData = {
      ...biometricData,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('biometric_data', offlineBiometricData);
    return offlineBiometricData;
  }
};

// Providers
export const getProviders = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('providers')
      .select('*')
      .eq('user_id', userId);
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching providers:', error);
    
    // Try to get from offline storage
    return await getOfflineData('providers');
  }
};

export const createProvider = async (provider: Omit<Provider, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('providers')
      .insert([provider])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating provider:', error);
    
    // Store offline
    const offlineProvider = {
      ...provider,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('providers', offlineProvider);
    return offlineProvider;
  }
};

// Emergency Contacts
export const getEmergencyContacts = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('emergency_contacts')
      .select('*')
      .eq('user_id', userId);
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error fetching emergency contacts:', error);
    
    // Try to get from offline storage
    return await getOfflineData('emergency_contacts');
  }
};

export const createEmergencyContact = async (contact: Omit<EmergencyContact, 'id' | 'created_at'>) => {
  try {
    const { data, error } = await supabase
      .from('emergency_contacts')
      .insert([contact])
      .select()
      .single();
      
    if (error) throw error;
    
    return data;
  } catch (error) {
    console.error('Error creating emergency contact:', error);
    
    // Store offline
    const offlineContact = {
      ...contact,
      id: `offline_${Date.now()}`,
      created_at: new Date().toISOString(),
    };
    await storeOfflineData('emergency_contacts', offlineContact);
    return offlineContact;
  }
};

// Sync offline data with the server
export const syncOfflineData = async (userId: string) => {
  try {
    // Sync mood entries
    const offlineMoodEntries = await getOfflineData('mood_entries');
    for (const entry of offlineMoodEntries) {
      if (entry.id.startsWith('offline_')) {
        const { id, created_at, ...entryData } = entry;
        await createMoodEntry({ ...entryData, user_id: userId });
      }
    }
    
    // Sync medications
    const offlineMedications = await getOfflineData('medications');
    for (const medication of offlineMedications) {
      if (medication.id.startsWith('offline_')) {
        const { id, created_at, ...medicationData } = medication;
        await createMedication({ ...medicationData, user_id: userId });
      }
    }
    
    // Sync medication doses
    const offlineMedicationDoses = await getOfflineData('medication_doses');
    for (const dose of offlineMedicationDoses) {
      if (dose.id.startsWith('offline_')) {
        const { id, created_at, ...doseData } = dose;
        await createMedicationDose({ ...doseData, user_id: userId });
      }
    }
    
    // Sync sleep data
    const offlineSleepData = await getOfflineData('sleep_data');
    for (const data of offlineSleepData) {
      if (data.id.startsWith('offline_')) {
        const { id, created_at, ...sleepData } = data;
        await createSleepData({ ...sleepData, user_id: userId });
      }
    }
    
    // Sync biometric data
    const offlineBiometricData = await getOfflineData('biometric_data');
    for (const data of offlineBiometricData) {
      if (data.id.startsWith('offline_')) {
        const { id, created_at, ...biometricData } = data;
        await createBiometricData({ ...biometricData, user_id: userId });
      }
    }
    
    // Clear offline data
    await AsyncStorage.multiRemove([
      'mood_entries',
      'medications',
      'medication_doses',
      'sleep_data',
      'biometric_data',
      'providers',
      'emergency_contacts',
    ]);
    
    return true;
  } catch (error) {
    console.error('Error syncing offline data:', error);
    return false;
  }
};

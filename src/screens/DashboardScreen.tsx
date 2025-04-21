import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, SafeAreaView, Image, TouchableOpacity } from 'react-native';
import { ScrollArea } from '../components/ui';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui';
import { Badge } from '../components/ui';
import { Button } from '../components/ui';
import { Progress } from '../components/ui';
import { Slider } from '../components/ui';
import { Avatar, AvatarImage, AvatarFallback } from '../components/ui';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '../context/AppContext';
import { formatDate, getRelativeTime } from '../utils/dateUtils';

const DashboardScreen = () => {
  const {
    userProfile,
    moodEntries,
    addMoodEntry,
    medications,
    medicationDoses,
    updateMedicationDose,
    biometricData,
    sleepData
  } = useAppContext();

  const [currentDate, setCurrentDate] = useState('');
  const [moodValue, setMoodValue] = useState(7);
  const [progress, setProgress] = useState(0);

  // Get the latest biometric data
  const latestBiometricData = biometricData.length > 0 ? biometricData[0] : null;

  // Get the latest sleep data
  const latestSleepData = sleepData.length > 0 ? sleepData[0] : null;

  // Get the next medication dose
  const nextMedicationDose = medicationDoses.find(dose => !dose.taken);
  const nextMedication = nextMedicationDose
    ? medications.find(med => med.id === nextMedicationDose.medicationId)
    : null;

  useEffect(() => {
    const date = new Date();
    setCurrentDate(formatDate(date));

    // Initialize progress animation
    const timer = setTimeout(() => {
      if (latestSleepData) {
        setProgress(latestSleepData.quality * 10);
      } else {
        setProgress(78);
      }
    }, 500);

    return () => {
      clearTimeout(timer);
    };
  }, [latestSleepData]);

  // Handle saving a new mood entry
  const handleSaveMood = () => {
    addMoodEntry({
      value: moodValue,
      date: new Date(),
    });
  };

  // Handle taking or skipping medication
  const handleMedicationAction = (doseId: string, taken: boolean) => {
    updateMedicationDose(doseId, taken);
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Top Navigation */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Image
            source={{ uri: 'https://via.placeholder.com/40' }}
            style={styles.logo}
          />
          <Text style={styles.headerTitle}>COPE</Text>
        </View>
        <View style={styles.headerRight}>
          <Button
            title=""
            variant="ghost"
            size="sm"
            icon={<Ionicons name="notifications-outline" size={24} color="#6b7280" />}
            onPress={() => {}}
          />
          <Avatar style={styles.avatar}>
            <AvatarImage source={{ uri: 'https://via.placeholder.com/40' }} />
            <AvatarFallback>JD</AvatarFallback>
          </Avatar>
        </View>
      </View>

      {/* Main Content */}
      <ScrollArea style={styles.scrollArea}>
        <View style={styles.content}>
          <View style={styles.greeting}>
            <Text style={styles.greetingTitle}>Good afternoon, Emily</Text>
            <Text style={styles.greetingDate}>{currentDate}</Text>
          </View>

          {/* Quick Mood Check-in */}
          <Card style={styles.moodCard}>
            <CardContent>
              <Text style={styles.cardTitle}>How are you feeling right now?</Text>
              <View style={styles.sliderContainer}>
                <Text style={styles.sliderLabel}>Low</Text>
                <Slider
                  defaultValue={[moodValue]}
                  max={10}
                  step={1}
                  style={styles.slider}
                  onValueChange={(value) => setMoodValue(value[0])}
                />
                <Text style={styles.sliderLabel}>High</Text>
              </View>
              <View style={styles.moodActions}>
                <Text style={styles.moodValue}>{moodValue}/10</Text>
                <Button title="Save Mood" onPress={handleSaveMood} />
              </View>
            </CardContent>
          </Card>

          {/* Daily Stats */}
          <Text style={styles.sectionTitle}>Today's Stats</Text>
          <View style={styles.statsGrid}>
            <Card style={styles.statCard}>
              <CardContent style={styles.statContent}>
                <View style={styles.statHeader}>
                  <Text style={styles.statLabel}>Heart Rate & HRV</Text>
                  <Ionicons name="heart" size={16} color="#ef4444" />
                </View>
                <View style={styles.statValue}>
                  <Text style={styles.statValueText}>
                    {latestBiometricData?.heartRate || 72}
                  </Text>
                  <Text style={styles.statValueUnit}>bpm</Text>
                </View>
                <View style={styles.statFooter}>
                  <Text style={styles.statFooterLabel}>HRV:</Text>
                  <Text style={styles.statFooterValue}>{latestBiometricData?.hrv || 68}ms</Text>
                  <Badge style={styles.statBadge}>Normal</Badge>
                </View>
              </CardContent>
            </Card>

            <Card style={styles.statCard}>
              <CardContent style={styles.statContent}>
                <View style={styles.statHeader}>
                  <Text style={styles.statLabel}>Sleep Quality</Text>
                  <Ionicons name="moon" size={16} color="#818cf8" />
                </View>
                <View style={styles.statValue}>
                  <Text style={styles.statValueText}>
                    {latestSleepData?.duration || 7.2}
                  </Text>
                  <Text style={styles.statValueUnit}>hrs</Text>
                </View>
                <View style={styles.statFooter}>
                  <Progress value={progress} style={styles.statProgress} />
                  <Text style={styles.statFooterValue}>78%</Text>
                </View>
              </CardContent>
            </Card>
          </View>

          {/* Medication Reminder */}
          <Card style={styles.medicationCard}>
            <CardContent>
              <View style={styles.medicationHeader}>
                <Text style={styles.cardTitle}>Medication Reminder</Text>
                <Badge style={styles.medicationBadge}>Due in 1h</Badge>
              </View>
              <View style={styles.medicationItem}>
                <View style={styles.medicationInfo}>
                  <View style={styles.medIcon}>
                    <Ionicons name="medical" size={20} color="#3b82f6" />
                  </View>
                  <View>
                    <Text style={styles.medicationName}>
                      {nextMedication?.name || 'Escitalopram'}
                    </Text>
                    <Text style={styles.medicationDose}>
                      {nextMedication?.dosage || '10mg'} - {nextMedication?.timeOfDay || 'Evening'} dose
                    </Text>
                  </View>
                </View>
                <View style={styles.medicationActions}>
                  <Button
                    title="Skip"
                    variant="outline"
                    size="sm"
                    onPress={() => nextMedicationDose && handleMedicationAction(nextMedicationDose.id, false)}
                  />
                  <Button
                    title="Take"
                    size="sm"
                    onPress={() => nextMedicationDose && handleMedicationAction(nextMedicationDose.id, true)}
                    style={styles.takeButton}
                  />
                </View>
              </View>
            </CardContent>
          </Card>

          {/* Quick Actions */}
          <Text style={styles.sectionTitle}>Quick Actions</Text>
          <View style={styles.quickActions}>
            <View style={styles.quickAction}>
              <View style={[styles.quickActionIcon, styles.journalIcon]}>
                <Ionicons name="create" size={24} color="#7c3aed" />
              </View>
              <Text style={styles.quickActionText}>Journal</Text>
            </View>
            <View style={styles.quickAction}>
              <View style={[styles.quickActionIcon, styles.medActionIcon]}>
                <Ionicons name="medical" size={24} color="#3b82f6" />
              </View>
              <Text style={styles.quickActionText}>Medication</Text>
            </View>
            <View style={styles.quickAction}>
              <View style={[styles.quickActionIcon, styles.insightsIcon]}>
                <Ionicons name="analytics" size={24} color="#10b981" />
              </View>
              <Text style={styles.quickActionText}>Insights</Text>
            </View>
            <View style={styles.quickAction}>
              <View style={[styles.quickActionIcon, styles.supportIcon]}>
                <Ionicons name="call" size={24} color="#ef4444" />
              </View>
              <Text style={styles.quickActionText}>Support</Text>
            </View>
          </View>
        </View>
      </ScrollArea>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 32,
    height: 32,
    marginRight: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1f2937',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    marginLeft: 8,
  },
  scrollArea: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  greeting: {
    marginBottom: 24,
  },
  greetingTitle: {
    fontSize: 20,
    fontWeight: '500',
    color: '#1f2937',
  },
  greetingDate: {
    fontSize: 14,
    color: '#6b7280',
  },
  moodCard: {
    marginBottom: 24,
    backgroundColor: '#f5f3ff',
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 12,
  },
  sliderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  sliderLabel: {
    fontSize: 14,
    color: '#6b7280',
    width: 40,
  },
  slider: {
    flex: 1,
    marginHorizontal: 8,
  },
  moodActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  moodValue: {
    fontSize: 24,
    fontWeight: '600',
    color: '#7c3aed',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 12,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -6,
    marginBottom: 24,
  },
  statCard: {
    width: '50%',
    paddingHorizontal: 6,
    marginBottom: 12,
  },
  statContent: {
    padding: 12,
  },
  statHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#6b7280',
  },
  statValue: {
    flexDirection: 'row',
    alignItems: 'flex-end',
  },
  statValueText: {
    fontSize: 20,
    fontWeight: '600',
    color: '#1f2937',
  },
  statValueUnit: {
    fontSize: 12,
    color: '#6b7280',
    marginLeft: 4,
    marginBottom: 2,
  },
  statFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  statFooterLabel: {
    fontSize: 12,
    color: '#6b7280',
  },
  statFooterValue: {
    fontSize: 12,
    fontWeight: '500',
    color: '#374151',
    marginLeft: 4,
  },
  statBadge: {
    marginLeft: 8,
    backgroundColor: '#d1fae5',
  },
  statProgress: {
    width: 64,
    height: 6,
  },
  medicationCard: {
    marginBottom: 24,
    backgroundColor: '#eff6ff',
  },
  medicationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  medicationBadge: {
    backgroundColor: '#fef3c7',
  },
  medicationItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  medicationInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  medIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#dbeafe',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  medicationName: {
    fontSize: 14,
    fontWeight: '500',
    color: '#1f2937',
  },
  medicationDose: {
    fontSize: 12,
    color: '#6b7280',
  },
  medicationActions: {
    flexDirection: 'row',
  },
  takeButton: {
    marginLeft: 8,
    backgroundColor: '#3b82f6',
  },
  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  quickAction: {
    alignItems: 'center',
  },
  quickActionIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 4,
  },
  journalIcon: {
    backgroundColor: '#f3e8ff',
  },
  medActionIcon: {
    backgroundColor: '#dbeafe',
  },
  insightsIcon: {
    backgroundColor: '#d1fae5',
  },
  supportIcon: {
    backgroundColor: '#fee2e2',
  },
  quickActionText: {
    fontSize: 12,
    color: '#6b7280',
  },
});

export default DashboardScreen;

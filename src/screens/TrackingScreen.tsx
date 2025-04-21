import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TextInput } from 'react-native';
import { ScrollArea } from '../components/ui';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui';
import { Badge } from '../components/ui';
import { Button } from '../components/ui';
import { Progress } from '../components/ui';
import { Slider } from '../components/ui';
import { Ionicons } from '@expo/vector-icons';

const TrackingScreen = () => {
  const [moodValue, setMoodValue] = useState(7);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Health Tracking</Text>
        <Text style={styles.headerSubtitle}>Monitor your biometrics and symptoms</Text>
      </View>

      <ScrollArea style={styles.scrollArea}>
        <View style={styles.content}>
          {/* Biometric Section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Biometric Data</Text>

            {/* HRV Card */}
            <Card style={styles.card}>
              <CardHeader>
                <View style={styles.cardHeaderContent}>
                  <CardTitle>Heart Rate Variability</CardTitle>
                  <Badge style={styles.successBadge}>Normal</Badge>
                </View>
              </CardHeader>
              <CardContent>
                <View style={styles.chartPlaceholder}>
                  <Text style={styles.chartPlaceholderText}>HRV Chart</Text>
                </View>
                <View style={styles.cardFooter}>
                  <Text style={styles.footerText}>Baseline: 65ms</Text>
                  <Text style={styles.footerText}>Current: 68ms</Text>
                  <Text style={styles.footerText}>Change: +4.6%</Text>
                </View>
              </CardContent>
            </Card>

            {/* Sleep Card */}
            <Card style={styles.card}>
              <CardHeader>
                <View style={styles.cardHeaderContent}>
                  <CardTitle>Sleep Patterns</CardTitle>
                  <Badge style={styles.infoBadge}>Good</Badge>
                </View>
              </CardHeader>
              <CardContent>
                <View style={styles.chartPlaceholder}>
                  <Text style={styles.chartPlaceholderText}>Sleep Chart</Text>
                </View>
                <View style={styles.sleepStats}>
                  <View style={styles.sleepStat}>
                    <Text style={styles.sleepStatLabel}>Total Sleep</Text>
                    <Text style={styles.sleepStatValue}>7.2 hrs</Text>
                  </View>
                  <View style={styles.sleepStat}>
                    <Text style={styles.sleepStatLabel}>Deep Sleep</Text>
                    <Text style={styles.sleepStatValue}>1.8 hrs</Text>
                  </View>
                  <View style={styles.sleepStat}>
                    <Text style={styles.sleepStatLabel}>REM Sleep</Text>
                    <Text style={styles.sleepStatValue}>1.5 hrs</Text>
                  </View>
                </View>
              </CardContent>
            </Card>

            {/* Voice Analysis Card */}
            <Card style={styles.card}>
              <CardHeader>
                <View style={styles.cardHeaderContent}>
                  <CardTitle>Voice Analysis</CardTitle>
                  <Badge style={styles.successBadge}>Stable</Badge>
                </View>
              </CardHeader>
              <CardContent>
                <View style={styles.voiceAnalysis}>
                  <View>
                    <Text style={styles.voiceAnalysisLabel}>Last recording: 2 hours ago</Text>
                    <Text style={styles.voiceAnalysisText}>
                      Speech patterns show normal rhythm and tone
                    </Text>
                  </View>
                  <Button
                    title="Record"
                    variant="outline"
                    size="sm"
                    icon={<Ionicons name="mic" size={16} color="#7c3aed" style={styles.buttonIcon} />}
                    onPress={() => {}}
                  />
                </View>
                <View style={styles.voiceMetrics}>
                  <View style={styles.voiceMetric}>
                    <View style={styles.voiceMetricHeader}>
                      <Text style={styles.voiceMetricLabel}>Speech Rate</Text>
                      <Text style={styles.voiceMetricValue}>Normal</Text>
                    </View>
                    <Progress value={72} />
                  </View>
                  <View style={styles.voiceMetric}>
                    <View style={styles.voiceMetricHeader}>
                      <Text style={styles.voiceMetricLabel}>Tone Variation</Text>
                      <Text style={styles.voiceMetricValue}>Normal</Text>
                    </View>
                    <Progress value={85} />
                  </View>
                  <View style={styles.voiceMetric}>
                    <View style={styles.voiceMetricHeader}>
                      <Text style={styles.voiceMetricLabel}>Emotional Markers</Text>
                      <Text style={styles.voiceMetricValue}>Neutral</Text>
                    </View>
                    <Progress value={65} />
                  </View>
                </View>
              </CardContent>
            </Card>
          </View>

          {/* Mood Journal */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Mood Journal</Text>
            <Card style={styles.card}>
              <CardContent>
                <View style={styles.moodJournal}>
                  <Text style={styles.moodJournalTitle}>How are you feeling today?</Text>
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
                  <Text style={styles.moodValue}>{moodValue}/10</Text>
                </View>

                <View style={styles.symptomsSection}>
                  <Text style={styles.symptomsSectionTitle}>Select symptoms (if any)</Text>
                  <View style={styles.symptomsContainer}>
                    <Badge style={styles.symptomBadge}>Anxious thoughts</Badge>
                    <Badge style={styles.symptomBadge}>Low energy</Badge>
                    <Badge style={styles.symptomBadge}>Restlessness</Badge>
                    <Badge style={styles.symptomBadge}>Racing thoughts</Badge>
                    <Badge style={styles.symptomBadge}>Poor focus</Badge>
                    <Badge style={[styles.symptomBadge, styles.selectedSymptomBadge]}>Irritability</Badge>
                    <Badge style={styles.symptomBadge}>+ Add more</Badge>
                  </View>
                </View>

                <View style={styles.journalEntrySection}>
                  <Text style={styles.journalEntrySectionTitle}>Journal entry</Text>
                  <TextInput
                    style={styles.journalEntryInput}
                    placeholder="How was your day? Any specific thoughts or feelings?"
                    multiline
                    numberOfLines={4}
                  />
                </View>

                <View style={styles.journalActions}>
                  <Button
                    title="Voice Note"
                    variant="outline"
                    size="sm"
                    icon={<Ionicons name="mic" size={16} color="#6b7280" style={styles.buttonIcon} />}
                    onPress={() => {}}
                  />
                  <Button title="Save Entry" onPress={() => {}} />
                </View>
              </CardContent>
            </Card>
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
    padding: 16,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '500',
    color: '#1f2937',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#6b7280',
  },
  scrollArea: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 12,
  },
  card: {
    marginBottom: 16,
  },
  cardHeaderContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  chartPlaceholder: {
    height: 160,
    backgroundColor: '#f3f4f6',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  chartPlaceholderText: {
    fontSize: 16,
    color: '#9ca3af',
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  footerText: {
    fontSize: 12,
    color: '#6b7280',
  },
  successBadge: {
    backgroundColor: '#d1fae5',
  },
  infoBadge: {
    backgroundColor: '#dbeafe',
  },
  warningBadge: {
    backgroundColor: '#fef3c7',
  },
  sleepStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  sleepStat: {
    flex: 1,
    backgroundColor: '#f3f4f6',
    borderRadius: 8,
    padding: 8,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  sleepStatLabel: {
    fontSize: 12,
    color: '#6b7280',
    marginBottom: 4,
  },
  sleepStatValue: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
  },
  voiceAnalysis: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  voiceAnalysisLabel: {
    fontSize: 12,
    color: '#6b7280',
  },
  voiceAnalysisText: {
    fontSize: 14,
    color: '#374151',
  },
  buttonIcon: {
    marginRight: 4,
  },
  voiceMetrics: {
    backgroundColor: '#f9fafb',
    borderRadius: 8,
    padding: 12,
  },
  voiceMetric: {
    marginBottom: 12,
  },
  voiceMetricHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  voiceMetricLabel: {
    fontSize: 12,
    fontWeight: '500',
    color: '#374151',
  },
  voiceMetricValue: {
    fontSize: 12,
    color: '#6b7280',
  },
  moodJournal: {
    marginBottom: 16,
  },
  moodJournalTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 8,
  },
  sliderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  sliderLabel: {
    fontSize: 12,
    color: '#6b7280',
    width: 40,
  },
  slider: {
    flex: 1,
    marginHorizontal: 8,
  },
  moodValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#7c3aed',
    textAlign: 'right',
  },
  symptomsSection: {
    marginBottom: 16,
  },
  symptomsSectionTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 8,
  },
  symptomsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  symptomBadge: {
    backgroundColor: '#f3f4f6',
    marginRight: 8,
    marginBottom: 8,
  },
  selectedSymptomBadge: {
    backgroundColor: '#ede9fe',
  },
  journalEntrySection: {
    marginBottom: 16,
  },
  journalEntrySectionTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 8,
  },
  journalEntryInput: {
    borderWidth: 1,
    borderColor: '#e5e7eb',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    color: '#374151',
    height: 100,
    textAlignVertical: 'top',
  },
  journalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
});

export default TrackingScreen;

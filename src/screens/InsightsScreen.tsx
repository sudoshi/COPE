import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { ScrollArea } from '../components/ui';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui';
import { Badge } from '../components/ui';
import { Button } from '../components/ui';
import { Progress } from '../components/ui';
import Ionicons from 'react-native-vector-icons/Ionicons';

const InsightsScreen = () => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Health Insights</Text>
        <Text style={styles.headerSubtitle}>Understand your patterns and trends</Text>
      </View>

      <ScrollArea style={styles.scrollArea}>
        <View style={styles.content}>
          {/* Monthly Overview */}
          <Card style={styles.card}>
            <CardHeader>
              <View style={styles.cardHeaderContent}>
                <CardTitle>Monthly Overview</CardTitle>
                <Badge style={styles.purpleBadge}>April 2025</Badge>
              </View>
            </CardHeader>
            <CardContent>
              <View style={styles.chartPlaceholder}>
                <Text style={styles.chartPlaceholderText}>Monthly Overview Chart</Text>
              </View>
              <View style={styles.statsGrid}>
                <View style={[styles.statItem, styles.purpleStat]}>
                  <Text style={styles.statLabel}>Avg. Mood</Text>
                  <Text style={styles.statValue}>6.8/10</Text>
                </View>
                <View style={[styles.statItem, styles.blueStat]}>
                  <Text style={styles.statLabel}>Avg. Sleep</Text>
                  <Text style={styles.statValue}>7.1 hrs</Text>
                </View>
                <View style={[styles.statItem, styles.greenStat]}>
                  <Text style={styles.statLabel}>Med Adherence</Text>
                  <Text style={styles.statValue}>92%</Text>
                </View>
              </View>
            </CardContent>
          </Card>

          {/* Mood Patterns */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Mood Patterns</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.chartPlaceholder}>
                <Text style={styles.chartPlaceholderText}>Mood Patterns Chart</Text>
              </View>
              <View style={styles.insightsContainer}>
                <Text style={styles.insightsTitle}>Key Insights</Text>
                <View style={styles.insightsList}>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.purpleDot]} />
                    <Text style={styles.insightText}>
                      Your mood tends to improve after consistent sleep patterns of 7+ hours
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.purpleDot]} />
                    <Text style={styles.insightText}>
                      Morning exercise correlates with higher mood ratings throughout the day
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.purpleDot]} />
                    <Text style={styles.insightText}>
                      Potential mild mood cycling detected - discuss with your provider
                    </Text>
                  </View>
                </View>
              </View>
            </CardContent>
          </Card>

          {/* Sleep Analysis */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Sleep Analysis</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.chartPlaceholder}>
                <Text style={styles.chartPlaceholderText}>Sleep Analysis Chart</Text>
              </View>
              <View style={styles.insightsContainer}>
                <Text style={styles.insightsTitle}>Key Insights</Text>
                <View style={styles.insightsList}>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.blueDot]} />
                    <Text style={styles.insightText}>
                      Your deep sleep has improved by 15% since starting medication
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.blueDot]} />
                    <Text style={styles.insightText}>
                      Sleep onset time has stabilized to within 30 minutes of target
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.amberDot]} />
                    <Text style={styles.insightText}>
                      Slight reduction in sleep duration over the past week - monitor
                    </Text>
                  </View>
                </View>
              </View>
            </CardContent>
          </Card>

          {/* Medication Effectiveness */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Medication Effectiveness</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.chartPlaceholder}>
                <Text style={styles.chartPlaceholderText}>Medication Effectiveness Chart</Text>
              </View>
              <View style={styles.insightsContainer}>
                <Text style={styles.insightsTitle}>Key Insights</Text>
                <View style={styles.insightsList}>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.greenDot]} />
                    <Text style={styles.insightText}>
                      Escitalopram shows positive correlation with reduced anxiety symptoms
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.greenDot]} />
                    <Text style={styles.insightText}>
                      Lamotrigine appears to be stabilizing mood fluctuations
                    </Text>
                  </View>
                  <View style={styles.insightItem}>
                    <View style={[styles.insightDot, styles.amberDot]} />
                    <Text style={styles.insightText}>
                      Minor side effects reported - discuss with provider at next visit
                    </Text>
                  </View>
                </View>
              </View>
              <View style={styles.actionContainer}>
                <Button title="Share with Provider" onPress={() => {}} />
              </View>
            </CardContent>
          </Card>

          {/* Therapy Progress */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Therapy Progress</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.therapyProgress}>
                <View>
                  <Text style={styles.therapyTitle}>CBT Sessions</Text>
                  <Text style={styles.therapySubtitle}>8 sessions completed</Text>
                </View>
                <Progress value={80} style={styles.therapyProgressBar} />
              </View>
              <View style={styles.therapyNotes}>
                <Text style={styles.therapyNotesTitle}>Session Notes</Text>
                <Text style={styles.therapyNotesText}>
                  Working on identifying and challenging negative thought patterns. Progress made on
                  developing coping strategies for anxiety triggers. Next session: Practice
                  mindfulness techniques.
                </Text>
              </View>
              <View style={styles.therapyActions}>
                <Text style={styles.therapyAppointment}>Next appointment: April 28, 2025</Text>
                <Button
                  title="Add Notes"
                  variant="outline"
                  size="sm"
                  style={styles.purpleOutlineButton}
                  onPress={() => {}}
                />
              </View>
            </CardContent>
          </Card>
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
  card: {
    marginBottom: 16,
  },
  cardHeaderContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  purpleBadge: {
    backgroundColor: '#ede9fe',
  },
  chartPlaceholder: {
    height: 180,
    backgroundColor: '#f3f4f6',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  chartPlaceholderText: {
    fontSize: 16,
    color: '#9ca3af',
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statItem: {
    flex: 1,
    borderRadius: 8,
    padding: 8,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  purpleStat: {
    backgroundColor: '#f5f3ff',
  },
  blueStat: {
    backgroundColor: '#eff6ff',
  },
  greenStat: {
    backgroundColor: '#ecfdf5',
  },
  statLabel: {
    fontSize: 12,
    color: '#6b7280',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
  },
  insightsContainer: {
    backgroundColor: '#f9fafb',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
  },
  insightsTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 8,
  },
  insightsList: {
    gap: 8,
  },
  insightItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  insightDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginTop: 6,
    marginRight: 8,
  },
  purpleDot: {
    backgroundColor: '#7c3aed',
  },
  blueDot: {
    backgroundColor: '#3b82f6',
  },
  greenDot: {
    backgroundColor: '#10b981',
  },
  amberDot: {
    backgroundColor: '#f59e0b',
  },
  insightText: {
    flex: 1,
    fontSize: 12,
    color: '#6b7280',
  },
  actionContainer: {
    alignItems: 'flex-end',
  },
  therapyProgress: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  therapyTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#1f2937',
  },
  therapySubtitle: {
    fontSize: 12,
    color: '#6b7280',
  },
  therapyProgressBar: {
    width: 96,
    height: 8,
  },
  therapyNotes: {
    backgroundColor: '#f9fafb',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
  },
  therapyNotesTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 4,
  },
  therapyNotesText: {
    fontSize: 12,
    color: '#6b7280',
    lineHeight: 18,
  },
  therapyActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  therapyAppointment: {
    fontSize: 12,
    color: '#6b7280',
  },
  purpleOutlineButton: {
    borderColor: '#e9d5ff',
  },
});

export default InsightsScreen;

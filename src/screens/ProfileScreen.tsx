import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { ScrollArea } from '../components/ui';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui';
import { Button } from '../components/ui';
import { Avatar, AvatarImage, AvatarFallback } from '../components/ui';
import { Ionicons } from '@expo/vector-icons';

const ProfileScreen = () => {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollArea style={styles.scrollArea}>
        <View style={styles.content}>
          <View style={styles.profileHeader}>
            <Avatar size="lg" style={styles.profileAvatar}>
              <AvatarImage source={{ uri: 'https://via.placeholder.com/80' }} />
              <AvatarFallback>EM</AvatarFallback>
            </Avatar>
            <Text style={styles.profileName}>Emily Morgan</Text>
            <Text style={styles.profileSubtitle}>Member since January 2025</Text>
          </View>

          {/* Personal Information */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Personal Information</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.infoList}>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Name</Text>
                  <Text style={styles.infoValue}>Emily Morgan</Text>
                </View>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Date of Birth</Text>
                  <Text style={styles.infoValue}>May 12, 1988</Text>
                </View>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Email</Text>
                  <Text style={styles.infoValue}>emily.morgan@example.com</Text>
                </View>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Phone</Text>
                  <Text style={styles.infoValue}>+1 (555) 123-4567</Text>
                </View>
              </View>
              <View style={styles.actionContainer}>
                <Button
                  title="Edit Profile"
                  variant="outline"
                  size="sm"
                  onPress={() => {}}
                />
              </View>
            </CardContent>
          </Card>

          {/* Health Care Team */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Health Care Team</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.teamList}>
                <View style={styles.teamMember}>
                  <View style={styles.teamMemberInfo}>
                    <Avatar style={styles.teamMemberAvatar}>
                      <AvatarImage source={{ uri: 'https://via.placeholder.com/40' }} />
                      <AvatarFallback>SC</AvatarFallback>
                    </Avatar>
                    <View>
                      <Text style={styles.teamMemberName}>Dr. Sarah Chen</Text>
                      <Text style={styles.teamMemberRole}>Psychiatrist</Text>
                    </View>
                  </View>
                  <Button
                    title=""
                    variant="ghost"
                    size="sm"
                    icon={<Ionicons name="call" size={20} color="#6b7280" />}
                    onPress={() => {}}
                  />
                </View>

                <View style={styles.teamMember}>
                  <View style={styles.teamMemberInfo}>
                    <Avatar style={styles.teamMemberAvatar}>
                      <AvatarImage source={{ uri: 'https://via.placeholder.com/40' }} />
                      <AvatarFallback>MT</AvatarFallback>
                    </Avatar>
                    <View>
                      <Text style={styles.teamMemberName}>Dr. Michael Torres</Text>
                      <Text style={styles.teamMemberRole}>Therapist (CBT)</Text>
                    </View>
                  </View>
                  <Button
                    title=""
                    variant="ghost"
                    size="sm"
                    icon={<Ionicons name="call" size={20} color="#6b7280" />}
                    onPress={() => {}}
                  />
                </View>
              </View>
              <View style={styles.actionContainer}>
                <Button
                  title="Add Provider"
                  variant="outline"
                  size="sm"
                  icon={<Ionicons name="add" size={16} color="#7c3aed" style={styles.buttonIcon} />}
                  style={styles.purpleOutlineButton}
                  onPress={() => {}}
                />
              </View>
            </CardContent>
          </Card>

          {/* Emergency Contacts */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>Emergency Contacts</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.teamList}>
                <View style={styles.teamMember}>
                  <View style={styles.teamMemberInfo}>
                    <Avatar style={styles.teamMemberAvatar}>
                      <AvatarImage source={{ uri: 'https://via.placeholder.com/40' }} />
                      <AvatarFallback>JM</AvatarFallback>
                    </Avatar>
                    <View>
                      <Text style={styles.teamMemberName}>Jennifer Morgan</Text>
                      <Text style={styles.teamMemberRole}>Sister</Text>
                    </View>
                  </View>
                  <Button
                    title=""
                    variant="ghost"
                    size="sm"
                    icon={<Ionicons name="call" size={20} color="#6b7280" />}
                    onPress={() => {}}
                  />
                </View>
              </View>
              <View style={styles.actionContainer}>
                <Button
                  title="Add Contact"
                  variant="outline"
                  size="sm"
                  icon={<Ionicons name="add" size={16} color="#7c3aed" style={styles.buttonIcon} />}
                  style={styles.purpleOutlineButton}
                  onPress={() => {}}
                />
              </View>
            </CardContent>
          </Card>

          {/* App Settings */}
          <Card style={styles.card}>
            <CardHeader>
              <CardTitle>App Settings</CardTitle>
            </CardHeader>
            <CardContent>
              <View style={styles.settingsList}>
                <View style={styles.settingsItem}>
                  <View style={styles.settingsItemInfo}>
                    <Ionicons name="notifications-outline" size={20} color="#6b7280" style={styles.settingsIcon} />
                    <Text style={styles.settingsLabel}>Notifications</Text>
                  </View>
                  <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
                </View>
                <View style={styles.settingsItem}>
                  <View style={styles.settingsItemInfo}>
                    <Ionicons name="lock-closed-outline" size={20} color="#6b7280" style={styles.settingsIcon} />
                    <Text style={styles.settingsLabel}>Privacy & Security</Text>
                  </View>
                  <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
                </View>
                <View style={styles.settingsItem}>
                  <View style={styles.settingsItemInfo}>
                    <Ionicons name="sync-outline" size={20} color="#6b7280" style={styles.settingsIcon} />
                    <Text style={styles.settingsLabel}>Data Sync</Text>
                  </View>
                  <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
                </View>
                <View style={styles.settingsItem}>
                  <View style={styles.settingsItemInfo}>
                    <Ionicons name="help-circle-outline" size={20} color="#6b7280" style={styles.settingsIcon} />
                    <Text style={styles.settingsLabel}>Help & Support</Text>
                  </View>
                  <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
                </View>
              </View>
            </CardContent>
          </Card>

          <Button
            title="Sign Out"
            variant="outline"
            style={styles.signOutButton}
            onPress={() => {}}
          />
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
  scrollArea: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  profileHeader: {
    alignItems: 'center',
    marginBottom: 24,
  },
  profileAvatar: {
    marginBottom: 12,
  },
  profileName: {
    fontSize: 20,
    fontWeight: '500',
    color: '#1f2937',
    marginBottom: 4,
  },
  profileSubtitle: {
    fontSize: 14,
    color: '#6b7280',
  },
  card: {
    marginBottom: 16,
  },
  infoList: {
    marginBottom: 16,
  },
  infoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  infoLabel: {
    fontSize: 14,
    color: '#6b7280',
  },
  infoValue: {
    fontSize: 14,
    color: '#1f2937',
  },
  actionContainer: {
    alignItems: 'flex-end',
  },
  teamList: {
    marginBottom: 16,
  },
  teamMember: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  teamMemberInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  teamMemberAvatar: {
    marginRight: 12,
  },
  teamMemberName: {
    fontSize: 14,
    fontWeight: '500',
    color: '#1f2937',
  },
  teamMemberRole: {
    fontSize: 12,
    color: '#6b7280',
  },
  buttonIcon: {
    marginRight: 4,
  },
  purpleOutlineButton: {
    borderColor: '#e9d5ff',
  },
  settingsList: {
    marginBottom: 8,
  },
  settingsItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  settingsItemInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingsIcon: {
    marginRight: 12,
  },
  settingsLabel: {
    fontSize: 14,
    color: '#1f2937',
  },
  signOutButton: {
    marginTop: 8,
    marginBottom: 24,
  },
});

export default ProfileScreen;

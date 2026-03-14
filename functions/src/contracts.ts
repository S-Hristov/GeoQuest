export type ChallengeProgressStatus = 'active' | 'completed' | 'abandoned';

export interface UserProfileRecord {
  uid: string;
  name: string;
  email: string;
  initials: string;
  level: number;
  points: number;
  nextLevelPoints: number;
  completed: number;
  badges: number;
  bestStreak: number;
  currentStreak: number;
  avatarPath?: string | null;
  lastCompletedDate?: string | null;
  lastActiveAt?: string | null;
  lastLocation?: UserLocationRecord | null;
  notificationPrefs?: NotificationPrefsRecord;
  push?: UserPushRecord;
  updatedAt: string;
}

export interface UserLocationRecord {
  latitude: number;
  longitude: number;
  recordedAt: string;
}

export interface NotificationPrefsRecord {
  dailyChallenge: boolean;
  nearbyNudges: boolean;
  streakRisk: boolean;
  streakMilestones: boolean;
  achievementUnlocks: boolean;
  completionSummary: boolean;
  newChallenges: boolean;
  weeklyRecap: boolean;
  leaderboardPass: boolean;
  reEngagement: boolean;
  ops: boolean;
}

export interface UserPushRecord {
  token?: string | null;
  platform?: string | null;
  locale?: string | null;
  tokenUpdatedAt?: string | null;
  lastDailyAt?: string | null;
  lastNearbyAt?: string | null;
  lastStreakRiskAt?: string | null;
  lastWeeklyAt?: string | null;
  lastReengagementAt?: string | null;
  lastLeaderboardRank?: number | null;
}

export interface ChallengeRecord {
  id: string;
  title: string;
  location: string;
  description: string;
  imageAsset: string;
  distanceKm: number;
  points: number;
  duration: string;
  difficulty: 'easy' | 'medium' | 'hard';
  category: string;
  latitude: number;
  longitude: number;
  explorersCompleted: number;
}

export interface ChallengeProgressRecord {
  uid: string;
  challengeId: string;
  status: ChallengeProgressStatus;
  startedAt: string;
  completedAt?: string | null;
  proofPath?: string | null;
  lastRouteShownAt?: string | null;
}

export interface UserAchievementRecord {
  uid: string;
  achievementId: string;
  unlockedAt: string;
}

export interface LeaderboardRecord {
  uid: string;
  name: string;
  initials: string;
  level: number;
  completed: number;
  points: number;
  rank: number;
  updatedAt: string;
}

export interface AchievementCatalogRecord {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
  rewardPoints: number;
  total: number;
  sortOrder: number;
}

export interface AchievementViewRecord {
  title: string;
  subtitle: string;
  icon: string;
  rewardPoints: number;
  progress: number;
  total: number;
  unlocked: string;
}

export interface ActiveChallengeStateRecord {
  challengeId: string;
  startedAt: string;
  status: ChallengeProgressStatus;
  lastRouteShownAt?: string | null;
}

export interface AppStateRecord {
  user: UserProfileRecord;
  challenges: ChallengeRecord[];
  leaderboard: LeaderboardRecord[];
  activeChallengeState: ActiveChallengeStateRecord | null;
  completedChallengeIds: string[];
  achievementsInProgress: AchievementViewRecord[];
  unlockedAchievements: AchievementViewRecord[];
  dailyChallengeId: string | null;
  nearbyChallengeIds: string[];
  categories: string[];
  filterOptions: {
    categories: string[];
    difficulties: Array<'easy' | 'medium' | 'hard'>;
    maxDistancesKm: number[];
  };
}

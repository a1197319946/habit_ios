import { defineStore } from 'pinia';
import { useUserStore } from './user';
import { syncToiCloud, readFromiCloud } from '@/utils/icloud';

export const useHabitStore = defineStore('habit', {
  state: () => ({
    habits: uni.getStorageSync('habits') || [],
    moods: uni.getStorageSync('moods') || [],
    checkins: uni.getStorageSync('checkins') || [],
    lastSyncTimestamp: uni.getStorageSync('lastSyncTimestamp') || 0
  }),
  getters: {
    getHabits: (state) => state.habits,
    getMoods: (state) => state.moods,
    getCheckins: (state) => state.checkins,
    
    getTodayCheckins: (state) => {
      const today = new Date().toISOString().split('T')[0];
      return state.checkins.filter(c => c.date === today);
    },
    
    getCheckinsByDate: (state) => (dateStr) => {
      return state.checkins.filter(c => c.date === dateStr);
    }
  },
  actions: {
    saveToStorage() {
      uni.setStorageSync('habits', this.habits);
      uni.setStorageSync('moods', this.moods);
      uni.setStorageSync('checkins', this.checkins);
      
      const userStore = useUserStore();
      
      // Update our own last modification time
      this.lastSyncTimestamp = Date.now();
      uni.setStorageSync('lastSyncTimestamp', this.lastSyncTimestamp);
      
      // trigger background sync
      setTimeout(() => {
        syncToiCloud({
          habits: this.habits,
          moods: this.moods,
          checkins: this.checkins,
          userInfo: userStore.userInfo
        });
      }, 500);
    },

    async mergeFromiCloud() {
      // Called on app start or foreground
      const icloudData = readFromiCloud();
      if (icloudData && icloudData.timestamp && icloudData.data) {
        if (icloudData.timestamp > this.lastSyncTimestamp) {
          // iCloud data is newer, merge it
          this.habits = icloudData.data.habits || [];
          this.moods = icloudData.data.moods || [];
          this.checkins = icloudData.data.checkins || [];
          
          const userStore = useUserStore();
          if (icloudData.data.userInfo) {
            userStore.setUserInfo(icloudData.data.userInfo);
            userStore.saveToStorageLocally();
          }
          
          this.lastSyncTimestamp = icloudData.timestamp;
          uni.setStorageSync('lastSyncTimestamp', this.lastSyncTimestamp);
          
          // Save merged data back to local storage silently
          uni.setStorageSync('habits', this.habits);
          uni.setStorageSync('moods', this.moods);
          uni.setStorageSync('checkins', this.checkins);
        }
      }
    },
    
    setHabits(newHabits) {
      this.habits = newHabits;
      this.saveToStorage();
    },
    
    async addHabit(habit) {
      const newHabit = {
        ...habit,
        id: Date.now().toString(),
        createdAt: new Date().toISOString()
      };
      this.habits = [...this.habits, newHabit];
      this.saveToStorage();
    },
    
    async updateHabit(updatedHabit) {
      const index = this.habits.findIndex(h => h.id === updatedHabit.id);
      if (index !== -1) {
        this.habits[index] = { ...this.habits[index], ...updatedHabit };
        this.saveToStorage();
      }
    },
    
    async deleteHabit(id) {
      this.habits = this.habits.filter(h => h.id !== id);
      this.checkins = this.checkins.filter(c => c.habitId !== id);
      this.moods = this.moods.filter(m => m.habitId !== id);
      this.saveToStorage();
    },
    
    async checkin(habitId, targetDate = null, amount = undefined) {
      const today = new Date().toISOString().split('T')[0];
      const dateStr = targetDate || today;
      const existingIdx = this.checkins.findIndex(c => c.habitId === habitId && c.date === dateStr);
      
      if (existingIdx === -1) {
        const checkinData = {
          id: Date.now().toString(),
          habitId,
          date: dateStr,
          timestamp: Date.now()
        };
        if (amount !== undefined) {
          checkinData.amount = amount;
        }
        this.checkins = [...this.checkins, checkinData];
      } else if (amount !== undefined) {
        this.checkins[existingIdx].amount = amount;
        this.checkins[existingIdx].timestamp = Date.now();
      }
      this.saveToStorage();
    },
    
    async undoCheckin(habitId, targetDate = null) {
      const today = new Date().toISOString().split('T')[0];
      const dateStr = targetDate || today;
      this.checkins = this.checkins.filter(c => !(c.habitId === habitId && c.date === dateStr));
      this.saveToStorage();
    },
    
    async addMood(moodRecord) {
      this.moods = [{
        ...moodRecord,
        id: Date.now().toString(),
        timestamp: Date.now()
      }, ...this.moods];
      this.saveToStorage();
    }
  }
});

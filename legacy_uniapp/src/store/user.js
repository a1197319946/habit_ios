import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: {
      avatarUrl: '',
      nickName: ''
    },
    openid: ''
  }),
  getters: {
    isLoggedIn: () => true, // Always true for local iOS app
  },
  actions: {
    setUserInfo(info) {
      this.userInfo = { ...this.userInfo, ...info };
    },
    async initFromStorage() {
      const stored = uni.getStorageSync('userInfo');
      if (stored) {
        try {
          const info = JSON.parse(stored);
          this.userInfo = info.userInfo || { avatarUrl: '', nickName: '' };
          this.openid = info.openid || '';
        } catch (e) {
          console.error('Parse userInfo error', e);
        }
      }
    },
    async silentLogin() {
      if (!this.openid) {
        this.openid = 'ios-' + Date.now();
        this.saveToStorageLocally();
      }
      return this.openid;
    },
    saveToStorageLocally() {
      uni.setStorageSync('userInfo', JSON.stringify({
        userInfo: this.userInfo,
        openid: this.openid
      }));
    },
    saveToStorage() {
      this.saveToStorageLocally();
      // Delegate iCloud sync to habit store
      import('@/store/habit').then(m => {
        m.useHabitStore().saveToStorage();
      });
    }
  }
});

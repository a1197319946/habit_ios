<template>
  <view class="mood-list-container">
    <view class="header-section">
      <text class="title">心情记录</text>
    </view>

    <!-- Filter -->
    <view class="filter-scroll-container">
      <scroll-view scroll-x class="filter-scroll">
        <view class="flex-row">
          <view 
            class="filter-tab"
            :class="{ 'is-active': filterHabitId === null }"
            @click="filterHabitId = null"
          >
            全部记录
          </view>
          <view 
            v-for="habit in habits" 
            :key="habit.id"
            class="filter-tab"
            :class="{ 'is-active': filterHabitId === habit.id }"
            @click="filterHabitId = habit.id"
          >
            {{ habit.name }}
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- Records List -->
    <view class="records-list">
      <view v-if="filteredMoods.length === 0" class="empty-state flex-col items-center justify-center">
        <view class="empty-icon glass-panel flex-row items-center justify-center" style="width: 80px; height: 80px; border-radius: var(--radius-xl); margin-bottom: 24px;">
          <uni-icons type="calendar" size="40" color="var(--primary)"></uni-icons>
        </view>
        <text class="empty-text">还没有心情记录</text>
      </view>

      <view 
        v-for="mood in filteredMoods" 
        :key="mood.id"
        class="mood-card glass-panel flex-col"
      >
        <view class="card-header flex-row justify-between items-center">
          <view class="flex-row items-center">
            <image :src="getMoodIcon(mood.mood)" class="mood-icon-img" />
            <text class="habit-name">{{ getHabitName(mood.habitId) }}</text>
          </view>
          <text class="date-text">{{ formatDate(mood.timestamp) }}</text>
        </view>
        <view class="card-body" v-if="mood.text || mood.imageUrl">
          <text class="mood-text" v-if="mood.text">{{ mood.text }}</text>
          <image 
            v-if="mood.imageUrl" 
            :src="mood.imageUrl" 
            mode="aspectFill" 
            class="mood-attached-img" 
            @click="previewImage(mood.imageUrl)" 
          />
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { ref, computed } from 'vue';
import { useHabitStore } from '@/store/habit';

const habitStore = useHabitStore();

const filterHabitId = ref(null);

const habits = computed(() => habitStore.getHabits);
const moods = computed(() => habitStore.getMoods);

const filteredMoods = computed(() => {
  let list = moods.value;
  if (filterHabitId.value) {
    list = list.filter(m => m.habitId === filterHabitId.value);
  }
  return list.sort((a, b) => b.timestamp - a.timestamp);
});

const getHabitName = (id) => {
  const h = habits.value.find(h => h.id === id);
  return h ? h.name : '未知习惯';
};

const getMoodIcon = (type) => {
  const map = {
    'excited': '158_激动',
    'happy': '158_开心',
    'normal': '158_一般',
    'down': '158_失落',
    'angry': '158_愤怒'
  };
  const iconName = map[type] || '158_一般';
  return `/static/icons/mood/${iconName}.png`;
};

const previewImage = (url) => {
  uni.previewImage({ urls: [url] });
};

const formatDate = (timestamp) => {
  const d = new Date(timestamp);
  return `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2,'0')}-${d.getDate().toString().padStart(2,'0')} ${d.getHours().toString().padStart(2,'0')}:${d.getMinutes().toString().padStart(2,'0')}`;
};

// 开启微信分享给朋友
onShareAppMessage(() => {
  return {
    title: '小习惯 - 坚持每天微小的改变',
    path: '/pages/index/index'
  };
});

// 开启分享到朋友圈
onShareTimeline(() => {
  return {
    title: '小习惯 - 坚持每天微小的改变'
  };
});

</script>

<style lang="scss" scoped>
.mood-list-container {
  min-height: 100vh;
  padding: 24px 20px;
}

.header-section {
  margin-bottom: 24px;
  .title {
    font-size: 28px;
    font-weight: 700;
    color: var(--text-main);
  }
}

.filter-scroll-container {
  margin-bottom: 24px;
}

.filter-scroll {
  width: 100%;
  white-space: nowrap;
}

.filter-tab {
  display: inline-block;
  padding: 8px 16px;
  margin-right: 12px;
  background: var(--surface);
  color: var(--text-muted);
  border-radius: var(--radius-xl);
  font-size: 14px;
  font-weight: 500;
  border: 1px solid var(--border-color);
  transition: all 0.2s;
  
  &.is-active {
    background: var(--primary);
    color: white;
    border-color: var(--primary);
  }
}

.glass-panel {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
}

.records-list {
  gap: 16px;
  display: flex;
  flex-direction: column;
}

.mood-card {
  padding: 16px;
  
  .card-header {
    margin-bottom: 12px;
    
    .mood-icon-img {
      width: 28px;
      height: 28px;
      margin-right: 12px;
    }
    
    .habit-name {
      font-size: 16px;
      font-weight: 600;
      color: var(--text-main);
    }
    
    .date-text {
      font-size: 12px;
      color: var(--text-light);
    }
  }
  
  .card-body {
    background: var(--background);
    padding: 12px;
    border-radius: var(--radius-sm);
    
    .mood-text {
      font-size: 14px;
      color: var(--text-regular);
      line-height: 1.6;
      display: block;
    }
    
    .mood-attached-img {
      margin-top: 12px;
      width: 100px;
      height: 100px;
      border-radius: var(--radius-sm);
    }
  }
}

.empty-state {
  margin-top: 64px;
  .empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
  }
  .empty-text {
    font-size: 15px;
    color: var(--text-muted);
  }
}
</style>

<template>
  <view class="habit-container">
    <view class="header-section">
      <text class="subtitle">共 {{ habits.length }} 个习惯</text>
    </view>
    <view v-if="localHabits.length === 0" class="empty-state flex-col items-center justify-center">
      <view class="empty-icon glass-panel flex-row items-center justify-center">
        <uni-icons type="flag" size="32" color="var(--primary)"></uni-icons>
      </view>
      <text class="empty-text">这里空空如也</text>
    </view>

    <view v-else class="habits-list">
      <view 
        v-for="(habit, index) in localHabits" 
        :key="habit.id"
        class="habit-card flex-row items-center justify-between glass-panel"
        :class="{ 'is-dragging': draggingIndex === index }"
        :style="{ 
          transform: getTransform(index), 
          zIndex: draggingIndex === index ? 100 : (draggingIndex !== -1 ? 90 : 1),
          boxShadow: draggingIndex === index ? '0 15px 30px rgba(0,0,0,0.15)' : ''
        }"
        @click="goToDetail(habit.id)"
      >
        <view class="habit-info flex-row items-center">
          <view class="drag-handle"
            @touchstart.stop="onDragStart(index, $event)"
            @touchmove.stop.prevent="onDragMove($event)"
            @touchend="onDragEnd"
            @touchcancel="onDragEnd"
          >
            <uni-icons type="list" size="20" color="#D1D5DB"></uni-icons>
          </view>
          <view class="habit-icon" :style="{ backgroundColor: habit.color || 'var(--primary)' }">
            <image v-if="habit.icon" :src="'/static/icons/habbit/' + habit.icon + '.png'" class="custom-icon" />
            <text v-else class="icon-text">{{ habit.name.charAt(0) }}</text>
          </view>
          <view class="habit-meta flex-col">
            <text class="habit-name">{{ habit.name }}</text>
          </view>
        </view>
        
        <view class="action-arrow"><uni-icons type="right" size="16" color="var(--text-light)"></uni-icons></view>
      </view>
    </view>

    <!-- Fixed Bottom Add Button -->
    <view class="bottom-action-area flex-row justify-center">
      <view class="add-btn primary-btn flex-row items-center justify-center" @click="goToAddHabit">
        <uni-icons type="plusempty" size="20" color="#ffffff" style="margin-right: 8px;"></uni-icons>
        <text>添加习惯</text>
      </view>
    </view>


  </view>
</template>

<script setup>
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { ref, computed, watch } from 'vue';
import { useHabitStore } from '@/store/habit';

const habitStore = useHabitStore();

const habits = computed(() => habitStore.getHabits);
const localHabits = ref([]);

watch(() => habitStore.getHabits, (newVal) => {
  localHabits.value = [...newVal];
}, { immediate: true, deep: true });

// Drag and drop logic
const draggingIndex = ref(-1);
const currentIndex = ref(-1);
const dragOffsetY = ref(0);
let startY = 0;
const itemHeight = 84; // approx height of item + gap

const onDragStart = (index, e) => {
  draggingIndex.value = index;
  currentIndex.value = index;
  startY = e.touches[0].pageY;
  dragOffsetY.value = 0;
  uni.vibrateShort();
};

const onDragMove = (e) => {
  if (draggingIndex.value === -1) return;
  const currentY = e.touches[0].pageY;
  dragOffsetY.value = currentY - startY;
  
  let offsetIndex = Math.round(dragOffsetY.value / itemHeight);
  let targetIndex = draggingIndex.value + offsetIndex;
  
  if (targetIndex < 0) targetIndex = 0;
  if (targetIndex >= localHabits.value.length) targetIndex = localHabits.value.length - 1;
  
  currentIndex.value = targetIndex;
};

const onDragEnd = () => {
  if (draggingIndex.value !== -1) {
    const oldIndex = draggingIndex.value;
    const newIndex = currentIndex.value;
    
    // Reset synchronously BEFORE mutating data to prevent CSS class sticking on recycled DOM nodes
    draggingIndex.value = -1;
    currentIndex.value = -1;
    dragOffsetY.value = 0;
    
    if (oldIndex !== newIndex) {
      const item = localHabits.value[oldIndex];
      localHabits.value.splice(oldIndex, 1);
      localHabits.value.splice(newIndex, 0, item);
      habitStore.setHabits(localHabits.value);
    }
  }
};

const getTransform = (index) => {
  if (draggingIndex.value === -1) return 'translateY(0)';
  
  if (index === draggingIndex.value) {
    return `translateY(${dragOffsetY.value}px) scale(1.05)`;
  }
  
  if (draggingIndex.value < currentIndex.value) {
    if (index > draggingIndex.value && index <= currentIndex.value) {
      return `translateY(-${itemHeight}px)`;
    }
  } else if (draggingIndex.value > currentIndex.value) {
    if (index < draggingIndex.value && index >= currentIndex.value) {
      return `translateY(${itemHeight}px)`;
    }
  }
  
  return 'translateY(0)';
};


const goToAddHabit = () => {
  uni.navigateTo({ url: '/pages/habit-create/habit-create' });
};

const goToDetail = (id) => {
  uni.navigateTo({
    url: `/pages/habit-detail/habit-detail?id=${id}`
  });
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
.habit-container {
  min-height: 100vh;
  padding: 24px 20px;
  padding-bottom: 120px;
}

.header-section {
  margin-bottom: 16px;
  .subtitle {
    font-size: 14px;
    color: var(--text-muted);
  }
}

.habits-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.glass-panel {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: var(--shadow-sm);
}

.habit-card {
  position: relative;
  padding: 12px;
  border-radius: var(--radius-md);
  transition: transform 0.3s cubic-bezier(0.25, 1, 0.5, 1);
  
  &:active:not(.is-dragging) {
    transform: scale(0.98);
  }
  
  &.is-dragging {
    transition: none !important;
    opacity: 0.95;
  }
}

.drag-handle {
  margin-right: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
}

.habit-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  box-shadow: inset 0 2px 4px rgba(255,255,255,0.3);
  
  .icon-text {
    color: white;
    font-size: 20px;
    font-weight: bold;
  }
}

.custom-icon {
  width: 24px;
  height: 24px;
}

.habit-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 4px;
}


.action-arrow {
  color: var(--text-light);
  font-weight: bold;
  font-size: 16px;
}

.bottom-action-area {
  position: fixed;
  bottom: 24px;
  left: 0;
  right: 0;
  padding: 0 20px;
  z-index: 100;
}

.primary-btn {
  width: 100%;
  height: 52px;
  background: var(--primary);
  color: white;
  border-radius: var(--radius-xl);
  font-size: 16px;
  font-weight: 600;
  box-shadow: 0 8px 20px rgba(79, 70, 229, 0.4);
  
  .plus-icon {
    font-size: 20px;
    margin-right: 8px;
    font-weight: 400;
  }
}

.empty-state {
  margin-top: 64px;
  .empty-icon {
    width: 80px;
    height: 80px;
    border-radius: 24px;
    font-size: 32px;
    margin-bottom: 24px;
    background: #fff;
  }
  .empty-text {
    color: var(--text-muted);
    font-size: 15px;
    margin-bottom: 24px;
  }
}
</style>

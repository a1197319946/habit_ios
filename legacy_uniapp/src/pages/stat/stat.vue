<template>
  <view class="stat-container">
    
    <!-- Top Filter Section -->
    <view class="filter-section flex-row justify-between items-center">
      <!-- Habit Selector Trigger -->
      <view class="habit-selector-trigger flex-row items-center" @click="isHabitModalOpen = true">
        <text class="trigger-text">{{ selectedHabitIds.length ? `选择习惯 (${selectedHabitIds.length})` : '全部习惯' }}</text>
        <view class="icon-arrow-down"></view>
      </view>

      <!-- Time Range Segmented Control -->
      <view class="time-segments flex-row">
        <view class="segment" :class="{ 'is-active': filterMode === 'all' }" @click="setFilterMode('all')">全部</view>
        <view class="segment" :class="{ 'is-active': filterMode === 'year' }" @click="setFilterMode('year')">年</view>
        <view class="segment" :class="{ 'is-active': filterMode === 'month' }" @click="setFilterMode('month')">月</view>
      </view>
    </view>

    <!-- Selected Habit Tags -->
    <view class="habit-tags flex-row" v-if="selectedHabitIds.length > 0">
      <scroll-view scroll-x class="tags-scroll">
        <view class="flex-row" style="padding-bottom: 4px;">
          <view class="tag flex-row items-center" v-for="id in selectedHabitIds" :key="id">
            <view class="tag-color-dot" :style="{ backgroundColor: getHabitColor(id) }"></view>
            <text class="tag-text">{{ getHabitName(id) }}</text>
            <view class="tag-close flex-col items-center justify-center" @click="removeHabitSelection(id)">×</view>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- Overview Card -->
    <view class="overview-card glass-panel">
      <view class="overview-header">
        <text class="overview-title">{{ getTitle }}</text>
      </view>
      <view class="overview-content flex-row justify-between">
        <view class="total-days-box flex-col">
          <view class="flex-row" style="align-items: flex-end;">
            <text class="total-num">{{ uniqueCheckinDays }}</text>
            <text class="total-unit">天</text>
          </view>
          <text class="total-label">打卡天数</text>
        </view>
        <view class="breakdown-list">
          <view v-for="item in breakdownData" :key="item.id" class="breakdown-item flex-row items-center justify-between">
            <view class="flex-row items-center">
              <view class="color-dot" :style="{ backgroundColor: item.color }"></view>
              <text class="habit-name">{{ item.name }}</text>
            </view>
            <view class="flex-col items-end">
              <text class="habit-days">{{ item.amountText }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- Main Chart Area -->
    <view class="chart-area glass-panel flex-col">
      
      <!-- Month View (Calendar) -->
      <view v-if="filterMode === 'month'" class="view-month flex-col">
        <view class="chart-header flex-row justify-between items-center">
          <view class="nav-btn" @click="prevMonth">‹</view>
          <text class="chart-title">{{ currentYear }}年{{ currentMonth }}月</text>
          <view class="nav-btn" @click="nextMonth">›</view>
        </view>

        <view class="calendar" style="margin-top: 12px;">
          <view class="weekdays flex-row justify-between">
            <text v-for="d in ['日','一','二','三','四','五','六']" :key="d" class="weekday">{{ d }}</text>
          </view>
          <view class="days-grid">
            <view class="day-cell" v-for="empty in monthOffset" :key="'empty'+empty"></view>
            <view class="day-cell flex-col items-center" v-for="day in monthDays" :key="day" :class="{ 'is-today': isToday(day) }">
              <text class="day-num">{{ day }}</text>
              <view class="dots-row flex-row justify-center">
                <view 
                  v-for="h in getHabitsOnDay(day)" 
                  :key="h.id" 
                  class="tiny-dot" 
                  :style="{ backgroundColor: h.color }">
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- Year View (Bar Chart) -->
      <view v-if="filterMode === 'year'" class="view-year flex-col">
        <view class="chart-header flex-row justify-between items-center">
          <view class="nav-btn" @click="prevYear">‹</view>
          <text class="chart-title">{{ currentYear }}年</text>
          <view class="nav-btn" @click="nextYear">›</view>
        </view>

        <view class="chart-container flex-row" style="margin-top: 12px;">
          <view class="y-axis flex-col justify-between items-end">
            <text>{{ Math.ceil(yearlyChartData.maxVal) }}</text>
            <text>{{ Math.ceil(yearlyChartData.maxVal / 2) }}</text>
            <text>0</text>
          </view>
          <view class="chart-bars flex-row justify-around">
            <view class="bar-col flex-col items-center" v-for="item in yearlyChartData.data" :key="item.month" @click="jumpToMonth(item.month)">
              <view class="bar-stack-area flex-col justify-end">
                <view v-for="seg in item.segments" :key="seg.id" 
                      class="bar-segment" 
                      :style="{ height: `${(seg.val / (yearlyChartData.maxVal || 1)) * 100}%`, backgroundColor: seg.color }">
                </view>
              </view>
              <text class="x-label">{{ item.month }}月</text>
            </view>
          </view>
        </view>

        <!-- Quick Jump Months -->
        <view class="quick-jump flex-col mt-4">
          <text class="quick-jump-title">快速查看月份</text>
          <view class="quick-jump-grid">
            <view class="quick-btn" v-for="m in 12" :key="m" @click="jumpToMonth(m)">
              {{ m }}月
            </view>
          </view>
        </view>
      </view>

      <!-- All View (Bar Chart) -->
      <view v-if="filterMode === 'all'" class="view-all flex-col">
        
        <view class="chart-container flex-row" style="margin-top: 16px;">
          <view class="y-axis flex-col justify-between items-end">
            <text>{{ Math.ceil(allChartData.maxVal) }}</text>
            <text>{{ Math.ceil(allChartData.maxVal / 2) }}</text>
            <text>0</text>
          </view>
          <view class="chart-bars flex-row justify-around">
            <view class="bar-col flex-col items-center" v-for="item in allChartData.data" :key="item.year" @click="jumpToYear(item.year)">
              <view class="bar-stack-area flex-col justify-end">
                <view v-for="seg in item.segments" :key="seg.id" 
                      class="bar-segment" 
                      :style="{ height: `${(seg.val / (allChartData.maxVal || 1)) * 100}%`, backgroundColor: seg.color }">
                </view>
              </view>
              <text class="x-label">{{ item.year }}</text>
            </view>
          </view>
        </view>

        <!-- Quick Jump Years -->
        <view class="quick-jump flex-col mt-4">
          <text class="quick-jump-title">快速查看年份</text>
          <view class="quick-jump-grid">
            <view class="quick-btn" v-for="y in availableYears" :key="y" @click="jumpToYear(y)">
              {{ y }}年
            </view>
          </view>
        </view>
      </view>

    </view>

    <!-- Habit Selection Modal -->
    <view class="modal-overlay" v-if="isHabitModalOpen" @click="isHabitModalOpen = false">
      <view class="modal-content flex-col" @click.stop>
        <view class="modal-header flex-row justify-between items-center">
          <text class="modal-title">选择习惯</text>
          <view class="modal-close" @click="isHabitModalOpen = false">×</view>
        </view>
        <scroll-view scroll-y class="modal-list">
          <view 
            class="modal-item flex-row justify-between items-center" 
            :class="{ 'is-selected': selectedHabitIds.length === 0 }"
            @click="clearHabitSelection"
          >
            <text class="modal-item-name">全部习惯</text>
            <view class="checkbox" :class="{ 'checked': selectedHabitIds.length === 0 }"></view>
          </view>
          <view 
            v-for="habit in habits" 
            :key="habit.id"
            class="modal-item flex-row justify-between items-center"
            @click="toggleHabitSelection(habit.id)"
          >
            <view class="flex-row items-center">
              <view class="color-dot" :style="{ backgroundColor: habit.color || '#3B82F6' }"></view>
              <text class="modal-item-name">{{ habit.name }}</text>
            </view>
            <view class="checkbox" :class="{ 'checked': selectedHabitIds.includes(habit.id) }"></view>
          </view>
        </scroll-view>
        <view class="modal-footer">
          <view class="btn-primary flex-row items-center justify-center" @click="isHabitModalOpen = false">确认</view>
        </view>
      </view>
    </view>

  </view>
</template>

<script setup>
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { ref, computed, watch } from 'vue';
import { useHabitStore } from '@/store/habit';

const habitStore = useHabitStore();

// Store Data
const habits = computed(() => habitStore.getHabits);
const checkins = computed(() => habitStore.getCheckins);

// State
const filterMode = ref('month'); // 'month', 'year', 'all'
const selectedHabitIds = ref([]); // empty array means "All habits"
const isHabitModalOpen = ref(false);

watch(isHabitModalOpen, (val) => {
  if (val) {
    uni.hideTabBar();
  } else {
    uni.showTabBar();
  }
});

const dDate = new Date();
const currentYear = ref(dDate.getFullYear());
const currentMonth = ref(dDate.getMonth() + 1);

const setFilterMode = (mode) => {
  filterMode.value = mode;
  const d = new Date();
  if (mode === 'month') {
    currentYear.value = d.getFullYear();
    currentMonth.value = d.getMonth() + 1;
  } else if (mode === 'year') {
    currentYear.value = d.getFullYear();
  }
};

// Helper Methods
const getHabitColor = (id) => {
  const h = habits.value.find(hab => hab.id === id);
  return h?.color || '#3B82F6';
};

const getHabitName = (id) => {
  const h = habits.value.find(hab => hab.id === id);
  return h?.name || '未知习惯';
};

// Habit Selection Methods
const toggleHabitSelection = (id) => {
  const index = selectedHabitIds.value.indexOf(id);
  if (index > -1) {
    selectedHabitIds.value.splice(index, 1);
  } else {
    selectedHabitIds.value.push(id);
  }
};

const clearHabitSelection = () => {
  selectedHabitIds.value = [];
};

const removeHabitSelection = (id) => {
  const index = selectedHabitIds.value.indexOf(id);
  if (index > -1) selectedHabitIds.value.splice(index, 1);
};

// Active Habits for Display
const activeHabits = computed(() => {
  if (selectedHabitIds.value.length === 0) return habits.value;
  return habits.value.filter(h => selectedHabitIds.value.includes(h.id));
});

// Filtered Checkins
const scopedCheckins = computed(() => {
  if (selectedHabitIds.value.length === 0) return checkins.value;
  return checkins.value.filter(c => selectedHabitIds.value.includes(c.habitId));
});

const timeFilteredCheckins = computed(() => {
  return scopedCheckins.value.filter(c => {
    if (!c.date) return false;
    const parts = c.date.split('-');
    if (parts.length !== 3) return false;
    const cYear = Number(parts[0]);
    const cMonth = Number(parts[1]);
    
    if (filterMode.value === 'month') {
      return cYear === currentYear.value && cMonth === currentMonth.value;
    } else if (filterMode.value === 'year') {
      return cYear === currentYear.value;
    }
    return true;
  });
});

// Overview Data
const uniqueCheckinDays = computed(() => {
  const days = new Set();
  timeFilteredCheckins.value.forEach(c => days.add(c.date));
  return days.size;
});

const breakdownData = computed(() => {
  const habitDaysMap = {};
  const habitAmountMap = {};
  
  timeFilteredCheckins.value.forEach(c => {
    if (!habitDaysMap[c.habitId]) {
      habitDaysMap[c.habitId] = new Set();
      habitAmountMap[c.habitId] = 0;
    }
    habitDaysMap[c.habitId].add(c.date);
    habitAmountMap[c.habitId] += Number(c.amount) || 0;
  });
  
  return activeHabits.value.map(h => {
    const isAmount = h.goalType === 'amount';
    const days = habitDaysMap[h.id] ? habitDaysMap[h.id].size : 0;
    const amountVal = habitAmountMap[h.id] || 0;
    
    let amountText = '';
    if (isAmount) {
      amountText = `${Number(amountVal.toFixed(1))}${h.amountUnit || ''}`;
    } else {
      amountText = `${days}次`;
    }
    
    return {
      id: h.id,
      name: h.name,
      color: h.color || '#3B82F6',
      days: days,
      isAmount: isAmount,
      amountVal: amountVal,
      amountText: amountText
    };
  }).filter(h => h.isAmount ? h.amountVal > 0 : h.days > 0);
});

const getTitle = computed(() => {
  if (filterMode.value === 'month') return `打卡概览 ${currentYear.value}-${String(currentMonth.value).padStart(2, '0')}`;
  if (filterMode.value === 'year') return `打卡概览 ${currentYear.value}`;
  return '打卡概览 全部';
});

// Month View (Calendar) Logic
const monthDays = computed(() => new Date(currentYear.value, currentMonth.value, 0).getDate());
const monthOffset = computed(() => new Date(currentYear.value, currentMonth.value - 1, 1).getDay());

const isToday = (day) => {
  const d = new Date();
  return day === d.getDate() && currentMonth.value === (d.getMonth() + 1) && currentYear.value === d.getFullYear();
};

const getHabitsOnDay = (day) => {
  const dateStr = `${currentYear.value}-${String(currentMonth.value).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  const presentHabitIds = new Set(timeFilteredCheckins.value.filter(c => c.date === dateStr).map(c => c.habitId));
  return activeHabits.value.filter(h => presentHabitIds.has(h.id));
};

// Year View (Bar Chart) Logic
const yearlyChartData = computed(() => {
  const data = Array.from({length: 12}, (_, i) => {
    return { month: i + 1, map: {}, total: 0, segments: [] };
  });
  
  timeFilteredCheckins.value.forEach(c => {
    if (!c.date) return;
    const parts = c.date.split('-');
    if (parts.length < 2) return;
    const cMonth = Number(parts[1]);
    const mIndex = cMonth - 1;
    if (!data[mIndex]) return;
    
    if (!data[mIndex].map[c.habitId]) {
      data[mIndex].map[c.habitId] = new Set();
    }
    data[mIndex].map[c.habitId].add(c.date);
  });
  
  let maxVal = 0;
  data.forEach(item => {
    let sum = 0;
    for (const hid in item.map) sum += item.map[hid].size;
    item.total = sum;
    if (sum > maxVal) maxVal = sum;
    
    // Create stacked segments based on order of activeHabits
    item.segments = activeHabits.value.map(h => ({
      id: h.id,
      color: h.color || '#3B82F6',
      val: item.map[h.id] ? item.map[h.id].size : 0
    })).filter(seg => seg.val > 0);
  });
  
  return { data, maxVal: maxVal || 10 }; 
});

// All View (Bar Chart) Logic
const availableYears = computed(() => {
  const years = new Set();
  years.add(new Date().getFullYear()); 
  scopedCheckins.value.forEach(c => {
    if (c.date) {
      const parts = c.date.split('-');
      if (parts.length > 0) {
        years.add(Number(parts[0]));
      }
    }
  });
  return Array.from(years).sort();
});

const allChartData = computed(() => {
  const years = availableYears.value;
  const data = years.map(y => {
    return { year: y, map: {}, total: 0, segments: [] };
  });
  
  timeFilteredCheckins.value.forEach(c => {
    if (!c.date) return;
    const parts = c.date.split('-');
    if (parts.length === 0) return;
    const cYear = Number(parts[0]);
    const yIndex = years.indexOf(cYear);
    if (yIndex !== -1) {
      if (!data[yIndex].map[c.habitId]) {
        data[yIndex].map[c.habitId] = new Set();
      }
      data[yIndex].map[c.habitId].add(c.date);
    }
  });
  
  let maxVal = 0;
  data.forEach(item => {
    let sum = 0;
    for (const hid in item.map) sum += item.map[hid].size;
    item.total = sum;
    if (sum > maxVal) maxVal = sum;
    
    item.segments = activeHabits.value.map(h => ({
      id: h.id,
      color: h.color || '#3B82F6',
      val: item.map[h.id] ? item.map[h.id].size : 0
    })).filter(seg => seg.val > 0);
  });
  
  return { data, maxVal: maxVal || 10 };
});

// Navigation actions
const prevMonth = () => {
  if (currentMonth.value === 1) {
    currentMonth.value = 12;
    currentYear.value--;
  } else {
    currentMonth.value--;
  }
};

const nextMonth = () => {
  if (currentMonth.value === 12) {
    currentMonth.value = 1;
    currentYear.value++;
  } else {
    currentMonth.value++;
  }
};

const prevYear = () => currentYear.value--;
const nextYear = () => currentYear.value++;

const jumpToMonth = (m) => {
  currentMonth.value = m;
  filterMode.value = 'month';
};

const jumpToYear = (y) => {
  currentYear.value = y;
  filterMode.value = 'year';
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
.stat-container {
  min-height: 100vh;
  padding: 16px;
  padding-bottom: calc(env(safe-area-inset-bottom) + 24px);
  background: var(--background);
}

.filter-section {
  margin-bottom: 12px;
  
  .habit-selector-trigger {
    padding: 8px 16px;
    background: var(--surface);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-light);
    
    .trigger-text {
      font-size: 14px;
      font-weight: 500;
      color: var(--text-main);
      margin-right: 4px;
    }
    
    .icon-arrow-down {
      width: 0; 
      height: 0; 
      border-left: 4px solid transparent;
      border-right: 4px solid transparent;
      border-top: 5px solid var(--text-muted);
    }
  }
  
  .time-segments {
    background: #E2E8F0;
    padding: 4px;
    border-radius: var(--radius-md);
    
    .segment {
      padding: 6px 12px;
      border-radius: var(--radius-sm);
      font-size: 13px;
      font-weight: 500;
      color: var(--text-regular);
      transition: all 0.2s;
      
      &.is-active {
        background: var(--surface);
        color: var(--primary);
        box-shadow: var(--shadow-sm);
      }
    }
  }
}

.habit-tags {
  margin-bottom: 12px;
  .tags-scroll {
    width: 100%;
    white-space: nowrap;
  }
  
  .tag {
    display: inline-flex;
    padding: 4px 8px 4px 10px;
    background: white;
    border-radius: var(--radius-sm);
    margin-right: 8px;
    border: 1px solid var(--border-light);
    
    .tag-color-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-right: 6px;
    }
    .tag-text {
      font-size: 13px;
      color: var(--text-main);
    }
    .tag-close {
      width: 20px;
      height: 20px;
      margin-left: 4px;
      font-size: 16px;
      color: var(--text-muted);
    }
  }
}

.glass-panel {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}

.overview-card {
  padding: 16px;
  margin-bottom: 12px;
  
  .overview-header {
    margin-bottom: 12px;
    .overview-title {
      font-size: 16px;
      font-weight: 600;
      color: var(--text-main);
    }
  }
  
  .total-days-box {
    justify-content: center;
    .total-num {
      font-size: 36px;
      font-weight: 800;
      color: var(--primary);
      line-height: 1;
    }
    .total-unit {
      font-size: 14px;
      color: var(--text-muted);
      margin-left: 4px;
      margin-bottom: 2px;
    }
    .total-label {
      font-size: 14px;
      color: var(--text-regular);
      margin-top: 8px;
    }
  }
  
  .breakdown-list {
    flex: 1;
    margin-left: 56px;
    display: grid;
    grid-template-columns: 1fr;
    grid-auto-rows: auto;
    gap: 16px;
    height: 92px;
    overflow-y: auto;
    align-content: start;
    
    .breakdown-item {
      width: 100%;
      .color-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 8px;
      }
      .habit-name {
        font-size: 14px;
        color: var(--text-regular);
      }
      .habit-days {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-main);
      }
      .habit-sub-days {
        font-size: 11px;
        color: var(--text-muted);
        margin-top: 2px;
      }
    }
  }
}

.chart-area {
  padding: 16px;
  
  .chart-header {
    margin-bottom: 4px;
    .nav-btn {
      font-size: 24px;
      color: var(--text-muted);
      padding: 0 16px;
      cursor: pointer;
    }
    .chart-title {
      font-size: 16px;
      font-weight: 600;
    }
  }
  
  .chart-subtitle {
    font-size: 14px;
    color: var(--text-muted);
    text-align: center;
    margin-bottom: 20px;
    display: block;
  }
}

/* Calendar Styles */
.calendar {
  .weekdays {
    margin-bottom: 12px;
    .weekday {
      width: 14.28%;
      text-align: center;
      font-size: 13px;
      color: var(--text-muted);
    }
  }
  
  .days-grid {
    display: flex;
    flex-wrap: wrap;
    
    .day-cell {
      width: 14.28%;
      height: 48px;
      margin-bottom: 8px;
      
      .day-num {
        font-size: 15px;
        color: var(--text-main);
        font-weight: 500;
        margin-bottom: 4px;
        
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
      }
      
      &.is-today .day-num {
        background-color: var(--primary);
        color: white;
      }
      
      .dots-row {
        gap: 2px;
        flex-wrap: wrap;
        width: 100%;
        padding: 0 4px;
        
        .tiny-dot {
          width: 5px;
          height: 5px;
          border-radius: 50%;
        }
      }
    }
  }
}

/* Bar Chart Styles */
.chart-container {
  height: 200px;
  margin-bottom: 24px;
  
  .y-axis {
    width: 30px;
    padding-bottom: 20px; 
    margin-right: 8px;
    text {
      font-size: 11px;
      color: var(--text-muted);
    }
  }
  
  .chart-bars {
    flex: 1;
    align-items: flex-end;
    
    .bar-col {
      width: 24px;
      height: 100%;
      position: relative;
      
      .bar-stack-area {
        width: 12px;
        height: 180px;
        background: rgba(0,0,0,0.03);
        border-radius: 6px;
        overflow: hidden;
        margin-bottom: 8px;
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        
        .bar-segment {
          width: 100%;
          transition: height 0.3s ease;
          
          &:first-child {
            border-top-left-radius: 6px;
            border-top-right-radius: 6px;
          }
        }
      }
      
      .x-label {
        font-size: 11px;
        color: var(--text-muted);
      }
    }
  }
}

.mt-4 {
  margin-top: 0px;
}

/* Quick Jump Styles */
.quick-jump {
  .quick-jump-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
    margin-bottom: 12px;
  }
  
  .quick-jump-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    
    .quick-btn {
      background: var(--background);
      padding: 10px 0;
      text-align: center;
      border-radius: var(--radius-sm);
      font-size: 14px;
      color: var(--text-regular);
      border: 1px solid var(--border-light);
      
      &:active {
        background: var(--surface-hover);
      }
    }
  }
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex;
  align-items: flex-end;
}

.modal-content {
  background: white;
  width: 100%;
  border-top-left-radius: 20px;
  border-top-right-radius: 20px;
  padding: 24px;
  padding-bottom: calc(24px + env(safe-area-inset-bottom));
  max-height: 70vh;
  
  .modal-header {
    margin-bottom: 20px;
    .modal-title {
      font-size: 18px;
      font-weight: 600;
    }
    .modal-close {
      font-size: 24px;
      color: var(--text-muted);
      width: 32px;
      height: 32px;
      text-align: center;
      line-height: 32px;
    }
  }
  
  .modal-list {
    flex: 1;
    margin-bottom: 24px;
    
    .modal-item {
      padding: 16px 0;
      border-bottom: 1px solid var(--border-light);
      
      .color-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 12px;
      }
      
      .modal-item-name {
        font-size: 16px;
        color: var(--text-main);
      }
      
      .checkbox {
        width: 20px;
        height: 20px;
        border-radius: 4px;
        border: 2px solid var(--border-color);
        transition: all 0.2s;
        position: relative;
        
        &.checked {
          background: var(--primary);
          border-color: var(--primary);
          
          &::after {
            content: '';
            position: absolute;
            left: 5px;
            top: 1px;
            width: 5px;
            height: 10px;
            border: solid white;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
          }
        }
      }
    }
  }
  
  .modal-footer {
    width: 100%;
  }
  
  .btn-primary {
    width: 100%;
    height: 48px;
    background: var(--primary);
    color: white;
    border-radius: var(--radius-xl);
    font-size: 16px;
    font-weight: 600;
  }
}
</style>

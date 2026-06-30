<template>
  <view class="create-container">
    <view class="form-body flex-col">
        <!-- Habit Name -->
        <view class="form-item flex-col">
          <text class="label">习惯名称 <text class="required">*</text></text>
          <input 
            class="input-box" 
            v-model="formData.name" 
            maxlength="10" 
            placeholder="例如：早起喝水" 
          />
        </view>

        <!-- Icon & Color Selection -->
        <view class="form-item flex-col">
          <text class="label">选择颜色</text>
          <swiper class="color-swiper" indicator-dots indicator-color="rgba(0,0,0,0.1)" indicator-active-color="var(--primary)">
            <swiper-item v-for="(page, index) in colorPages" :key="index">
              <view class="color-grid">
                <view 
                  v-for="color in page" 
                  :key="color"
                  class="color-item"
                  :style="{ backgroundColor: color }"
                  :class="{ 'is-active': formData.color === color }"
                  @click="formData.color = color"
                ></view>
              </view>
            </swiper-item>
          </swiper>
          
          <text class="label" style="margin-top: 8px;">选择图标</text>
          <swiper class="icon-swiper" indicator-dots indicator-color="rgba(0,0,0,0.1)" indicator-active-color="var(--primary)">
            <swiper-item v-for="(page, index) in iconPages" :key="index">
              <view class="icon-grid">
                <view 
                  v-for="icon in page" 
                  :key="icon"
                  class="icon-item flex-row items-center justify-center"
                  :class="{ 'is-active': formData.icon === icon }"
                  :style="{ backgroundColor: formData.icon === icon ? formData.color : 'var(--background)' }"
                  @click="formData.icon = icon"
                >
                  <image :src="'/static/icons/habbit/' + icon + '.png'" class="custom-icon" />
                </view>
              </view>
            </swiper-item>
          </swiper>
        </view>

        <!-- Goal Settings -->
        <view class="form-item flex-col">
          <text class="label">打卡目标 <text class="required">*</text></text>
          
          <view class="tabs flex-row" style="margin-bottom: 12px;">
            <view 
              class="tab-item flex-row items-center justify-center"
              :class="{ 'is-active': formData.goalType === 'frequency' }"
              @click="formData.goalType = 'frequency'"
            >次数目标</view>
            <view 
              class="tab-item flex-row items-center justify-center"
              :class="{ 'is-active': formData.goalType === 'amount' }"
              @click="formData.goalType = 'amount'"
            >总量目标</view>
          </view>
          
          <view class="tabs flex-row">
            <view 
              class="tab-item flex-row items-center justify-center"
              :class="{ 'is-active': formData.frequencyType === 'weekly' }"
              @click="formData.frequencyType = 'weekly'"
            >按周</view>
            <view 
              class="tab-item flex-row items-center justify-center"
              :class="{ 'is-active': formData.frequencyType === 'monthly' }"
              @click="formData.frequencyType = 'monthly'"
            >按月</view>
          </view>

          <!-- Cycle Sub Options -->
          <view class="cycle-options flex-col">
            <!-- Frequency Goal Inputs -->
            <view v-if="formData.goalType === 'frequency'">
              <view v-if="formData.frequencyType === 'weekly'" class="flex-row items-center justify-between step-control">
                <text>每周目标次数</text>
                <view class="stepper flex-row items-center">
                  <view class="step-btn" @click="formData.weeklyTarget > 1 && formData.weeklyTarget--">-</view>
                  <text class="step-val">{{ formData.weeklyTarget }}</text>
                  <view class="step-btn" @click="formData.weeklyTarget < 7 && formData.weeklyTarget++">+</view>
                </view>
              </view>
              
              <view v-if="formData.frequencyType === 'monthly'" class="flex-row items-center justify-between step-control">
                <text>每月目标次数</text>
                <view class="stepper flex-row items-center">
                  <view class="step-btn" @click="formData.monthlyTarget > 1 && formData.monthlyTarget--">-</view>
                  <text class="step-val">{{ formData.monthlyTarget }}</text>
                  <view class="step-btn" @click="formData.monthlyTarget < 31 && formData.monthlyTarget++">+</view>
                </view>
              </view>
            </view>
            
            <!-- Amount Goal Inputs -->
            <view v-if="formData.goalType === 'amount'" class="flex-col amount-settings">
              <view class="flex-row items-center justify-between amount-row">
                <text class="amount-label">{{ formData.frequencyType === 'weekly' ? '每周' : '每月' }}目标总量</text>
                <view class="flex-row items-center amount-inputs">
                  <input class="amount-input" type="digit" v-model="formData.amountValue" @input="onAmountInput" placeholder="0" />
                  <picker class="unit-picker" mode="selector" :range="unitOptions" @change="onUnitChange">
                    <view class="picker-display flex-row items-center">
                      <text class="unit-text">{{ formData.amountUnit }}</text>
                      <text class="unit-arrow">▼</text>
                    </view>
                  </picker>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
    <view class="fixed-bottom">
      <view 
        class="submit-btn primary-btn flex-row items-center justify-center" 
        :class="{ 'is-loading': isSubmitting }"
        @click="submit"
      >
        <view v-if="isSubmitting" class="loading-spinner"></view>
        <text>{{ isSubmitting ? '创建中...' : '完成创建' }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { reactive, computed, ref, nextTick } from 'vue';
import { useHabitStore } from '@/store/habit';
import { localIcons } from '@/utils/icons';

const habitStore = useHabitStore();

const allColors = [
  // Page 1: Reds, Pinks, Oranges
  '#B71C1C', '#FF3B30', '#F87171', '#FCA5A5', '#FFADAD', '#FFB3BA',
  '#880E4F', '#E91E63', '#FF2D55', '#FB7185', '#FFC6FF', '#FDE2E4',
  '#BF360C', '#E65100', '#FF6F00', '#F57F17', '#FF9500', '#FFDFBA',
  
  // Page 2: Yellows, Limes, Greens
  '#FFD6A5', '#FFCC00', '#FBBF24', '#FDE047', '#FFFFBA', '#FDFFB6',
  '#827717', '#CDDC39', '#8BC34A', '#E2F0CB', '#33691E', '#1B5E20',
  '#4CAF50', '#4CD964', '#34D399', '#86EFAC', '#BAFFC9', '#CAFFBF',
  
  // Page 3: Teals, Cyans, Blues
  '#004D40', '#006064', '#009688', '#B5EAD7', '#00BCD4', '#67E8F9',
  '#9BF6FF', '#5AC8FA', '#38BDF8', '#BAE1FF', '#A0C4FF', '#01579B',
  '#0D47A1', '#007AFF', '#2196F3', '#1A237E', '#3F51B5', '#818CF8',
  
  // Page 4: Indigos, Purples, Neutrals
  '#311B92', '#5856D6', '#BDB2FF', '#C7CEEA', '#4A148C', '#673AB7',
  '#9C27B0', '#A78BFA', '#E879F9', '#E6B3FF', '#3E2723', '#78716C',
  '#212121', '#94A3B8', '#9CA3AF', '#A1A1AA', '#D4D4D8', '#E5E7EB'
];

const colorPages = computed(() => {
  const pages = [];
  for (let i = 0; i < allColors.length; i += 18) {
    pages.push(allColors.slice(i, i + 18));
  }
  return pages;
});

const icons = localIcons;

const iconPages = computed(() => {
  const pages = [];
  for (let i = 0; i < icons.length; i += 18) {
    pages.push(icons.slice(i, i + 18));
  }
  return pages;
});

const unitOptions = ['km', '公里', '米', '分钟', '小时', '组', '次', '页'];
const onUnitChange = (e) => {
  formData.amountUnit = unitOptions[e.detail.value];
};

const formData = reactive({
  name: '',
  color: allColors[0],
  icon: icons[0],
  goalType: 'frequency',
  frequencyType: 'weekly',
  weeklyTarget: 3,
  monthlyTarget: 10,
  amountValue: '',
  amountUnit: 'km'
});

const isSubmitting = ref(false);

// unused now
const toggleFixedDay = () => {};

const onAmountInput = (e) => {
  let val = e.detail.value.toString();
  val = val.replace(/[^\d.]/g, ''); 
  const parts = val.split('.');
  if (parts.length > 2) {
    val = parts[0] + '.' + parts.slice(1).join('');
  }
  if (val.includes('.')) {
    const p = val.split('.');
    if (p[1].length > 1) {
      val = p[0] + '.' + p[1].substring(0, 1);
    }
  }
  nextTick(() => {
    formData.amountValue = val;
  });
  return val;
};

const submit = async () => {
  if (isSubmitting.value) return;

  if (habitStore.habits.length >= 10) {
    uni.showToast({ title: '最多只能创建10个习惯哦', icon: 'none' });
    return;
  }

  const trimmedName = formData.name.trim();
  if (!trimmedName) {
    uni.showToast({ title: '请输入习惯名称', icon: 'none' });
    return;
  }
  
  // 校验重复名称
  const isDuplicate = habitStore.habits.some(h => h.name === trimmedName);
  if (isDuplicate) {
    uni.showToast({ title: '习惯已经存在了鸭 🦆', icon: 'none', duration: 2000 });
    return;
  }

  const specialChars = /[`~!@#$%^&*()_\-+=<>?:"{}|,.\/;'\\[\]·~！@#￥%……&*（）——\-+={}|《》？：“”【】、；‘’，。、]/im;
  if (specialChars.test(trimmedName)) {
    uni.showToast({ title: '习惯名称不能包含特殊字符', icon: 'none' });
    return;
  }
  
  if (formData.goalType === 'amount') {
    const amountVal = parseFloat(formData.amountValue);
    if (isNaN(amountVal) || amountVal <= 0) {
      uni.showToast({ title: '请输入正确的目标总量', icon: 'none' });
      return;
    }
    formData.amountValue = amountVal;
  }
  
  isSubmitting.value = true;
  try {
    await habitStore.addHabit({ ...formData, name: trimmedName });
    uni.showToast({ title: '创建成功', icon: 'success' });
    setTimeout(() => uni.navigateBack(), 1000);
  } catch (error) {
    uni.showModal({
      title: '错误详情 (请截图)',
      content: typeof error === 'object' ? JSON.stringify(error, Object.getOwnPropertyNames(error)) : String(error),
      showCancel: false
    });
  } finally {
    isSubmitting.value = false;
  }
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
.create-container {
  min-height: 100vh;
  padding: 16px;
  padding-bottom: 120px;
  background: rgba(255, 255, 255, 0.6);
}

.form-body {
  gap: 16px;
  margin-bottom: 24px;
}

.form-item {
  .label {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
    margin-bottom: 8px;
    .required {
      color: var(--error);
      margin-left: 4px;
    }
  }
  
  .input-box {
    height: 48px;
    background: var(--background);
    border-radius: var(--radius-md);
    padding: 0 16px;
    font-size: 15px;
  }
}

.color-swiper {
  height: 140px;
  margin-bottom: 8px;
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
  justify-items: center;
  padding-top: 6px;
  padding-bottom: 16px;
}

.icon-swiper {
  height: 170px;
}

.icon-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
  justify-items: center;
  padding-top: 6px;
  padding-bottom: 16px;
}

.color-item {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  flex-shrink: 0;
  border: 2px solid transparent;
  transition: transform 0.2s;
  
  &.is-active {
    transform: scale(1.15);
    border-color: var(--text-main);
  }
}

.icon-item {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  flex-shrink: 0;
  transition: all 0.2s;
  
  &.is-active {
    transform: scale(1.05);
  }
}

.custom-icon {
  width: 20px;
  height: 20px;
}

.tabs {
  background: var(--background);
  border-radius: var(--radius-md);
  padding: 4px;
}

.tab-item {
  flex: 1;
  height: 36px;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-muted);
  transition: all 0.2s;
  
  &.is-active {
    background: var(--surface);
    color: var(--text-main);
    box-shadow: var(--shadow-sm);
  }
}

.cycle-options {
  margin-top: 12px;
  background: var(--background);
  border-radius: var(--radius-md);
  padding: 12px;
}

.fixed-days {
  gap: 8px;
  justify-content: space-between;
}

.day-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--surface);
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 600;
  transition: all 0.2s;
  
  &.is-active {
    background: var(--primary);
    color: white;
    box-shadow: var(--shadow-sm);
  }
}

.step-control {
  font-size: 14px;
  color: var(--text-main);
  font-weight: 500;
}

.stepper {
  background: var(--surface);
  border-radius: var(--radius-sm);
  padding: 4px;
  
  .step-btn {
    width: 28px;
    height: 28px;
    border-radius: 4px;
    background: var(--background);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    color: var(--text-main);
    font-weight: bold;
    
    &:active {
      background: var(--border-color);
    }
  }
  
  .step-val {
    width: 36px;
    text-align: center;
    font-size: 15px;
    font-weight: 600;
  }
}

.fixed-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 20px;
  padding-bottom: calc(16px + env(safe-area-inset-bottom));
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border-top: 1px solid var(--border-light);
  z-index: 100;

  .primary-btn {
    height: 48px;
    background: var(--primary);
    color: white;
    border-radius: var(--radius-xl);
    font-size: 16px;
    font-weight: 600;
    transition: all 0.3s ease;
    
    &.is-loading {
      opacity: 0.7;
      pointer-events: none;
    }
  }
}

.loading-spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid #ffffff;
  border-radius: 50%;
  margin-right: 8px;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.amount-settings {
  gap: 12px;
}

.amount-row {
  height: 48px;
}

.amount-label {
  font-size: 14px;
  color: var(--text-main);
  font-weight: 500;
}

.amount-inputs {
  gap: 8px;
}

.amount-input {
  width: 80px;
  height: 36px;
  background: var(--surface);
  border-radius: var(--radius-sm);
  padding: 0 12px;
  font-size: 16px;
  font-weight: 600;
  text-align: center;
  color: var(--primary);
  border: 1px solid var(--border-light);
}

.picker-display {
  height: 36px;
  padding: 0 12px;
  background: var(--surface);
  border-radius: var(--radius-sm);
  border: 1px solid var(--border-light);
  
  .unit-text {
    font-size: 14px;
    color: var(--text-main);
    margin-right: 4px;
  }
  
  .unit-arrow {
    font-size: 10px;
    color: var(--text-muted);
  }
}
</style>

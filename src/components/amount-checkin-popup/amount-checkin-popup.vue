<template>
  <uni-popup ref="popupRef" type="bottom" :safe-area="false">
    <view class="popup-content flex-col">
      <view class="popup-header flex-row items-center justify-between">
        <text class="popup-title">录入打卡数据</text>
        <uni-icons type="closeempty" size="20" color="#9CA3AF" @click="close"></uni-icons>
      </view>
      
      <view class="habit-info flex-row items-center">
        <view class="habit-icon" :style="{ backgroundColor: habit?.color || 'var(--primary-light)' }">
          <image v-if="habit?.icon" :src="'/static/icons/habbit/' + habit.icon + '.png'" class="custom-icon" />
          <text v-else class="icon-text">{{ habit?.name?.charAt(0) }}</text>
        </view>
        <view class="habit-details flex-col">
          <text class="habit-name">{{ habit?.name }}</text>
          <text class="habit-goal">本周期目标：{{ habit?.amountValue || 0 }} {{ habit?.amountUnit || '' }}</text>
          <text class="habit-progress">本周期已累计：{{ accumulatedAmount }} {{ habit?.amountUnit || '' }}</text>
        </view>
      </view>

      <view class="input-section flex-col">
        <text class="input-label">本次完成量</text>
        <view class="input-wrapper flex-row items-center">
          <input 
            class="amount-input" 
            type="digit" 
            v-model="amount" 
            @input="onAmountInput"
            placeholder="0" 
            :focus="isFocus"
          />
          <text class="unit-text">{{ habit?.amountUnit || '' }}</text>
        </view>
      </view>

      <view class="submit-btn flex-row items-center justify-center" @click="submit">
        <text>完成打卡</text>
      </view>
    </view>
  </uni-popup>
</template>

<script setup>
import { ref, nextTick } from 'vue';

const props = defineProps({
  habit: Object,
  accumulatedAmount: {
    type: Number,
    default: 0
  },
  initialAmount: {
    type: Number,
    default: null
  }
});

const emit = defineEmits(['close', 'submit']);

const popupRef = ref(null);
const amount = ref('');
const isFocus = ref(false);

const open = () => {
  if (props.initialAmount) {
    amount.value = props.initialAmount;
  } else {
    amount.value = '';
  }
  popupRef.value?.open();
  // Wait for the popup slide-up animation (usually ~300ms) to complete
  // before focusing the input, otherwise the keyboard popup will cause a jump.
  setTimeout(() => {
    isFocus.value = true;
  }, 400);
};

const close = () => {
  isFocus.value = false;
  popupRef.value?.close();
};


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
    amount.value = val;
  });
  return val;
};

const submit = () => {
  const finalAmount = parseFloat(amount.value);
  if (isNaN(finalAmount) || finalAmount <= 0) {
    uni.showToast({ title: '请输入正确的数值', icon: 'none' });
    return;
  }
  emit('submit', finalAmount);
  close();
};

defineExpose({ open, close });
</script>

<style lang="scss" scoped>
.popup-content {
  width: 100%;
  box-sizing: border-box;
  background: #FFFFFF;
  border-radius: 24px 24px 0 0;
  padding: 24px 20px;
}

.popup-header {
  margin-bottom: 24px;
  
  .popup-title {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-main);
  }
}

.habit-info {
  background: #F9FAFB;
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 32px;
  
  .habit-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 16px;
    
    .custom-icon {
      width: 28px;
      height: 28px;
    }
    
    .icon-text {
      font-size: 20px;
      font-weight: bold;
      color: white;
    }
  }
  
  .habit-details {
    flex: 1;
    
    .habit-name {
      font-size: 16px;
      font-weight: 700;
      color: var(--text-main);
      margin-bottom: 4px;
    }
    
    .habit-goal {
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 2px;
    }
    
    .habit-progress {
      font-size: 13px;
      color: var(--primary);
      font-weight: 500;
    }
  }
}

.input-section {
  margin-bottom: 40px;
  
  .input-label {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-main);
    margin-bottom: 16px;
  }
  
  .input-wrapper {
    background: #F3F4F6;
    border-radius: 16px;
    padding: 12px 20px;
    
    .amount-input {
      flex: 1;
      height: 60px;
      font-size: 40px;
      font-weight: 800;
      color: var(--primary);
      text-align: center;
    }
    
    .unit-text {
      font-size: 16px;
      font-weight: 600;
      color: var(--text-main);
      margin-left: 12px;
    }
  }
}

.submit-btn {
  height: 52px;
  background: var(--primary);
  border-radius: var(--radius-xl);
  color: white;
  font-size: 16px;
  font-weight: 600;
  box-shadow: 0 8px 16px rgba(139, 92, 246, 0.25);
  transition: all 0.2s;
  
  &:active {
    transform: scale(0.98);
  }
}
</style>

<template>
  <uni-popup ref="popupRef" type="bottom" :safe-area="false">
    <view class="popup-content flex-col">
      <view class="popup-header flex-row items-center justify-between">
        <text class="popup-title">打卡成功</text>
        <uni-icons type="closeempty" size="20" color="#9CA3AF" @click="close"></uni-icons>
      </view>
      
      <!-- 进度卡片 -->
      <view v-if="progressData" class="progress-card flex-col">
        <text class="progress-title">目标进展</text>
        <view class="progress-row flex-row items-center justify-between">
          <text class="stat-label">本次完成</text>
          <text class="stat-val highlight">{{ progressData.todayAmount }} {{ progressData.unit }}</text>
        </view>
        <view class="progress-row flex-row items-center justify-between">
          <text class="stat-label">{{ progressData.label }}累计</text>
          <text class="stat-val">{{ progressData.currentTotal }} {{ progressData.unit }}</text>
        </view>
        <view class="progress-row flex-row items-center justify-between">
          <text class="stat-label">{{ progressData.targetLabel }}</text>
          <text class="stat-val">{{ progressData.target }} {{ progressData.unit }}</text>
        </view>
        
        <view v-if="progressData.currentTotal >= progressData.target" class="achievement-text">
          <text>🎉 {{ progressData.targetLabel }}已达成！</text>
        </view>
      </view>
      
      <view class="actions-group flex-col">
        <view class="btn primary-btn" @click="recordMood">记心情</view>
        <view class="btn secondary-btn" @click="generatePoster">生成分享海报</view>
      </view>
    </view>
  </uni-popup>
  <canvas canvas-id="posterCanvas" class="poster-canvas"></canvas>
</template>

<script setup>
import { computed, ref, getCurrentInstance } from 'vue';
import { useHabitStore } from '@/store/habit';
import { useUserStore } from '@/store/user';
import { drawRoundRect } from '@/utils/canvasHelper';
import { getDailyQuote } from '@/utils/quotes';

const props = defineProps({
  habit: Object,
  date: String
});

const emit = defineEmits(['close', 'record']);
const habitStore = useHabitStore();
const popupRef = ref(null);
const instance = getCurrentInstance();

const open = () => {
  popupRef.value?.open();
};

const close = () => {
  popupRef.value?.close();
};

const recordMood = () => {
  emit('record');
};

// ======================== STATS LOGIC ========================
const periodCheckins = computed(() => {
  if (!props.habit) return [];
  const checkins = habitStore.getCheckins.filter(c => c.habitId === props.habit.id);
  const dateStr = props.date || new Date().toISOString().split('T')[0];
  const [y, m, d] = dateStr.split('-');
  const now = new Date(y, m - 1, d);
  
  if (props.habit.frequencyType === 'weekly') {
    const day = now.getDay();
    const diff = day === 0 ? 6 : day - 1;
    const monday = new Date(now);
    monday.setDate(now.getDate() - diff);
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    
    const startStr = [monday.getFullYear(), String(monday.getMonth()+1).padStart(2,'0'), String(monday.getDate()).padStart(2,'0')].join('-');
    const endStr = [sunday.getFullYear(), String(sunday.getMonth()+1).padStart(2,'0'), String(sunday.getDate()).padStart(2,'0')].join('-');
    return checkins.filter(c => c.date >= startStr && c.date <= endStr);
  } else {
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
    const startStr = [firstDay.getFullYear(), String(firstDay.getMonth()+1).padStart(2,'0'), String(firstDay.getDate()).padStart(2,'0')].join('-');
    const endStr = [lastDay.getFullYear(), String(lastDay.getMonth()+1).padStart(2,'0'), String(lastDay.getDate()).padStart(2,'0')].join('-');
    return checkins.filter(c => c.date >= startStr && c.date <= endStr);
  }
});

const progressData = computed(() => {
  if (!props.habit) return null;
  const isAmount = props.habit.goalType === 'amount';
  
  let target = 0;
  let currentTotal = 0;
  let todayAmount = 0;
  const unit = isAmount ? (props.habit.amountUnit || '') : '次';
  const label = props.habit.frequencyType === 'weekly' ? '本周' : '本月';
  const targetLabel = props.habit.frequencyType === 'weekly' ? '周目标' : '月目标';

  if (isAmount) {
    target = Number(props.habit.amountValue) || 0;
    currentTotal = Number(periodCheckins.value.reduce((sum, c) => sum + (Number(c.amount) || 0), 0).toFixed(1));
    const todayCheckin = periodCheckins.value.find(c => c.date === props.date);
    todayAmount = todayCheckin ? (Number(todayCheckin.amount) || 0) : 0;
  } else {
    target = props.habit.frequencyType === 'weekly' ? (props.habit.weeklyTarget || 3) : (props.habit.monthlyTarget || 10);
    currentTotal = periodCheckins.value.length;
    const todayCheckin = periodCheckins.value.find(c => c.date === props.date);
    todayAmount = todayCheckin ? 1 : 0;
  }

  return { label, targetLabel, target, currentTotal, todayAmount, unit };
});

const statsData = computed(() => {
  if (!props.habit) return null;
  const checkins = habitStore.getCheckins.filter(c => c.habitId === props.habit.id).sort((a,b) => a.date.localeCompare(b.date));
  const totalCount = checkins.length;
  const totalAmount = Number(checkins.reduce((sum, c) => sum + (Number(c.amount) || 0), 0).toFixed(1));
  
  const dateStr = props.date || new Date().toISOString().split('T')[0];
  const [ty, tm, td] = dateStr.split('-');
  const todayDate = new Date(ty, tm - 1, td);
  const currentMonthStr = todayDate.getFullYear() + '-' + String(todayDate.getMonth() + 1).padStart(2, '0');
  const thisMonthCheckins = checkins.filter(c => c.date.startsWith(currentMonthStr));
  const monthCount = thisMonthCheckins.length;
  const monthDays = new Set(thisMonthCheckins.map(c => c.date)).size;
  const monthAmount = Number(thisMonthCheckins.reduce((sum, c) => sum + (Number(c.amount) || 0), 0).toFixed(1));
  
  const todayCheckin = checkins.find(c => c.date === dateStr);
  const todayAmount = todayCheckin ? (Number(todayCheckin.amount) || 0) : (props.habit.goalType === 'amount' ? 0 : (thisMonthCheckins.some(c => c.date === dateStr) ? 1 : 0));
  
  let maxStreak = 0;
  let currentStreak = 0;
  let tempStreak = 0;
  let lastDate = null;
  const uniqueDates = Array.from(new Set(checkins.map(c => c.date))).sort();
  
  for (let i = 0; i < uniqueDates.length; i++) {
    if (!lastDate) {
      tempStreak = 1;
    } else {
      const d1 = new Date(lastDate);
      const d2 = new Date(uniqueDates[i]);
      const diff = Math.floor((d2 - d1) / (1000 * 60 * 60 * 24));
      if (diff === 1) {
        tempStreak += 1;
      } else if (diff > 1) {
        tempStreak = 1;
      }
    }
    if (tempStreak > maxStreak) maxStreak = tempStreak;
    lastDate = uniqueDates[i];
  }
  
  const todayStr = dateStr;
  const yesterdayDate = new Date(todayDate);
  yesterdayDate.setDate(todayDate.getDate() - 1);
  const yesterdayStr = [yesterdayDate.getFullYear(), String(yesterdayDate.getMonth() + 1).padStart(2, '0'), String(yesterdayDate.getDate()).padStart(2, '0')].join('-');
  
  if (!uniqueDates.includes(todayStr) && !uniqueDates.includes(yesterdayStr)) {
    currentStreak = 0;
  } else {
    let backDate = new Date(uniqueDates.includes(todayStr) ? todayStr : yesterdayStr);
    while (true) {
      const bStr = [backDate.getFullYear(), String(backDate.getMonth() + 1).padStart(2, '0'), String(backDate.getDate()).padStart(2, '0')].join('-');
      if (uniqueDates.includes(bStr)) {
        currentStreak++;
        backDate.setDate(backDate.getDate() - 1);
      } else {
        break;
      }
    }
  }
  
  const dayOfWeek = todayDate.getDay() === 0 ? 6 : todayDate.getDay() - 1;
  const mondayDate = new Date(todayDate);
  mondayDate.setDate(todayDate.getDate() - dayOfWeek);
  
  const weeklyTrend = [];
  let weekCheckins = 0;
  for (let i = 0; i < 7; i++) {
    const d = new Date(mondayDate);
    d.setDate(mondayDate.getDate() + i);
    const dStr = [d.getFullYear(), String(d.getMonth() + 1).padStart(2, '0'), String(d.getDate()).padStart(2, '0')].join('-');
    const hasCheckin = uniqueDates.includes(dStr);
    if (hasCheckin) weekCheckins++;
    weeklyTrend.push(hasCheckin);
  }
  
  return { totalCount, monthCount, monthDays, maxStreak, currentStreak, weeklyTrend, weekCheckins, totalAmount, monthAmount, todayAmount };
});

const generatePoster = async () => {
  try {
    uni.showLoading({ title: '生成中...' });
    const userStore = useUserStore();
    
    let avatarPath = '';
    if (userStore.userInfo?.avatarUrl) {
      try {
        const res = await new Promise((resolve, reject) => {
          uni.getImageInfo({
            src: userStore.userInfo.avatarUrl,
            success: resolve,
            fail: reject
          });
        });
        avatarPath = res.path;
      } catch(e) { console.error(e); }
    }
    
    // Download helper for remote canvas images
    const downloadImage = (url) => new Promise((resolve, reject) => {
      uni.getImageInfo({
        src: url,
        success: (res) => resolve(res.path),
        fail: (err) => resolve('') // fallback if download fails
      });
    });

    // Fetch required remote images
    const [bgPath, scancodePath] = await Promise.all([
      downloadImage(`https://mp-262de33c-8e30-4555-93c8-259e7396a210.cdn.bspapp.com/img/bg.png?t=${Date.now()}`),
      downloadImage('https://mp-262de33c-8e30-4555-93c8-259e7396a210.cdn.bspapp.com/img/scancode.jpg')
    ]);

    const ctx = uni.createCanvasContext('posterCanvas', instance.proxy);
    // Draw on a 941x1672 coordinate system, scaling down to CSS pixels
    ctx.scale(0.5, 0.5); 
    
    // 1. Static Background Image
    if (bgPath) {
      ctx.drawImage(bgPath, 0, 0, 941, 1672);
    }
    
    // Use top baseline for 1:1 design tool coordinate matching
    ctx.setTextBaseline('top');
    ctx.setTextAlign('left');

    // 1.5 Calendar Day & Month
    const dateObj = new Date(props.date || new Date().toISOString().split('T')[0]);
    
    // Month abbr (712, 133), size 36, white
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    ctx.setFontSize(36);
    ctx.setFillStyle('#FFFFFF');
    ctx.fillText(monthNames[dateObj.getMonth()], 712, 133);

    // Day (703, 207), size 72
    const dayNumStr = dateObj.getDate().toString();
    ctx.setFontSize(72);
    ctx.setFillStyle('#7E22CE');
    ctx.fillText(dayNumStr, 703, 207);
    ctx.fillText(dayNumStr, 704, 207); // bold

    // 2. Quote (107, 439), size 48
    ctx.setFontSize(48);
    ctx.setFillStyle('#111827');
    
    const quote = getDailyQuote(props.date);
    let line1 = quote;
    let line2 = '';
    if (quote.includes('，')) {
      const parts = quote.split('，');
      line1 = parts[0] + '，';
      line2 = parts[1] || '';
    }

    ctx.fillText(line1, 107, 439);
    ctx.fillText(line1, 108, 439); // fake bold
    if (line2) {
      ctx.fillText(line2, 107, 509);
      ctx.fillText(line2, 108, 509);
    }

    // Habit Name & Icon
    const hName = props.habit?.name || '未知习惯';
    ctx.setFontSize(80); // smaller
    ctx.setFillStyle('#7E22CE');
    ctx.fillText(hName, 107, 810); // down further
    ctx.fillText(hName, 108, 810);
    
    const isAmount = props.habit?.goalType === 'amount';
    const habitUnit = isAmount ? (props.habit?.amountUnit || '') : '天';

    if (props.habit?.icon) {
      const w = ctx.measureText(hName).width;
      const iconX = 107 + w + 30;
      // Bottom align to Y=890
      // Icon height=60, so Y=890-60=830
      ctx.drawImage(`/static/icons/habbit/${props.habit.icon}.png`, iconX, 830, 60, 60);

      // Amount-based: append text and celebration icon
      if (isAmount && statsData.value) {
        // shift to the right by using a larger gap (40px)
        const textXStart = iconX + 60 + 40;
        
        ctx.setFontSize(48); // larger text
        ctx.setFillStyle('#111827');
        const prefix = "完成";
        const textY = 842; // bottom aligned: 890 - 48 = 842
        ctx.fillText(prefix, textXStart, textY);
        ctx.fillText(prefix, textXStart + 1, textY); // bold
        const wPrefix = ctx.measureText(prefix).width;

        ctx.setFontSize(64); // number even larger
        ctx.setFillStyle('#7E22CE'); // highlight color
        const numText = ` ${statsData.value.todayAmount} `; // spaces around number
        const numY = 826; // bottom aligned: 890 - 64 = 826
        ctx.fillText(numText, textXStart + wPrefix, numY);
        ctx.fillText(numText, textXStart + wPrefix + 1, numY); // bold layer 1
        ctx.fillText(numText, textXStart + wPrefix + 2, numY); // bold layer 2
        const wNum = ctx.measureText(numText).width;

        ctx.setFontSize(48);
        ctx.setFillStyle('#111827');
        const suffix = `${habitUnit}`;
        ctx.fillText(suffix, textXStart + wPrefix + wNum, textY);
        ctx.fillText(suffix, textXStart + wPrefix + wNum + 1, textY); // bold
        const wSuffix = ctx.measureText(suffix).width;

        const celebX = textXStart + wPrefix + wNum + wSuffix + 20;
        // Celebration icon 50x50, bottom aligned: 890 - 50 = 840
        ctx.drawImage('/static/icons/mood/158_激动.png', celebX, 840, 50, 50);
      }
    }

    // (Chick, Avatar, Nickname removed per user request)

    ctx.setTextAlign('left'); // Reset for the rest

    // 7. Stats
    const mDays = isAmount 
      ? (statsData.value.monthAmount || 0).toString() 
      : (statsData.value.monthCount || 1).toString();
      
    // Month Stats (Center X = 79 + 375/2 = 266.5)
    ctx.setFontSize(88);
    const w1 = ctx.measureText(mDays).width;
    ctx.setFontSize(40);
    const wUnit1 = ctx.measureText(habitUnit).width;
    const totalW1 = w1 + 10 + wUnit1;
    const startX1 = 266.5 - (totalW1 / 2);

    ctx.setFontSize(88); // larger
    ctx.setFillStyle('#7E22CE');
    ctx.fillText(mDays, startX1, 1177);
    ctx.fillText(mDays, startX1 + 1, 1177); // bold layer 1
    ctx.fillText(mDays, startX1 + 2, 1177); // bold layer 2
    
    ctx.setFontSize(40);
    ctx.fillText(habitUnit, startX1 + w1 + 10, 1177 + 40); // Align vertically with the larger digits
    
    // Total Stats (Center X = 480 + 375/2 = 667.5)
    const tDays = isAmount 
      ? (statsData.value.totalAmount || 0).toString() 
      : (statsData.value.totalCount || 1).toString();
      
    ctx.setFontSize(88);
    const w2 = ctx.measureText(tDays).width;
    ctx.setFontSize(40);
    const wUnit2 = ctx.measureText(habitUnit).width;
    const totalW2 = w2 + 10 + wUnit2;
    const startX2 = 667.5 - (totalW2 / 2);

    ctx.setFontSize(88); // larger
    ctx.setFillStyle('#7E22CE');
    ctx.fillText(tDays, startX2, 1177);
    ctx.fillText(tDays, startX2 + 1, 1177); // bold layer 1
    ctx.fillText(tDays, startX2 + 2, 1177); // bold layer 2
    
    ctx.setFontSize(40);
    ctx.fillText(habitUnit, startX2 + w2 + 10, 1177 + 40);

    // 8. QR Code (118, 1399) size (144, 144)
    if (scancodePath) {
      ctx.drawImage(scancodePath, 118, 1399, 144, 144);
    }
    
    ctx.draw(false, () => {
      setTimeout(() => {
        uni.canvasToTempFilePath({
          canvasId: 'posterCanvas',
          fileType: 'png',
          destWidth: 941,
          destHeight: 1672,
          success: (res) => {
            uni.hideLoading();
            uni.previewImage({ urls: [res.tempFilePath], current: res.tempFilePath });
          },
          fail: (err) => {
            console.error('canvas to file failed', err);
            uni.hideLoading();
            uni.showToast({ title: '海报生成失败', icon: 'none' });
          }
        }, instance.proxy);
      }, 500);
    });
  } catch (err) {
    uni.hideLoading();
    uni.showModal({ title: "Error", content: err.message || String(err) });
    console.error(err);
  }
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

.progress-card {
  width: 100%;
  background: #F9FAFB;
  border-radius: 16px;
  padding: 16px 20px;
  margin-bottom: 24px;
  border: 1px solid #F3F4F6;
  
  .progress-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
    margin-bottom: 12px;
  }
  
  .progress-row {
    margin-bottom: 8px;
    &:last-child {
      margin-bottom: 0;
    }
    
    .stat-label {
      font-size: 14px;
      color: var(--text-muted);
    }
    
    .stat-val {
      font-size: 15px;
      font-weight: 600;
      color: var(--text-main);
      
      &.highlight {
        color: var(--primary);
        font-size: 16px;
        font-weight: 700;
      }
    }
  }
  
  .achievement-text {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px dashed #E5E7EB;
    font-size: 14px;
    font-weight: 600;
    color: #10B981;
    text-align: center;
  }
}

.actions-group {
  width: 100%;
  gap: 12px;
  margin-top: 24px;
}

.btn {
  width: 100%;
  height: 52px;
  border-radius: var(--radius-xl);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.96);
  }
}

.primary-btn {
  background: var(--primary);
  color: white;
  box-shadow: 0 8px 16px rgba(139, 92, 246, 0.25);
}

.secondary-btn {
  background: var(--surface);
  color: var(--text-main);
  border: 1px solid var(--border-light);
}

.poster-canvas {
  width: 470.5px;
  height: 836px;
  position: fixed;
  left: -9999px;
  top: -9999px;
}
</style>

<template>
  <uni-popup ref="popupRef" type="bottom" :safe-area="false">
    <view class="popup-content flex-col">
      <view class="popup-header flex-row items-center justify-between">
        <view class="date-info flex-col">
          <text class="popup-title">记录心情</text>
          <text class="subtitle">{{ currentDate }} · {{ habitName }}</text>
        </view>
        <uni-icons type="closeempty" size="20" color="#9CA3AF" @click="close"></uni-icons>
      </view>

      <view class="form-body flex-col">
        <!-- Mood Selection -->
        <view class="form-item flex-col">
          <text class="label">当前心情 <text class="required">*</text></text>
          <view class="mood-options flex-row justify-between">
            <view 
              v-for="m in moodOptions" 
              :key="m.type"
              class="mood-btn flex-col items-center"
              :class="{ 'is-active': formData.mood === m.type }"
              @click="formData.mood = m.type"
            >
              <image :src="'/static/icons/mood/' + m.icon + '.png'" class="mood-icon" :style="{ opacity: formData.mood === m.type ? 1 : 0.6 }" />
              <text class="mood-text">{{ m.label }}</text>
            </view>
          </view>
        </view>

        <!-- Thoughts Textarea -->
        <view class="form-item flex-col">
          <text class="label">想法 (选填)</text>
          <textarea 
            class="textarea-box" 
            v-model="formData.text" 
            maxlength="200" 
            placeholder="写下这一刻的想法..." 
            :adjust-position="false"
            :show-confirm-bar="false"
          />
          <text class="char-count">{{ formData.text.length }}/200</text>
        </view>

        <!-- Image Upload -->
        <view class="form-item flex-col">
          <text class="label">图片 (选填)</text>
          <view class="image-uploader">
            <view v-if="formData.imageUrl" class="preview-box">
              <image :src="formData.imageUrl" mode="aspectFill" class="preview-img" @click="previewImage" />
              <view class="delete-btn flex-row items-center justify-center" @click.stop="removeImage">✕</view>
            </view>
            <view v-else class="upload-btn flex-col items-center justify-center" @click="chooseImage">
              <uni-icons type="camera" size="32" color="var(--text-light)"></uni-icons>
              <text class="upload-text">添加图片</text>
            </view>
          </view>
        </view>
      </view>

      <view class="footer">
        <view class="submit-btn primary-btn flex-row items-center justify-center" @click="submit">
          <text>记录</text>
        </view>
      </view>
    </view>
  </uni-popup>
</template>

<script setup>
import { reactive, computed, ref } from 'vue';
import { copyImageToiCloud } from '@/utils/icloud';

const props = defineProps({
  habitId: String,
  habitName: String
});

const emit = defineEmits(['close', 'submit']);
const popupRef = ref(null);

const open = () => {
  popupRef.value?.open();
};


const close = () => {
  popupRef.value?.close();
};

defineExpose({ open, close });

const currentDate = computed(() => {
  const d = new Date();
  return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
});

const moodOptions = [
  { type: 'excited', icon: '158_激动', label: '激动' },
  { type: 'happy', icon: '158_开心', label: '开心' },
  { type: 'normal', icon: '158_一般', label: '一般' },
  { type: 'down', icon: '158_失落', label: '失落' },
  { type: 'angry', icon: '158_愤怒', label: '愤怒' }
];

const formData = reactive({
  mood: '',
  text: '',
  imageUrl: ''
});

const chooseImage = () => {
  uni.chooseMedia({
    count: 1,
    mediaType: ['image'],
    sourceType: ['album', 'camera'],
    sizeType: ['compressed'],
    success: (res) => {
      const tempPath = res.tempFiles[0].tempFilePath;
      uni.saveFile({
        tempFilePath: tempPath,
        success: (saveRes) => {
          let finalPath = saveRes.savedFilePath;
          // Sync to iCloud
          const ext = finalPath.split('.').pop() || 'jpg';
          const icloudPath = copyImageToiCloud(finalPath, `mood_${Date.now()}.${ext}`);
          if (icloudPath) {
            finalPath = icloudPath;
          }
          formData.imageUrl = finalPath;
        },
        fail: () => {
          uni.showToast({ title: '保存图片失败', icon: 'none' });
        }
      });
    }
  });
};

const previewImage = () => {
  if (formData.imageUrl) {
    uni.previewImage({ urls: [formData.imageUrl] });
  }
};

const removeImage = () => {
  formData.imageUrl = '';
};

const submit = () => {
  if (!formData.mood) {
    uni.showToast({ title: '请选择心情', icon: 'none' });
    return;
  }
  emit('submit', { 
    habitId: props.habitId,
    mood: formData.mood,
    text: formData.text,
    imageUrl: formData.imageUrl
  });
  close();
};
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
  .subtitle {
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 4px;
  }
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
}

.mood-options {
  gap: 8px;
}

.mood-btn {
  flex: 1;
  padding: 8px 0;
  border-radius: var(--radius-md);
  background: var(--background);
  border: 2px solid transparent;
  transition: all 0.2s;
  
  .mood-icon {
    width: 32px;
    height: 32px;
    margin-bottom: 6px;
    transition: all 0.2s;
  }
  .mood-text {
    font-size: 12px;
    color: var(--text-regular);
  }
  
  &.is-active {
    background: var(--primary-bg);
    border-color: var(--primary);
    transform: scale(1.05);
    .mood-text {
      color: var(--primary);
      font-weight: 600;
    }
    .mood-icon {
      transform: scale(1.1);
    }
  }
}

.textarea-box {
  width: 100%;
  height: 80px;
  background: var(--background);
  border-radius: var(--radius-md);
  padding: 12px 16px;
  font-size: 14px;
  color: var(--text-main);
}

.char-count {
  text-align: right;
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 8px;
}

.image-uploader {
  margin-top: 8px;
}

.upload-btn {
  width: 80px;
  height: 80px;
  background: var(--background);
  border: 1px dashed var(--border-color);
  border-radius: var(--radius-md);
  
  .upload-text {
    font-size: 12px;
    color: var(--text-light);
    margin-top: 4px;
  }
}

.preview-box {
  position: relative;
  width: 80px;
  height: 80px;
  
  .preview-img {
    width: 100%;
    height: 100%;
    border-radius: var(--radius-md);
  }
  
  .delete-btn {
    position: absolute;
    top: -8px;
    right: -8px;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.6);
    color: white;
    font-size: 12px;
  }
}

.footer {
  .primary-btn {
    height: 48px;
    background: var(--primary);
    color: white;
    border-radius: var(--radius-xl);
    font-size: 16px;
    font-weight: 600;
  }
}

</style>

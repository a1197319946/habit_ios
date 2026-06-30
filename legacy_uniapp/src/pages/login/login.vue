<template>
  <view class="login-container flex-col items-center">
    <!-- Top Header (Same as Splash) -->
    <view class="header flex-col items-center">
      <view class="logo-row flex-row items-center justify-center">
        <view class="logo-icon flex-row items-center justify-center">
          <uni-icons type="checkbox-filled" size="28" color="#7C3AED"></uni-icons>
        </view>
        <text class="app-name">小习惯打卡</text>
      </view>
      <view class="subtitle-row flex-row items-center justify-center">
        <text class="dot">•</text>
        <text class="subtitle">每天一点点，养成好习惯</text>
        <text class="dot">•</text>
      </view>
    </view>

    <!-- Center 3D Illustration Placeholder -->
    <view class="illustration-container">
      <image src="/static/images/login-img.png" class="illustration-img" mode="aspectFit" />
    </view>

    <!-- Bottom Actions Area -->
    <view class="bottom-section flex-col items-center">
      
      <!-- User Profile Form -->
      <view class="profile-form flex-col items-center w-full">
        <button class="avatar-wrapper" open-type="chooseAvatar" @chooseavatar="onChooseAvatar">
          <image class="avatar-img" :src="avatarUrl || '/static/tabbar/profile.png'" mode="aspectFill"></image>
          <view class="avatar-edit-badge"><uni-icons type="camera-filled" size="12" color="#fff"></uni-icons></view>
        </button>
        <view class="nickname-wrapper flex-row items-center">
          <input type="nickname" class="nickname-input" placeholder="点击获取微信昵称" :value="nickName" @blur="onNicknameInput" @change="onNicknameInput"/>
        </view>
      </view>

      <view class="btn-group flex-col w-full items-center">
        <button class="wechat-btn flex-row items-center justify-center" @click="handleLogin">
          <uni-icons type="weixin" size="24" color="#ffffff" style="margin-right: 8px;"></uni-icons>
          <text>确认授权登录</text>
        </button>
        <text class="cancel-text" @click="handleCancel">取消登录</text>
      </view>

      <view class="agreement-row flex-row items-center justify-center" @click="toggleAgree">
        <view class="checkbox" :class="{ 'is-checked': isAgreed }">
          <uni-icons v-if="isAgreed" type="checkmarkempty" size="14" color="#8B5CF6"></uni-icons>
        </view>
        <view class="agreement-text flex-row">
          <text class="text">我已阅读并同意</text>
          <text class="link" @click.stop="goToAgreement('user')">《用户协议》</text>
          <text class="link" @click.stop="goToAgreement('privacy')">《隐私政策》</text>
        </view>
      </view>

      <view class="footer-note flex-row items-center justify-center">
        <uni-icons type="checkmarkempty" size="12" color="#A78BFA"></uni-icons>
        <text class="note-text">授权后可同步打卡记录与习惯数据</text>
      </view>
    </view>
    
    <!-- Background Waves (CSS) -->
    <view class="bg-waves"></view>
  </view>
</template>

<script setup>
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { ref } from 'vue';
import { useUserStore } from '@/store/user';
import { useHabitStore } from '@/store/habit';
import { cloud } from '@/utils/cloud';

const userStore = useUserStore();

const isAgreed = ref(false);
const avatarUrl = ref('');
const nickName = ref('');

const toggleAgree = () => {
  isAgreed.value = !isAgreed.value;
};

const goToAgreement = (type) => {
  uni.navigateTo({ url: `/pages/agreement/agreement?type=${type}` });
};

const onChooseAvatar = (e) => {
  avatarUrl.value = e.detail.avatarUrl;
};

const onNicknameInput = (e) => {
  nickName.value = e.detail.value;
};

const handleLogin = async () => {
  if (!isAgreed.value) {
    uni.showToast({ title: '请先同意用户协议', icon: 'none' });
    return;
  }
  if (!avatarUrl.value || !nickName.value) {
    uni.showToast({ title: '请完善头像和昵称', icon: 'none' });
    return;
  }
  
  uni.showLoading({ title: '登录中...' });
  
  try {
    // 1. 获取登录 code
    const loginRes = await new Promise((resolve, reject) => {
      uni.login({
        provider: 'weixin',
        success: resolve,
        fail: reject
      });
    });

    // 2. 获取 OpenID
    const { result } = await cloud.callFunction({ 
      name: 'user-center',
      data: { action: 'login', code: loginRes.code }
    });
    
    if (result.code !== 0) {
      throw new Error(result.msg || '获取 openid 失败');
    }
    const openid = result.openid;
    userStore.setOpenid(openid);

    // 3. 上传头像到 uniCloud
    let fileID = avatarUrl.value;
    if (avatarUrl.value && !avatarUrl.value.startsWith('http') && !avatarUrl.value.startsWith('cloud://')) {
      try {
        // 压缩图片
        const compressedPath = await new Promise((resolve) => {
          uni.compressImage({
            src: avatarUrl.value,
            quality: 60,
            success: (res) => resolve(res.tempFilePath),
            fail: () => resolve(avatarUrl.value) // fallback to original
          });
        });

        const cloudPath = `avatars/${openid}-${Date.now()}.jpg`;
        const uploadRes = await cloud.uploadFile({
          cloudPath: cloudPath,
          filePath: compressedPath,
        });
        fileID = uploadRes.fileID;
      } catch (uploadErr) {
        console.warn('头像上传失败，使用原图', uploadErr);
      }
    }

    // 4. 更新全局状态
    const newUserInfo = {
      avatarUrl: fileID,
      nickName: nickName.value
    };
    userStore.setUserInfo(newUserInfo);
    userStore.saveToStorage();

    // 将用户信息同步存入云数据库
    cloud.callFunction({
      name: 'user-center',
      data: {
        action: 'syncUserInfo',
        openid: openid,
        userInfo: newUserInfo
      }
    }).catch(err => console.error('同步用户信息失败', err));

    // 5. 初始化用户习惯数据
    const habitStore = useHabitStore();
    await habitStore.initFromCloud(openid);

    uni.hideLoading();
    uni.showToast({ title: '登录成功', icon: 'success' });
    setTimeout(() => {
      uni.switchTab({ url: '/pages/index/index' });
    }, 1000);

  } catch (err) {
    console.error('Login error', err);
    uni.hideLoading();
    uni.showToast({ title: '登录失败: ' + (err.message || '未知错误'), icon: 'none' });
  }
};

const handleCancel = () => {
  uni.exitMiniProgram({
    success: () => console.log('退出小程序成功')
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
.login-container {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(180deg, #FAFAFF 0%, #F5EEFF 50%, #EADDFF 100%);
  position: relative;
  overflow: hidden;
  padding-top: 20vh;
}

.header {
  z-index: 10;
  margin-bottom: 20px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  
  .logo-row {
    margin-bottom: 12px;
    
    .logo-icon {
      width: 48px;
      height: 48px;
      background: white;
      border-radius: 14px;
      box-shadow: 0 4px 12px rgba(124, 58, 237, 0.15);
      margin-right: 12px;
    }
    
    .app-name {
      font-size: 28px;
      font-weight: 800;
      color: #6D28D9;
      letter-spacing: 2px;
    }
  }
  
  .subtitle-row {
    .dot {
      color: #A78BFA;
      margin: 0 8px;
      font-size: 18px;
    }
    .subtitle {
      font-size: 15px;
      color: #8B5CF6;
      font-weight: 500;
      letter-spacing: 1px;
    }
  }
}

.illustration-container {
  width: 100%;
  height: 35vh;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  
  .illustration-img {
    width: 90%;
    height: 100%;
  }
}

.bottom-section {
  position: absolute;
  bottom: 0;
  width: 100%;
  padding: 0 24px;
  padding-bottom: calc(30px + env(safe-area-inset-bottom));
  z-index: 10;
}

.profile-form {
  margin-bottom: 30px;
  
  .avatar-wrapper {
    width: 72px;
    height: 72px;
    padding: 0;
    margin: 0;
    border-radius: 50%;
    background: #f3f4f6;
    position: relative;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 2px solid white;
    
    &::after { display: none; }
    
    .avatar-img {
      width: 100%;
      height: 100%;
      border-radius: 50%;
    }
    
    .avatar-edit-badge {
      position: absolute;
      bottom: 0;
      right: 0;
      width: 24px;
      height: 24px;
      background: #8B5CF6;
      border-radius: 50%;
      border: 2px solid white;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
  
  .nickname-wrapper {
    margin-top: 16px;
    width: 60%;
    background: rgba(255,255,255,0.8);
    border-radius: 100px;
    padding: 8px 16px;
    border: 1px solid rgba(139, 92, 246, 0.2);
    
    .nickname-input {
      width: 100%;
      text-align: center;
      font-size: 16px;
      color: #4C1D95;
      font-weight: 500;
    }
  }
}

.w-full {
  width: 100%;
}

.btn-group {
  margin-bottom: 24px;
  
  .wechat-btn {
    width: 100%;
    height: 56px;
    background: linear-gradient(90deg, #A78BFA 0%, #7C3AED 100%);
    color: white;
    border-radius: 100px;
    font-size: 18px;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    border: none;
    box-shadow: 0 8px 24px rgba(124, 58, 237, 0.4);
    
    &::after {
      display: none;
    }
    
    &:active {
      transform: scale(0.98);
      opacity: 0.9;
    }
  }
  
  .cancel-text {
    margin-top: 16px;
    font-size: 14px;
    color: #8B5CF6;
    opacity: 0.8;
    padding: 8px;
    
    &:active {
      opacity: 0.5;
    }
  }
}

.agreement-row {
  margin-bottom: 16px;
  
  .checkbox {
    width: 16px;
    height: 16px;
    border-radius: 50%;
    border: 1px solid #C4B5FD;
    margin-right: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    transition: all 0.2s;
    
    &.is-checked {
      border-color: #8B5CF6;
      background: rgba(139, 92, 246, 0.1);
    }
  }
  
  .agreement-text {
    font-size: 12px;
    
    .text {
      color: #8B5CF6;
    }
    .link {
      color: #6D28D9;
      font-weight: 600;
    }
  }
}

.footer-note {
  opacity: 0.8;
  
  .note-text {
    font-size: 12px;
    color: #8B5CF6;
    margin-left: 4px;
  }
}

.bg-waves {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 30vh;
  background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 320" xmlns="http://www.w3.org/2000/svg"><path fill="%23D8B4FE" fill-opacity="0.3" d="M0,160L48,170.7C96,181,192,203,288,197.3C384,192,480,160,576,160C672,160,768,192,864,208C960,224,1056,224,1152,208C1248,192,1344,160,1392,144L1440,128L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path><path fill="%23C084FC" fill-opacity="0.2" d="M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,213.3C672,224,768,224,864,208C960,192,1056,160,1152,149.3C1248,139,1344,149,1392,154.7L1440,160L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom;
  background-size: cover;
  z-index: 1;
}
</style>

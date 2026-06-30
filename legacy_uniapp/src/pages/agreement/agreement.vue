<template>
  <view class="agreement-container">
    <view class="header">
      <text class="title">{{ title }}</text>
    </view>
    <scroll-view scroll-y class="content-scroll">
      <view class="content">
        <template v-if="type === 'privacy'">
          <view class="section">
            <text class="p">欢迎使用小习惯打卡！我们非常重视您的隐私保护和个人信息安全。本说明将详细解释我们如何收集、使用和存储您的个人信息。</text>
          </view>
          
          <view class="section">
            <text class="h2">1. 我们如何收集和使用您的信息</text>
            <text class="p">当您使用“微信授权登录”时，我们会请求获取以下信息：</text>
            <view class="list">
              <text class="li">• 微信头像：仅用于在小程序的“我的”页面和您的专属打卡海报中展示您的个性化形象。</text>
              <text class="li">• 微信昵称：仅用于在小程序内部对您的称呼展示，让您的打卡体验更加亲切和专属。</text>
              <text class="li">• OpenID（系统静默获取）：用于作为您在系统中的唯一身份标识，确保您的习惯数据和心情记录能在不同设备上精准同步，不会丢失。</text>
            </view>
            <text class="p highlight">郑重承诺：我们收集的头像和昵称等信息，绝不用于任何与本小程序基础服务无关的商业营销，绝不与任何第三方共享。</text>
          </view>
          
          <view class="section">
            <text class="h2">2. 信息存储与安全</text>
            <text class="p">您的个人信息和打卡数据均安全加密存储于微信官方提供的云开发（CloudBase）数据库中，享有微信原生级别的最高安全防护，防止信息泄露、损坏或丢失。</text>
          </view>
          
          <view class="section">
            <text class="h2">3. 您的权利</text>
            <text class="p">您有权随时修改您在小程序内展示的头像和昵称。如果您希望注销账号并删除所有打卡记录与个人信息，可通过“我的”页面的“建议与反馈”联系我们进行注销操作。</text>
          </view>
        </template>
        
        <template v-else>
          <view class="section">
            <text class="p">欢迎您使用小习惯打卡小程序！在您使用本服务前，请仔细阅读以下协议：</text>
          </view>
          
          <view class="section">
            <text class="h2">1. 服务说明</text>
            <text class="p">小习惯打卡是一款致力于帮助用户养成良好习惯、记录日常心情的工具型产品。我们通过提供目标设定、每日打卡、数据统计等功能，助力您的个人成长。</text>
          </view>
          
          <view class="section">
            <text class="h2">2. 用户行为规范</text>
            <view class="list">
              <text class="li">• 您在使用本小程序记录心情、填写习惯名称等文本信息时，须遵守国家法律法规，不得发布违法、违规或不良信息。</text>
              <text class="li">• 您应妥善保管自己的微信账号，通过该账号在小程序内的所有操作均视为您本人的行为。</text>
            </view>
          </view>
          
          <view class="section">
            <text class="h2">3. 数据声明</text>
            <text class="p">我们将竭尽全力保障您的数据安全与稳定，但对于因不可抗力（如微信服务器故障、网络中断）导致的偶然数据同步延迟，敬请谅解。</text>
          </view>
        </template>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue';
import { onLoad, onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';

const type = ref('privacy');

const title = computed(() => {
  return type.value === 'privacy' ? '隐私政策及信息获取说明' : '用户服务协议';
});

onLoad((options) => {
  if (options.type) {
    type.value = options.type;
  }
});

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
.agreement-container {
  width: 100vw;
  height: 100vh;
  background: #FAFAFF;
  display: flex;
  flex-direction: column;
}

.header {
  padding: 24px 20px 16px;
  background: #ffffff;
  border-bottom: 1px solid #F3F4F6;
  
  .title {
    font-size: 20px;
    font-weight: 700;
    color: #4C1D95;
  }
}

.content-scroll {
  flex: 1;
  height: 0;
}

.content {
  padding: 24px;
}

.section {
  margin-bottom: 32px;
  
  .h2 {
    display: block;
    font-size: 16px;
    font-weight: 600;
    color: #5B21B6;
    margin-bottom: 12px;
  }
  
  .p {
    display: block;
    font-size: 14px;
    color: #4B5563;
    line-height: 1.6;
    margin-bottom: 8px;
  }
  
  .highlight {
    color: #8B5CF6;
    font-weight: 500;
    background: rgba(139, 92, 246, 0.05);
    padding: 12px;
    border-radius: 8px;
    margin-top: 12px;
  }
  
  .list {
    margin-top: 8px;
    
    .li {
      display: block;
      font-size: 14px;
      color: #4B5563;
      line-height: 1.6;
      margin-bottom: 6px;
      padding-left: 8px;
    }
  }
}
</style>

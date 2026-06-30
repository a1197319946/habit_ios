<script>
import { useUserStore } from '@/store/user';
import { useHabitStore } from '@/store/habit';

export default {
  onLaunch: async function () {
    console.log('App Launch');
    
    // 初始化数据
    const userStore = useUserStore();
    const habitStore = useHabitStore();
    
    // 初始化本地的 userInfo
    await userStore.initFromStorage();
    
    // 静默登录或生成本地 ID
    await userStore.silentLogin();
    
    // 从 iCloud 合并数据 (如果有)
    await habitStore.mergeFromiCloud();
  },
  onShow: function () {
    console.log('App Show');
    const habitStore = useHabitStore();
    habitStore.mergeFromiCloud();
  },
  onHide: function () {
    console.log('App Hide')
  },
}
</script>

<style lang="scss">
/* 全局样式和 CSS 变量 */
page, ::before, ::after {
  /* 高级感调色板 - 参考高级 UI 设计规范 */
  --primary: #4F46E5; /* 靛蓝色 Indigo 600 */
  --primary-light: #818CF8; /* Indigo 400 */
  --primary-bg: #EEF2FF; /* Indigo 50 */
  
  --surface: #FFFFFF;
  --background: #F8FAFC; /* Slate 50 */
  
  --text-main: #0F172A; /* Slate 900 */
  --text-regular: #334155; /* Slate 700 */
  --text-muted: #64748B; /* Slate 500 */
  --text-light: #94A3B8; /* Slate 400 */
  
  --border-light: #F1F5F9; /* Slate 100 */
  --border-color: #E2E8F0; /* Slate 200 */
  
  --error: #EF4444; /* Red 500 */
  --success: #10B981; /* Emerald 500 */
  --warning: #F59E0B; /* Amber 500 */
  
  /* 圆角 */
  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-xl: 32px;
  
  /* 阴影 */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.02);
  --shadow-float: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 10px 10px -5px rgba(0, 0, 0, 0.02);
  
  /* 字体设置 */
  --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

page {
  background-color: var(--background);
  color: var(--text-main);
  font-family: var(--font-family);
  font-size: 14px;
  line-height: 1.5;
  box-sizing: border-box;
}

view, text, image, scroll-view, button {
  box-sizing: border-box;
}

/* 隐藏滚动条 */
::-webkit-scrollbar {
  display: none;
  width: 0;
  height: 0;
  color: transparent;
}

/* 常用工具类 */
.flex-row {
  display: flex;
  flex-direction: row;
}

.flex-col {
  display: flex;
  flex-direction: column;
}

.items-center {
  align-items: center;
}

.justify-center {
  justify-content: center;
}

.justify-between {
  justify-content: space-between;
}

.text-ellipsis {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}
</style>

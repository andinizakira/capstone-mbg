<template>
  <div class="layout">
    <!-- Slim Sidebar -->
    <aside class="sidebar" :class="{ expanded: sidebarExpanded }">
      <!-- Logo -->
      <div class="sidebar-logo">
        <div class="logo-mark">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5z"/>
            <path d="M2 17l10 5 10-5"/>
            <path d="M2 12l10 5 10-5"/>
          </svg>
        </div>
        <span class="logo-text" v-if="sidebarExpanded">MBG</span>
      </div>

      <!-- Toggle Button -->
      <button class="sidebar-toggle" @click="sidebarExpanded = !sidebarExpanded">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="3" y1="12" x2="21" y2="12"/>
          <line x1="3" y1="6" x2="21" y2="6"/>
          <line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
      </button>

      <!-- Navigation -->
      <nav class="sidebar-nav">
        <router-link to="/" class="nav-item" exact-active-class="active" :title="!sidebarExpanded ? 'Dashboard' : ''">
          <div class="nav-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="7" rx="1"/>
              <rect x="14" y="3" width="7" height="7" rx="1"/>
              <rect x="3" y="14" width="7" height="7" rx="1"/>
              <rect x="14" y="14" width="7" height="7" rx="1"/>
            </svg>
          </div>
          <span class="nav-label" v-if="sidebarExpanded">Dashboard</span>
        </router-link>

        <router-link to="/data-bahan-baku" class="nav-item" exact-active-class="active" :title="!sidebarExpanded ? 'Bahan Baku' : ''">
          <div class="nav-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
              <line x1="12" y1="22.08" x2="12" y2="12"/>
            </svg>
          </div>
          <span class="nav-label" v-if="sidebarExpanded">Bahan Baku</span>
        </router-link>

        <router-link to="/data-menu" class="nav-item" exact-active-class="active" :title="!sidebarExpanded ? 'Data Menu' : ''">
          <div class="nav-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
          </div>
          <span class="nav-label" v-if="sidebarExpanded">Data Menu</span>
        </router-link>

        <router-link to="/monitoring" class="nav-item" exact-active-class="active" :title="!sidebarExpanded ? 'Monitoring' : ''">
          <div class="nav-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
          </div>
          <span class="nav-label" v-if="sidebarExpanded">Monitoring</span>
        </router-link>
      </nav>

      <!-- Footer -->
      <div class="sidebar-footer">
        <button @click="handleLogout" class="nav-item logout-btn" :title="!sidebarExpanded ? 'Logout' : ''">
          <div class="nav-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
          </div>
          <span class="nav-label" v-if="sidebarExpanded">Logout</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="main-area">
      <!-- Top Bar -->
      <header class="topbar">
        <div class="topbar-left">
          <h1 class="page-title-main">{{ currentPageTitle }}</h1>
        </div>
        <div class="topbar-right">
          <div class="topbar-search">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"/>
              <line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
          </div>
          <div class="topbar-notification">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
              <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
            <span class="notification-dot"></span>
          </div>
          <div class="topbar-avatar">
            <div class="avatar-circle">
              {{ userInitial }}
            </div>
            <span class="avatar-name">{{ authStore.user?.nama || 'Admin' }}</span>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <div class="content-wrapper">
        <router-view></router-view>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter, useRoute } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();
const route = useRoute();
const sidebarExpanded = ref(false);

const userInitial = computed(() => {
  const nama = authStore.user?.nama || 'A';
  return nama.charAt(0).toUpperCase();
});

const currentPageTitle = computed(() => {
  const titles = {
    'Dashboard': 'Dashboard',
    'DataMenu': 'Data Menu',
    'DataBahanBaku': 'Data Bahan Baku',
    'Monitoring': 'Monitoring MBG',
  };
  return titles[route.name] || 'Dashboard';
});

const handleLogout = () => {
  authStore.logout();
  router.push('/login');
};
</script>

<style scoped>
/* ═══ Layout ═════════════════════════════════════════════════════ */
.layout {
  display: flex;
  min-height: 100vh;
  background: var(--bg-primary);
}

/* ═══ Sidebar ════════════════════════════════════════════════════ */
.sidebar {
  width: 72px;
  background: var(--bg-sidebar);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  z-index: 100;
  transition: width var(--transition-normal);
  overflow: hidden;
}

.sidebar.expanded {
  width: 220px;
}

/* Logo */
.sidebar-logo {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 0 16px;
  border-bottom: 1px solid var(--border-color);
  flex-shrink: 0;
}

.logo-mark {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, var(--accent-green), #22c55e);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #0b0e1a;
  flex-shrink: 0;
  box-shadow: var(--shadow-glow-green);
}

.logo-text {
  font-size: 18px;
  font-weight: 800;
  color: var(--text-heading);
  letter-spacing: 1px;
  white-space: nowrap;
}

/* Toggle */
.sidebar-toggle {
  width: 100%;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  transition: color var(--transition-fast);
  flex-shrink: 0;
}

.sidebar-toggle:hover {
  color: var(--accent-green);
}

/* Navigation */
.sidebar-nav {
  flex: 1;
  padding: 8px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: var(--radius-md);
  color: var(--text-muted);
  transition: all var(--transition-fast);
  cursor: pointer;
  white-space: nowrap;
  border: none;
  background: transparent;
  font-family: var(--font-sans);
  font-size: 14px;
  width: 100%;
  text-align: left;
}

.nav-item:hover {
  color: var(--text-primary);
  background: rgba(255, 255, 255, 0.04);
}

.nav-item.active {
  color: var(--accent-green);
  background: var(--accent-green-dim);
}

.nav-item.active .nav-icon {
  color: var(--accent-green);
}

.nav-icon {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.nav-label {
  font-weight: 500;
  font-size: 13px;
}

/* Footer */
.sidebar-footer {
  padding: 12px;
  border-top: 1px solid var(--border-color);
  flex-shrink: 0;
}

.logout-btn:hover {
  color: var(--accent-red) !important;
  background: var(--accent-red-dim) !important;
}

/* ═══ Main Area ══════════════════════════════════════════════════ */
.main-area {
  flex: 1;
  margin-left: 72px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  transition: margin-left var(--transition-normal);
}

.sidebar.expanded ~ .main-area {
  margin-left: 220px;
}

/* ═══ Top Bar ════════════════════════════════════════════════════ */
.topbar {
  height: 64px;
  background: var(--bg-topbar);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 28px;
  flex-shrink: 0;
  position: sticky;
  top: 0;
  z-index: 50;
  backdrop-filter: blur(12px);
}

.topbar-left {
  display: flex;
  align-items: center;
}

.page-title-main {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-heading);
  letter-spacing: -0.2px;
}

.topbar-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.topbar-search,
.topbar-notification {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--transition-fast);
  position: relative;
}

.topbar-search:hover,
.topbar-notification:hover {
  background: var(--bg-card-hover);
  color: var(--text-primary);
  border-color: rgba(255, 255, 255, 0.1);
}

.notification-dot {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 7px;
  height: 7px;
  background: var(--accent-pink);
  border-radius: 50%;
  border: 1.5px solid var(--bg-topbar);
}

.topbar-avatar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px 12px 4px 4px;
  border-radius: 50px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
}

.avatar-circle {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent-green), var(--accent-teal));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 700;
  color: #0b0e1a;
}

.avatar-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
}

/* ═══ Content ════════════════════════════════════════════════════ */
.content-wrapper {
  flex: 1;
  padding: 24px 28px;
  overflow-y: auto;
}
</style>

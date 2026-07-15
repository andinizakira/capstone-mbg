<template>
  <div class="dashboard">
    <!-- Welcome Banner -->
    <div class="welcome-banner">
      <div class="welcome-content">
        <p class="welcome-sub">Selamat datang,</p>
        <h1 class="welcome-title">{{ authStore.user?.nama || 'Administrator' }} 👋</h1>
        <p class="welcome-desc">Pantau dan kelola data menu MBG dari dashboard ini.</p>
      </div>
      <div class="welcome-chart">
        <svg viewBox="0 0 200 60" class="sparkline">
          <defs>
            <linearGradient id="sparkGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#4ade80" stop-opacity="0.3"/>
              <stop offset="100%" stop-color="#4ade80" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <path d="M0,45 Q20,40 40,35 T80,25 T120,30 T160,15 T200,20" fill="none" stroke="#4ade80" stroke-width="2"/>
          <path d="M0,45 Q20,40 40,35 T80,25 T120,30 T160,15 T200,20 L200,60 L0,60Z" fill="url(#sparkGrad)"/>
        </svg>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
      <div class="stat-card" v-for="stat in stats" :key="stat.label">
        <div class="stat-icon-wrap" :style="{ background: stat.dimColor }">
          <div class="stat-icon" :style="{ color: stat.color }" v-html="stat.icon"></div>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-label">{{ stat.label }}</span>
        </div>
        <div class="stat-trend" :class="stat.trendUp ? 'up' : 'down'">
          <svg v-if="stat.trendUp" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg>
          <svg v-else width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/></svg>
          <span>{{ stat.trend }}</span>
        </div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="charts-row">
      <!-- Performance Chart -->
      <div class="chart-card chart-large">
        <div class="chart-header">
          <div>
            <span class="chart-title">Performa Rekomendasi</span>
            <span class="chart-sub">Rekomendasi menu per bulan</span>
          </div>
          <div class="chart-tabs">
            <button class="chart-tab active">Mingguan</button>
            <button class="chart-tab">Bulanan</button>
          </div>
        </div>
        <div class="chart-body">
          <svg viewBox="0 0 600 180" class="area-chart">
            <defs>
              <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#4ade80" stop-opacity="0.2"/>
                <stop offset="100%" stop-color="#4ade80" stop-opacity="0"/>
              </linearGradient>
            </defs>
            <!-- Grid lines -->
            <line v-for="i in 5" :key="'g'+i" :x1="0" :y1="i*36" :x2="600" :y2="i*36" stroke="rgba(255,255,255,0.03)" stroke-width="1"/>
            <!-- Area fill -->
            <path d="M0,140 C50,130 80,100 120,90 S180,110 220,80 S280,50 320,60 S380,40 420,30 S480,50 540,25 L600,35 L600,180 L0,180Z" fill="url(#areaGrad)"/>
            <!-- Line -->
            <path d="M0,140 C50,130 80,100 120,90 S180,110 220,80 S280,50 320,60 S380,40 420,30 S480,50 540,25 L600,35" fill="none" stroke="#4ade80" stroke-width="2.5" stroke-linecap="round"/>
            <!-- Dots -->
            <circle cx="120" cy="90" r="4" fill="#4ade80"/>
            <circle cx="220" cy="80" r="4" fill="#4ade80"/>
            <circle cx="320" cy="60" r="4" fill="#4ade80"/>
            <circle cx="420" cy="30" r="4" fill="#4ade80"/>
            <circle cx="540" cy="25" r="4" fill="#4ade80"/>
          </svg>
          <div class="chart-labels">
            <span>Sen</span><span>Sel</span><span>Rab</span><span>Kam</span><span>Jum</span><span>Sab</span><span>Min</span>
          </div>
        </div>
      </div>

      <!-- Bar Chart -->
      <div class="chart-card chart-small">
        <div class="chart-header">
          <div>
            <span class="chart-title">Status Menu</span>
            <span class="chart-sub">Layak vs Tidak Layak</span>
          </div>
        </div>
        <div class="bar-chart-body">
          <div class="bar-group" v-for="(bar, i) in barData" :key="i">
            <div class="bar-wrapper">
              <div class="bar bar-primary" :style="{ height: bar.layak + '%' }"></div>
              <div class="bar bar-secondary" :style="{ height: bar.tidak + '%' }"></div>
            </div>
            <span class="bar-label">{{ bar.label }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Navigation Cards -->
    <div class="nav-cards-grid">
      <router-link to="/data-bahan-baku" class="nav-card">
        <div class="nav-card-icon" style="background: var(--accent-blue-dim);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent-blue)" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
            <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
            <line x1="12" y1="22.08" x2="12" y2="12"/>
          </svg>
        </div>
        <div class="nav-card-content">
          <h3>Data Bahan Baku</h3>
          <p>Kelola data & takaran bahan baku nutrisi</p>
        </div>
        <div class="nav-card-arrow">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
          </svg>
        </div>
      </router-link>

      <router-link to="/data-menu" class="nav-card">
        <div class="nav-card-icon" style="background: var(--accent-green-dim);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent-green)" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
          </svg>
        </div>
        <div class="nav-card-content">
          <h3>Data Menu</h3>
          <p>Kelola database menu makanan MBG</p>
        </div>
        <div class="nav-card-arrow">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
          </svg>
        </div>
      </router-link>

      <router-link to="/monitoring" class="nav-card">
        <div class="nav-card-icon" style="background: var(--accent-orange-dim);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent-orange)" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
          </svg>
        </div>
        <div class="nav-card-content">
          <h3>Monitoring MBG</h3>
          <p>Pantau riwayat rekomendasi siswa</p>
        </div>
        <div class="nav-card-arrow">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
          </svg>
        </div>
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import api from '../services/api';

const authStore = useAuthStore();

const stats = ref([
  {
    label: 'Total Menu',
    value: '...',
    icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>',
    color: '#4ade80',
    dimColor: 'rgba(74, 222, 128, 0.12)',
    trend: '+12%',
    trendUp: true,
  },
  {
    label: 'Bahan Baku',
    value: '...',
    icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>',
    color: '#60a5fa',
    dimColor: 'rgba(96, 165, 250, 0.12)',
    trend: '+8%',
    trendUp: true,
  },
  {
    label: 'Rekomendasi Hari Ini',
    value: '...',
    icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>',
    color: '#a78bfa',
    dimColor: 'rgba(167, 139, 250, 0.12)',
    trend: '+25%',
    trendUp: true,
  },
  {
    label: 'Menu Layak',
    value: '...',
    icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>',
    color: '#f472b6',
    dimColor: 'rgba(244, 114, 182, 0.12)',
    trend: '95%',
    trendUp: true,
  },
]);

const barData = ref([
  { label: 'Sen', layak: 75, tidak: 25 },
  { label: 'Sel', layak: 85, tidak: 15 },
  { label: 'Rab', layak: 60, tidak: 40 },
  { label: 'Kam', layak: 90, tidak: 10 },
  { label: 'Jum', layak: 70, tidak: 30 },
  { label: 'Sab', layak: 80, tidak: 20 },
]);

onMounted(async () => {
  try {
    const [menuRes, bbRes] = await Promise.all([
      api.get('/admin/menu').catch(() => null),
      api.get('/admin/bahan-baku').catch(() => null),
    ]);
    if (menuRes?.data?.data) stats.value[0].value = menuRes.data.data.length;
    if (bbRes?.data?.data) stats.value[1].value = bbRes.data.data.length;
    // Placeholder values for demo
    stats.value[2].value = Math.floor(Math.random() * 50 + 10);
    stats.value[3].value = '95%';
  } catch {
    // silently ignore
  }
});
</script>

<style scoped>
.dashboard {
  animation: fadeInUp 0.4s ease;
}

/* ═══ Welcome Banner ═════════════════════════════════════════════ */
.welcome-banner {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-xl);
  padding: 28px 32px;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  overflow: hidden;
}

.welcome-banner::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -10%;
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, rgba(74, 222, 128, 0.08) 0%, transparent 70%);
  pointer-events: none;
}

.welcome-sub {
  font-size: 13px;
  color: var(--text-muted);
  margin-bottom: 4px;
}

.welcome-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-heading);
  margin-bottom: 6px;
}

.welcome-desc {
  font-size: 14px;
  color: var(--text-secondary);
}

.welcome-chart {
  width: 200px;
  flex-shrink: 0;
}

.sparkline {
  width: 100%;
  height: auto;
}

/* ═══ Stats Grid ═════════════════════════════════════════════════ */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  transition: all var(--transition-fast);
}

.stat-card:hover {
  border-color: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

.stat-icon-wrap {
  width: 46px;
  height: 46px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 22px;
  font-weight: 700;
  color: var(--text-heading);
  line-height: 1.1;
}

.stat-label {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 2px;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 3px;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: 20px;
}

.stat-trend.up {
  color: var(--accent-green);
  background: var(--accent-green-dim);
}

.stat-trend.down {
  color: var(--accent-red);
  background: var(--accent-red-dim);
}

/* ═══ Charts ═════════════════════════════════════════════════════ */
.charts-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 16px;
  margin-bottom: 24px;
}

.chart-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.chart-header {
  padding: 20px 24px 16px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
}

.chart-title {
  display: block;
  font-size: 15px;
  font-weight: 600;
  color: var(--text-heading);
}

.chart-sub {
  display: block;
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 2px;
}

.chart-tabs {
  display: flex;
  gap: 4px;
  background: var(--bg-primary);
  border-radius: var(--radius-sm);
  padding: 3px;
}

.chart-tab {
  padding: 5px 12px;
  border: none;
  background: transparent;
  color: var(--text-muted);
  font-size: 12px;
  font-weight: 500;
  border-radius: 4px;
  cursor: pointer;
  font-family: var(--font-sans);
  transition: all var(--transition-fast);
}

.chart-tab.active {
  background: var(--accent-green);
  color: #0b0e1a;
}

.chart-body {
  padding: 0 24px 20px;
}

.area-chart {
  width: 100%;
  height: auto;
}

.chart-labels {
  display: flex;
  justify-content: space-between;
  padding: 12px 0 0;
  font-size: 11px;
  color: var(--text-muted);
}

/* Bar Chart */
.bar-chart-body {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  padding: 0 24px 20px;
  height: 180px;
  gap: 12px;
}

.bar-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.bar-wrapper {
  display: flex;
  gap: 3px;
  align-items: flex-end;
  height: 140px;
}

.bar {
  width: 14px;
  border-radius: 4px 4px 0 0;
  transition: height 0.5s ease;
}

.bar-primary {
  background: linear-gradient(to top, #4ade80, #22c55e);
}

.bar-secondary {
  background: rgba(96, 165, 250, 0.4);
}

.bar-label {
  font-size: 11px;
  color: var(--text-muted);
}

/* ═══ Nav Cards ══════════════════════════════════════════════════ */
.nav-cards-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.nav-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all var(--transition-normal);
  cursor: pointer;
}

.nav-card:hover {
  border-color: rgba(255, 255, 255, 0.1);
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
}

.nav-card-icon {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.nav-card-content {
  flex: 1;
}

.nav-card-content h3 {
  font-size: 15px;
  font-weight: 600;
  color: var(--text-heading);
  margin-bottom: 3px;
}

.nav-card-content p {
  font-size: 12px;
  color: var(--text-muted);
}

.nav-card-arrow {
  color: var(--text-muted);
  transition: all var(--transition-fast);
}

.nav-card:hover .nav-card-arrow {
  color: var(--accent-green);
  transform: translateX(4px);
}

/* ═══ Responsive ═════════════════════════════════════════════════ */
@media (max-width: 1200px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
  .charts-row { grid-template-columns: 1fr; }
}

@media (max-width: 768px) {
  .stats-grid { grid-template-columns: 1fr; }
  .nav-cards-grid { grid-template-columns: 1fr; }
  .welcome-chart { display: none; }
}
</style>

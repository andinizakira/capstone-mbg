<template>
  <div class="page-wrapper">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <div class="header-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
          </svg>
        </div>
        <div>
          <h1 class="page-title">Monitoring MBG</h1>
          <p class="page-subtitle">Pantau riwayat rekomendasi siswa</p>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-bar">
      <div class="filter-input-wrap">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input type="text" v-model="searchName" placeholder="Cari nama siswa..." @input="fetchMonitoring" />
      </div>
      <div class="filter-input-wrap date">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
        <input type="date" v-model="filterDate" @change="fetchMonitoring" />
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="state-container">
      <div class="loading-spinner"></div>
      <span>Memuat data monitoring...</span>
    </div>

    <!-- Empty -->
    <div v-else-if="riwayatList.length === 0" class="state-container">
      <span class="empty-icon">📊</span>
      <span>Tidak ada data monitoring</span>
    </div>

    <!-- Cards Grid -->
    <div v-else class="monitor-grid">
      <div class="monitor-card" v-for="(item, index) in riwayatList" :key="item.id">
        <div class="monitor-card-header">
          <div class="monitor-avatar">
            <span>{{ getInitial(item.nama_siswa) }}</span>
          </div>
          <div class="monitor-info">
            <h3>{{ item.nama_siswa }}</h3>
            <span class="monitor-meta">Umur {{ item.umur }} tahun</span>
          </div>
          <span :class="['status-badge', item.status === 'Layak' ? 'valid' : 'invalid']">
            {{ item.status === 'Layak' ? 'Layak' : 'Tidak Layak' }}
          </span>
        </div>
        <div class="monitor-card-body">
          <div class="monitor-detail">
            <span class="detail-label">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              Waktu Makan
            </span>
            <span class="detail-value">{{ item.jam_makan || '-' }}</span>
          </div>
          <div class="monitor-detail">
            <span class="detail-label">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
              Menu
            </span>
            <span class="detail-value">{{ item.nama_menu }}{{ item.dessert ? ', ' + item.dessert : '' }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';

const riwayatList = ref([]);
const loading = ref(true);
const searchName = ref('');
const filterDate = ref('');

const getInitial = (name) => {
  if (!name) return '?';
  return name.charAt(0).toUpperCase();
};

const fetchMonitoring = async () => {
  loading.value = true;
  try {
    let params = {};
    if (searchName.value) params.nama = searchName.value;
    if (filterDate.value) params.tanggal = filterDate.value;

    const res = await api.get('/admin/monitoring', { params });
    riwayatList.value = res.data.data;
  } catch (err) {
    alert('Gagal mengambil data monitoring');
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchMonitoring();
});
</script>

<style scoped>
.page-wrapper {
  animation: fadeInUp 0.4s ease;
}

/* ═══ Page Header ════════════════════════════════════════════════ */
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 14px;
}

.header-icon {
  width: 48px;
  height: 48px;
  background: var(--accent-orange-dim);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--accent-orange);
}

.page-title {
  font-size: 20px;
  font-weight: 700;
  color: var(--text-heading);
  margin: 0;
}

.page-subtitle {
  font-size: 13px;
  color: var(--text-muted);
  margin: 2px 0 0;
}

/* ═══ Filters ════════════════════════════════════════════════════ */
.filters-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.filter-input-wrap {
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 0 14px;
  color: var(--text-muted);
  transition: all var(--transition-fast);
}

.filter-input-wrap:focus-within {
  border-color: var(--accent-green);
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1);
}

.filter-input-wrap input {
  padding: 10px 0;
  background: transparent;
  border: none;
  outline: none;
  font-size: 13px;
  color: var(--text-primary);
  font-family: var(--font-sans);
  min-width: 200px;
}

.filter-input-wrap input::placeholder {
  color: var(--text-muted);
}

.filter-input-wrap.date input {
  min-width: 140px;
}

/* Fix date input color in dark theme */
.filter-input-wrap input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(0.7);
}

/* ═══ State ══════════════════════════════════════════════════════ */
.state-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 60px 20px;
  color: var(--text-muted);
  font-size: 14px;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--border-color);
  border-top-color: var(--accent-green);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

.empty-icon {
  font-size: 40px;
}

/* ═══ Monitor Grid ═══════════════════════════════════════════════ */
.monitor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 16px;
}

.monitor-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 20px;
  transition: all var(--transition-fast);
}

.monitor-card:hover {
  border-color: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

.monitor-card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border-color);
}

.monitor-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent-purple), var(--accent-blue));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 15px;
  font-weight: 700;
  color: white;
  flex-shrink: 0;
}

.monitor-info {
  flex: 1;
}

.monitor-info h3 {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-heading);
  margin: 0;
}

.monitor-meta {
  font-size: 12px;
  color: var(--text-muted);
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
  flex-shrink: 0;
}

.status-badge.valid {
  background: var(--accent-green-dim);
  color: var(--accent-green);
}

.status-badge.invalid {
  background: var(--accent-red-dim);
  color: var(--accent-red);
}

.monitor-card-body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.monitor-detail {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.detail-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--text-muted);
}

.detail-value {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
}

/* ═══ Responsive ═════════════════════════════════════════════════ */
@media (max-width: 768px) {
  .monitor-grid { grid-template-columns: 1fr; }
  .filters-bar { flex-direction: column; }
}
</style>

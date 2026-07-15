<template>
  <div class="page-wrapper">

    <!-- Page Header -->
    <div class="page-header">
      <div class="header-left">
        <div class="header-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
            <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
            <line x1="12" y1="22.08" x2="12" y2="12"/>
          </svg>
        </div>
        <div>
          <h1 class="page-title">Data Bahan Baku</h1>
          <p class="page-subtitle">Kelola bahan baku nutrisi untuk rekomendasi menu MBG</p>
        </div>
      </div>
      <button class="btn-add" @click="openAddModal">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Tambah Data
      </button>
    </div>

    <!-- Stats Row -->
    <div class="stats-row">
      <div class="stat-chip">
        <span class="stat-chip-dot blue"></span>
        <span class="stat-chip-value">{{ bahanBaku.length }}</span>
        <span class="stat-chip-label">Total Bahan</span>
      </div>
    </div>

    <!-- Table Card -->
    <div class="table-card">
      <div class="table-toolbar">
        <span class="table-title">Daftar Bahan Baku</span>
        <span class="table-badge">{{ bahanBaku.length }} item</span>
      </div>
      <div class="table-scroll">
        <table>
          <thead>
            <tr>
              <th>No</th>
              <th>Nama Bahan</th>
              <th>Takaran</th>
              <th>Karbohidrat</th>
              <th>Protein</th>
              <th>Lemak</th>
              <th>Serat</th>
              <th>Energi</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="9" class="state-cell">
                <div class="loading-spinner"></div>
                <span>Memuat data...</span>
              </td>
            </tr>
            <tr v-else-if="bahanBaku.length === 0">
              <td colspan="9" class="state-cell">
                <span class="empty-icon">🥦</span>
                <span>Belum ada data bahan baku</span>
              </td>
            </tr>
            <tr v-for="(item, index) in bahanBaku" :key="item.id" class="data-row">
              <td><span class="row-num">{{ index + 1 }}</span></td>
              <td><span class="cell-main">{{ item.nama_bahan }}</span></td>
              <td><span class="pill blue">{{ item.takaran || '-' }}</span></td>
              <td>{{ item.karbohidrat != null ? item.karbohidrat + ' g' : '-' }}</td>
              <td>{{ item.protein != null ? item.protein + ' g' : '-' }}</td>
              <td>{{ item.lemak != null ? item.lemak + ' g' : '-' }}</td>
              <td>{{ item.serat != null ? item.serat + ' g' : '-' }}</td>
              <td><span class="pill green">{{ item.energi != null ? item.energi + ' kkal' : '-' }}</span></td>
              <td class="actions-cell">
                <button class="action-btn edit" @click="openEditModal(item)" title="Edit">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                  </svg>
                </button>
                <button class="action-btn delete" @click="deleteBahan(item.id)" title="Hapus">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                  </svg>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <Transition name="modal">
      <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal-box">

          <div class="modal-header">
            <div>
              <h2 class="modal-title">{{ isEdit ? 'Edit Bahan Baku' : 'Tambah Bahan Baku' }}</h2>
              <p class="modal-sub">Isi data nutrisi bahan baku dengan lengkap</p>
            </div>
            <button class="modal-close" @click="closeModal">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>

          <form @submit.prevent="submitForm" class="modal-form">

            <!-- Row 1: Nama + Takaran -->
            <div class="form-section">Informasi Dasar</div>
            <div class="form-grid">
              <div class="form-group full">
                <label>Nama Bahan Baku <span class="req">*</span></label>
                <input type="text" v-model="form.nama_bahan" placeholder="cth: Nasi Putih" required />
              </div>
              <div class="form-group">
                <label>Takaran</label>
                <input type="text" v-model="form.takaran" placeholder="cth: 100g" />
              </div>
              <div class="form-group">
                <label>Nama Baku</label>
                <input type="text" v-model="form.nama_baku" placeholder="cth: Oryza sativa" />
              </div>
            </div>

            <!-- Row 2: Nutrisi -->
            <div class="form-section">
              Kandungan Nutrisi
              <span class="per-tag">per takaran</span>
            </div>
            <div class="form-grid">
              <div class="form-group">
                <label>Energi (kkal)</label>
                <input type="number" step="0.1" min="0" v-model="form.energi" placeholder="0.0" />
              </div>
              <div class="form-group">
                <label>Karbohidrat (g)</label>
                <input type="number" step="0.1" min="0" v-model="form.karbohidrat" placeholder="0.0" />
              </div>
              <div class="form-group">
                <label>Protein (g)</label>
                <input type="number" step="0.1" min="0" v-model="form.protein" placeholder="0.0" />
              </div>
              <div class="form-group">
                <label>Lemak (g)</label>
                <input type="number" step="0.1" min="0" v-model="form.lemak" placeholder="0.0" />
              </div>
              <div class="form-group">
                <label>Serat (g)</label>
                <input type="number" step="0.1" min="0" v-model="form.serat" placeholder="0.0" />
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="closeModal">Batal</button>
              <button type="submit" class="btn-save" :disabled="saving">
                <span v-if="saving" class="spinner-sm"></span>
                {{ saving ? 'Menyimpan...' : (isEdit ? 'Simpan Perubahan' : 'Tambah Data') }}
              </button>
            </div>

          </form>
        </div>
      </div>
    </Transition>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';

const bahanBaku = ref([]);
const loading   = ref(true);
const saving    = ref(false);
const showModal = ref(false);
const isEdit    = ref(false);

const defaultForm = () => ({
  id: null,
  nama_bahan: '',
  takaran: '',
  nama_baku: '',
  energi: '',
  karbohidrat: '',
  protein: '',
  lemak: '',
  serat: '',
});

const form = ref(defaultForm());

const fetchBahanBaku = async () => {
  loading.value = true;
  try {
    const res = await api.get('/admin/bahan-baku');
    bahanBaku.value = res.data.data;
  } catch {
    alert('Gagal mengambil data bahan baku');
  } finally {
    loading.value = false;
  }
};

const openAddModal = () => {
  isEdit.value = false;
  form.value = defaultForm();
  showModal.value = true;
};

const openEditModal = (item) => {
  isEdit.value = true;
  form.value = { ...item };
  showModal.value = true;
};

const closeModal = () => { showModal.value = false; };

const submitForm = async () => {
  saving.value = true;
  try {
    if (isEdit.value) {
      await api.put(`/admin/bahan-baku/${form.value.id}`, form.value);
    } else {
      await api.post('/admin/bahan-baku', form.value);
    }
    closeModal();
    fetchBahanBaku();
  } catch {
    alert('Gagal menyimpan data');
  } finally {
    saving.value = false;
  }
};

const deleteBahan = async (id) => {
  if (!confirm('Yakin ingin menghapus bahan baku ini?')) return;
  try {
    await api.delete(`/admin/bahan-baku/${id}`);
    fetchBahanBaku();
  } catch {
    alert('Gagal menghapus data');
  }
};

onMounted(fetchBahanBaku);
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
  background: var(--accent-blue-dim);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--accent-blue);
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

.btn-add {
  display: flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, var(--accent-green), #22c55e);
  color: #0b0e1a;
  border: none;
  padding: 10px 20px;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  font-family: var(--font-sans);
  box-shadow: 0 4px 15px rgba(74, 222, 128, 0.3);
  transition: all var(--transition-fast);
}

.btn-add:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(74, 222, 128, 0.4);
}

/* ═══ Stats ══════════════════════════════════════════════════════ */
.stats-row {
  margin-bottom: 20px;
}

.stat-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 50px;
  padding: 8px 18px;
}

.stat-chip-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.stat-chip-dot.blue { background: var(--accent-blue); box-shadow: 0 0 6px rgba(96,165,250,0.5); }

.stat-chip-value {
  font-size: 16px;
  font-weight: 700;
  color: var(--text-heading);
}

.stat-chip-label {
  font-size: 12px;
  color: var(--text-muted);
}

/* ═══ Table Card ═════════════════════════════════════════════════ */
.table-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.table-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 18px 24px;
  border-bottom: 1px solid var(--border-color);
}

.table-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-heading);
}

.table-badge {
  background: var(--accent-blue-dim);
  color: var(--accent-blue);
  border-radius: 20px;
  padding: 2px 10px;
  font-size: 11px;
  font-weight: 600;
}

.table-scroll { overflow-x: auto; }

table {
  width: 100%;
  border-collapse: collapse;
}

thead tr {
  background: rgba(255, 255, 255, 0.02);
}

th {
  padding: 12px 18px;
  text-align: left;
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
  border-bottom: 1px solid var(--border-color);
}

td {
  padding: 12px 18px;
  font-size: 13px;
  color: var(--text-secondary);
  border-bottom: 1px solid var(--border-light);
  white-space: nowrap;
}

.data-row {
  transition: background var(--transition-fast);
}

.data-row:hover {
  background: rgba(255, 255, 255, 0.02);
}

.data-row:last-child td {
  border-bottom: none;
}

.row-num {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  background: var(--accent-blue-dim);
  color: var(--accent-blue);
  border-radius: 6px;
  font-size: 11px;
  font-weight: 700;
}

.cell-main {
  font-weight: 600;
  color: var(--text-primary);
}

.pill {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
}

.pill.blue {
  background: var(--accent-blue-dim);
  color: var(--accent-blue);
}

.pill.green {
  background: var(--accent-green-dim);
  color: var(--accent-green);
}

.state-cell {
  text-align: center;
  padding: 48px 20px !important;
  color: var(--text-muted);
  font-size: 14px;
}

.loading-spinner {
  width: 28px;
  height: 28px;
  border: 3px solid var(--border-color);
  border-top-color: var(--accent-green);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto 10px;
}

.empty-icon {
  display: block;
  font-size: 36px;
  margin-bottom: 8px;
}

.actions-cell {
  display: flex;
  gap: 6px;
  align-items: center;
}

.action-btn {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-fast);
}

.action-btn.edit {
  background: var(--accent-blue-dim);
  color: var(--accent-blue);
}

.action-btn.delete {
  background: var(--accent-red-dim);
  color: var(--accent-red);
}

.action-btn:hover {
  transform: scale(1.1);
}

/* ═══ Modal ══════════════════════════════════════════════════════ */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-box {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-xl);
  width: 100%;
  max-width: 640px;
  box-shadow: var(--shadow-lg);
  overflow: hidden;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 28px;
  border-bottom: 1px solid var(--border-color);
}

.modal-title {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-heading);
  margin: 0;
}

.modal-sub {
  font-size: 12px;
  color: var(--text-muted);
  margin: 2px 0 0;
}

.modal-close {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
  background: transparent;
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-fast);
}

.modal-close:hover {
  background: var(--accent-red-dim);
  color: var(--accent-red);
  border-color: transparent;
}

/* ─── Form ────────────────────────────────────────────── */
.modal-form { padding: 24px 28px; }

.form-section {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  color: var(--text-muted);
  margin-bottom: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.per-tag {
  font-size: 10px;
  background: var(--accent-green-dim);
  color: var(--accent-green);
  padding: 2px 8px;
  border-radius: 10px;
  text-transform: none;
  letter-spacing: 0;
  font-weight: 600;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
  margin-bottom: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group.full { grid-column: 1 / -1; }

.form-group label {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-secondary);
}

.req { color: var(--accent-red); }

.form-group input {
  padding: 10px 14px;
  background: var(--bg-input);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  font-size: 14px;
  font-family: var(--font-sans);
  color: var(--text-primary);
  outline: none;
  transition: all var(--transition-fast);
}

.form-group input::placeholder {
  color: var(--text-muted);
}

.form-group input:focus {
  border-color: var(--accent-green);
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn-cancel {
  padding: 10px 20px;
  border: 1px solid var(--border-color);
  background: transparent;
  color: var(--text-secondary);
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  font-family: var(--font-sans);
  transition: all var(--transition-fast);
}

.btn-cancel:hover { background: rgba(255, 255, 255, 0.04); }

.btn-save {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 22px;
  background: linear-gradient(135deg, var(--accent-green), #22c55e);
  color: #0b0e1a;
  border: none;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  font-family: var(--font-sans);
  box-shadow: 0 4px 12px rgba(74, 222, 128, 0.3);
  transition: all var(--transition-fast);
}

.btn-save:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(74, 222, 128, 0.4); }
.btn-save:disabled { opacity: 0.65; cursor: not-allowed; }

.spinner-sm {
  width: 14px; height: 14px;
  border: 2px solid rgba(11, 14, 26, 0.3);
  border-top-color: #0b0e1a;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

/* ═══ Modal Transition ═══════════════════════════════════════════ */
.modal-enter-active, .modal-leave-active {
  transition: all 0.25s ease;
}
.modal-enter-from, .modal-leave-to {
  opacity: 0;
}
.modal-enter-from .modal-box, .modal-leave-to .modal-box {
  transform: scale(0.93) translateY(16px);
}
</style>

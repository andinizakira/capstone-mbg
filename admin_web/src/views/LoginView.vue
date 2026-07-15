<template>
  <div class="login-page">
    <!-- Animated background -->
    <div class="bg-glow glow-1"></div>
    <div class="bg-glow glow-2"></div>
    <div class="bg-glow glow-3"></div>

    <div class="login-card">
      <!-- Logo -->
      <div class="login-logo">
        <div class="logo-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5z"/>
            <path d="M2 17l10 5 10-5"/>
            <path d="M2 12l10 5 10-5"/>
          </svg>
        </div>
      </div>

      <h2 class="login-title">Admin MBG</h2>
      <p class="login-subtitle">Masuk ke dashboard administrasi</p>

      <form @submit.prevent="handleLogin" class="login-form" autocomplete="off">
        <div class="form-group">
          <label>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
              <polyline points="22,6 12,13 2,6"/>
            </svg>
            Email
          </label>
          <input type="email" v-model="email" placeholder="admin@mbg.id" required autocomplete="off" />
        </div>

        <div class="form-group">
          <label>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
              <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
            Password
          </label>
          <input type="password" v-model="password" placeholder="••••••••" required autocomplete="new-password" />
        </div>

        <div v-if="errorMessage" class="error-msg">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
          {{ errorMessage }}
        </div>

        <button type="submit" :disabled="loading" class="btn-login">
          <span v-if="loading" class="spinner"></span>
          <span v-else>Masuk</span>
        </button>
      </form>

      <p class="login-footer">MBG Dashboard &copy; 2026</p>
    </div>
  </div>
</template>

//Proses login admin-------
<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const email = ref('');
const password = ref('');
const errorMessage = ref('');
const loading = ref(false);

const router = useRouter();
const authStore = useAuthStore();

const handleLogin = async () => {
  loading.value = true;
  errorMessage.value = '';
  const result = await authStore.login(email.value, password.value);
  loading.value = false;

  if (result.success) {
    router.push('/');
  } else {
    errorMessage.value = result.message;
  }
};
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-primary);
  position: relative;
  overflow: hidden;
}

/* ═══ Animated Background Glow ═══════════════════════════════════ */
.bg-glow {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
  animation: float 8s ease-in-out infinite;
}

.glow-1 {
  width: 400px;
  height: 400px;
  background: rgba(74, 222, 128, 0.08);
  top: -100px;
  left: -100px;
  animation-delay: 0s;
}

.glow-2 {
  width: 300px;
  height: 300px;
  background: rgba(96, 165, 250, 0.06);
  bottom: -50px;
  right: -50px;
  animation-delay: 3s;
}

.glow-3 {
  width: 200px;
  height: 200px;
  background: rgba(167, 139, 250, 0.05);
  top: 50%;
  left: 50%;
  animation-delay: 5s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -20px) scale(1.05); }
  66% { transform: translate(-20px, 15px) scale(0.95); }
}

/* ═══ Card ═══════════════════════════════════════════════════════ */
.login-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-xl);
  padding: 48px 40px;
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 1;
  box-shadow: var(--shadow-lg);
  animation: fadeInUp 0.5s ease;
}

/* ═══ Logo ═══════════════════════════════════════════════════════ */
.login-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.logo-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, var(--accent-green), #22c55e);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #0b0e1a;
  box-shadow: var(--shadow-glow-green);
}

.login-title {
  text-align: center;
  font-size: 24px;
  font-weight: 700;
  color: var(--text-heading);
  margin-bottom: 6px;
}

.login-subtitle {
  text-align: center;
  font-size: 14px;
  color: var(--text-muted);
  margin-bottom: 36px;
}

/* ═══ Form ═══════════════════════════════════════════════════════ */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  gap: 6px;
}

.form-group input {
  padding: 12px 16px;
  background: var(--bg-input);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  font-size: 14px;
  color: var(--text-primary);
  font-family: var(--font-sans);
  transition: all var(--transition-fast);
  outline: none;
}

.form-group input::placeholder {
  color: var(--text-muted);
}

.form-group input:focus {
  border-color: var(--accent-green);
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1);
}

.error-msg {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--accent-red);
  font-size: 13px;
  padding: 10px 14px;
  background: var(--accent-red-dim);
  border-radius: var(--radius-md);
  border: 1px solid rgba(248, 113, 113, 0.2);
}

.btn-login {
  padding: 14px;
  background: linear-gradient(135deg, var(--accent-green), #22c55e);
  color: #0b0e1a;
  border: none;
  border-radius: var(--radius-md);
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  font-family: var(--font-sans);
  transition: all var(--transition-fast);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 4px;
  box-shadow: 0 4px 15px rgba(74, 222, 128, 0.3);
}

.btn-login:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(74, 222, 128, 0.4);
}

.btn-login:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2.5px solid rgba(11, 14, 26, 0.3);
  border-top-color: #0b0e1a;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

.login-footer {
  text-align: center;
  margin-top: 32px;
  font-size: 12px;
  color: var(--text-muted);
}
</style>

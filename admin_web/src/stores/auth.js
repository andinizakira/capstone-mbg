// src/stores/auth.js
import { defineStore } from 'pinia';
import api from '../services/api';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('admin_token') || null,
    user: JSON.parse(localStorage.getItem('admin_user')) || null
  }),
  getters: {
    isAuthenticated: (state) => !!state.token
  },
  actions: {
    async login(email, password) {
      try {
        const response = await api.post('/auth/login', { email, password });
        if (response.data.status === 'success') {
          const role = response.data.data.user.role;
          if (role !== 'admin') {
            throw new Error('Akses ditolak. Anda bukan admin.');
          }
          this.token = response.data.data.token;
          this.user = response.data.data.user;
          localStorage.setItem('admin_token', this.token);
          localStorage.setItem('admin_user', JSON.stringify(this.user));
          return { success: true };
        }
      } catch (error) {
        return { 
          success: false, 
          message: error.response?.data?.message || error.message || 'Login gagal' 
        };
      }
    },
    logout() {
      this.token = null;
      this.user = null;
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_user');
      window.location.href = '/login';
    }
  }
});

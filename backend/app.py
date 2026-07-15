"""
app.py
======
Flask Application Factory — Sistem Rekomendasi Menu MBG
Port: 5000
"""

import os
from datetime import timedelta
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from database import init_db
from routes.auth           import auth_bp
from routes.rekomendasi    import rekomendasi_bp
from routes.riwayat        import riwayat_bp
from routes.admin_menu     import admin_menu_bp
from routes.admin_bahan_baku import admin_bb_bp
from routes.monitoring     import monitoring_bp


def create_app():
    app = Flask(__name__)

    # ── Konfigurasi JWT ────────────────────────────────────────────────────
    app.config['JWT_SECRET_KEY']        = os.environ.get(
        'JWT_SECRET_KEY', 'mbg-super-secret-key-2024-ganti-di-production')
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=7)

    # ── CORS ───────────────────────────────────────────────────────────────
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    # ── Ekstensi ───────────────────────────────────────────────────────────
    JWTManager(app)

    # ── Daftarkan semua Blueprint ──────────────────────────────────────────
    app.register_blueprint(auth_bp)
    app.register_blueprint(rekomendasi_bp)
    app.register_blueprint(riwayat_bp)
    app.register_blueprint(admin_menu_bp)
    app.register_blueprint(admin_bb_bp)
    app.register_blueprint(monitoring_bp)

    # ── Health Check ───────────────────────────────────────────────────────
    @app.route('/', methods=['GET'])
    def health_check():
        return jsonify({
            'status':  'ok',
            'message': 'MBG Recommendation API is running 🚀',
            'version': '2.0.0',
            'endpoints': {
                'auth':         ['POST /api/auth/register', 'POST /api/auth/login'],
                'siswa':        ['POST /api/rekomendasi', 'GET /api/riwayat'],
                'admin_menu':   ['GET/POST /api/admin/menu',
                                 'PUT/DELETE /api/admin/menu/<id>'],
                'admin_bb':     ['GET/POST /api/admin/bahan-baku',
                                 'PUT/DELETE /api/admin/bahan-baku/<id>'],
                'monitoring':   ['GET /api/admin/monitoring'],
            }
        })

    # ── Error handlers ─────────────────────────────────────────────────────
    @app.errorhandler(404)
    def not_found(_):
        return jsonify({'status': 'error', 'message': 'Endpoint tidak ditemukan'}), 404

    @app.errorhandler(405)
    def method_not_allowed(_):
        return jsonify({'status': 'error', 'message': 'Method tidak diizinkan'}), 405

    return app


# ── Entry Point ────────────────────────────────────────────────────────────
if __name__ == '__main__':
    init_db()   # Buat tabel + seed admin jika belum ada
    app = create_app()
    app.run(host='0.0.0.0', port=5001, debug=True)
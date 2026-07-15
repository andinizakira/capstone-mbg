"""
routes/monitoring.py
====================
GET /api/admin/monitoring — pantau seluruh riwayat rekomendasi siswa.
Mendukung filter by nama siswa dan tanggal.
Hanya bisa diakses role 'admin'.
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from database import get_db
from functools import wraps

monitoring_bp = Blueprint('monitoring', __name__,
                           url_prefix='/api/admin/monitoring')


def admin_required(fn):
    @wraps(fn)
    @jwt_required()
    def wrapper(*args, **kwargs):
        claims = get_jwt()
        if claims.get('role') != 'admin':
            return jsonify({'status': 'error',
                            'message': 'Akses ditolak. Hanya admin.'}), 403
        return fn(*args, **kwargs)
    return wrapper


@monitoring_bp.route('', methods=['GET'])
@admin_required
def monitoring():
    """
    Ambil seluruh riwayat rekomendasi semua siswa.

    Query params (opsional):
      - nama   : filter by nama siswa (partial match, case-insensitive)
      - tanggal: filter by tanggal makan (format: YYYY-MM-DD)
    """
    nama_filter    = request.args.get('nama', '').strip()
    tanggal_filter = request.args.get('tanggal', '').strip()

    # MySQL: DATE_FORMAT menggantikan strftime SQLite
    query = """
        SELECT
            r.id,
            u.nama          AS nama_siswa,
            u.email,
            r.umur,
            r.jenis_kelamin,
            r.nama_menu,
            r.makanan_berat,
            r.dessert,
            r.energi,
            r.status,
            DATE_FORMAT(r.waktu_makan, '%%d %%M %%Y') AS tanggal,
            DATE_FORMAT(r.waktu_makan, '%%H:%%i')     AS jam_makan,
            r.waktu_makan
        FROM riwayat r
        JOIN users u ON r.user_id = u.id
        WHERE 1=1
    """
    params = []

    if nama_filter:
        query  += " AND u.nama LIKE %s"
        params.append(f'%{nama_filter}%')

    if tanggal_filter:
        query  += " AND DATE(r.waktu_makan) = %s"
        params.append(tanggal_filter)

    query += " ORDER BY r.waktu_makan DESC"

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(query, params)
        data = cur.fetchall()

        # Hitung ringkasan
        total_siswa  = len(set(r['nama_siswa'] for r in data))
        total_layak  = sum(1 for r in data if r['status'] == 'Layak')
        total_tidak  = sum(1 for r in data if r['status'] == 'Tidak')

        return jsonify({
            'status': 'success',
            'summary': {
                'total_data':   len(data),
                'total_siswa':  total_siswa,
                'total_layak':  total_layak,
                'total_tidak':  total_tidak,
            },
            'data': data
        }), 200
    finally:
        cur.close()
        conn.close()

"""
routes/riwayat.py
=================
GET /api/riwayat — ambil history rekomendasi siswa yang sedang login.
"""

from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from database import get_db

riwayat_bp = Blueprint('riwayat', __name__, url_prefix='/api')


@riwayat_bp.route('/riwayat', methods=['GET'])
@jwt_required()
def get_riwayat():
    """
    Kembalikan seluruh riwayat rekomendasi milik siswa yang sedang login,
    diurutkan dari yang terbaru.
    """
    claims  = get_jwt()
    user_id = get_jwt_identity()

    if claims.get('role') != 'siswa':
        return jsonify({'status': 'error',
                        'message': 'Hanya siswa yang dapat mengakses endpoint ini'}), 403

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("""
            SELECT id, umur, jenis_kelamin, nama_menu,
                   makanan_berat, dessert, energi, status,
                   DATE_FORMAT(waktu_makan, '%%d %%M %%Y, %%H:%%i') AS tanggal
            FROM riwayat
            WHERE user_id = %s
            ORDER BY waktu_makan DESC
        """, (int(user_id),))

        data = cur.fetchall()
        return jsonify({'status': 'success', 'data': data}), 200
    finally:
        cur.close()
        conn.close()

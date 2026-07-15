"""
routes/rekomendasi.py
======================
POST /api/rekomendasi — jalankan ML dan simpan hasilnya ke riwayat secara otomatis.
Membutuhkan JWT token (siswa).
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from model_engine import proses_rekomendasi, get_akg
from database import get_db

rekomendasi_bp = Blueprint('rekomendasi', __name__, url_prefix='/api')


@rekomendasi_bp.route('/rekomendasi', methods=['POST'])
@jwt_required()
def rekomendasi():
    """
    Proses rekomendasi menu MBG untuk siswa yang sedang login.
    Hasil rekomendasi yang berstatus 'Layak' otomatis disimpan ke tabel riwayat.

    Body: { "umur": int, "jenis_kelamin": str }
    """
    claims  = get_jwt()
    user_id = get_jwt_identity()   # string id dari token

    # Hanya role 'siswa' yang boleh akses endpoint ini
    if claims.get('role') != 'siswa':
        return jsonify({'status': 'error',
                        'message': 'Hanya siswa yang dapat mengakses endpoint ini'}), 403

    if not request.is_json:
        return jsonify({'status': 'error',
                        'message': 'Request harus Content-Type: application/json'}), 400

    body = request.get_json()
    if 'umur' not in body or 'jenis_kelamin' not in body:
        return jsonify({'status': 'error',
                        'message': "Field 'umur' dan 'jenis_kelamin' wajib diisi"}), 400

    try:
        umur = int(body['umur'])
        jk   = str(body['jenis_kelamin']).strip()
    except (ValueError, TypeError):
        return jsonify({'status': 'error',
                        'message': "'umur' harus integer"}), 400

    if umur < 7 or umur > 18:
        return jsonify({'status': 'error',
                        'message': f'Umur {umur} di luar rentang 7–18 tahun'}), 422

    try:
        akg_target       = get_akg(umur, jk)
        rekomendasi_list = proses_rekomendasi(umur, jk)
    except ValueError as e:
        return jsonify({'status': 'error', 'message': str(e)}), 422
    except FileNotFoundError:
        return jsonify({'status': 'error',
                        'message': "File dataset tidak ditemukan"}), 500
    except Exception as e:
        return jsonify({'status': 'error',
                        'message': f'Kesalahan server: {str(e)}'}), 500

    # ── Simpan otomatis ke riwayat (semua menu hasil rekomendasi) ──────────
    conn = get_db()
    cur  = conn.cursor()
    try:
        for item in rekomendasi_list:
            cur.execute("""
                INSERT INTO riwayat
                    (user_id, umur, jenis_kelamin, nama_menu,
                     makanan_berat, dessert, energi, status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                int(user_id),
                umur, jk,
                item['nama_menu'],
                item['makanan_berat'],
                item['dessert'],
                item['energi'],
                item['status'],
            ))
        conn.commit()
    finally:
        cur.close()
        conn.close()

    return jsonify({
        'status': 'success',
        'data': {
            'input':       {'umur': umur, 'jenis_kelamin': jk},
            'akg_target':  akg_target,
            'rekomendasi': rekomendasi_list,
        }
    }), 200

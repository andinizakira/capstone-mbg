"""
routes/admin_bahan_baku.py
==========================
CRUD endpoint untuk data bahan baku — hanya bisa diakses role 'admin'.
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from database import get_db
from functools import wraps

admin_bb_bp = Blueprint('admin_bahan_baku', __name__,
                         url_prefix='/api/admin/bahan-baku')


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


# ── GET /api/admin/bahan-baku ──────────────────────────────────────────────
@admin_bb_bp.route('', methods=['GET'])
@admin_required
def list_bahan():
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT * FROM bahan_baku ORDER BY id")
        rows = cur.fetchall()
        return jsonify({'status': 'success', 'data': rows}), 200
    finally:
        cur.close()
        conn.close()


# ── POST /api/admin/bahan-baku ─────────────────────────────────────────────
@admin_bb_bp.route('', methods=['POST'])
@admin_required
def tambah_bahan():
    data = request.get_json() or {}
    if 'nama_bahan' not in data:
        return jsonify({'status': 'error',
                        'message': "Field 'nama_bahan' wajib diisi"}), 400

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO bahan_baku
                (nama_bahan, takaran, nama_baku, energi, karbohidrat, protein, lemak, serat)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data.get('nama_bahan'),
            data.get('takaran'),
            data.get('nama_baku'),
            float(data.get('energi', 0)),
            float(data.get('karbohidrat', 0)),
            float(data.get('protein', 0)),
            float(data.get('lemak', 0)),
            float(data.get('serat', 0)),
        ))
        conn.commit()
        new_id = cur.lastrowid
        cur.execute("SELECT * FROM bahan_baku WHERE id = %s", (new_id,))
        new = cur.fetchone()
        return jsonify({'status': 'success',
                        'message': 'Bahan baku berhasil ditambahkan',
                        'data': new}), 201
    finally:
        cur.close()
        conn.close()


# ── PUT /api/admin/bahan-baku/<id> ─────────────────────────────────────────
@admin_bb_bp.route('/<int:bb_id>', methods=['PUT'])
@admin_required
def update_bahan(bb_id):
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT id FROM bahan_baku WHERE id = %s", (bb_id,))
        if not cur.fetchone():
            return jsonify({'status': 'error',
                            'message': 'Bahan baku tidak ditemukan'}), 404

        data = request.get_json() or {}
        fields = ['nama_bahan', 'takaran', 'nama_baku',
                  'energi', 'karbohidrat', 'protein', 'lemak', 'serat']
        updates = {f: data[f] for f in fields if f in data}

        if not updates:
            return jsonify({'status': 'error',
                            'message': 'Tidak ada field yang diupdate'}), 400

        set_clause = ', '.join(f"{k} = %s" for k in updates)
        values     = list(updates.values()) + [bb_id]
        cur.execute(f"UPDATE bahan_baku SET {set_clause} WHERE id = %s", values)
        conn.commit()

        cur.execute("SELECT * FROM bahan_baku WHERE id = %s", (bb_id,))
        updated = cur.fetchone()
        return jsonify({'status': 'success',
                        'message': 'Bahan baku berhasil diupdate',
                        'data': updated}), 200
    finally:
        cur.close()
        conn.close()


# ── DELETE /api/admin/bahan-baku/<id> ─────────────────────────────────────
@admin_bb_bp.route('/<int:bb_id>', methods=['DELETE'])
@admin_required
def hapus_bahan(bb_id):
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT id FROM bahan_baku WHERE id = %s", (bb_id,))
        if not cur.fetchone():
            return jsonify({'status': 'error',
                            'message': 'Bahan baku tidak ditemukan'}), 404

        cur.execute("DELETE FROM bahan_baku WHERE id = %s", (bb_id,))
        conn.commit()
        return jsonify({'status': 'success',
                        'message': f'Bahan baku ID {bb_id} berhasil dihapus'}), 200
    finally:
        cur.close()
        conn.close()

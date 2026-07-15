"""
routes/admin_menu.py
====================
CRUD endpoint untuk data menu — hanya bisa diakses role 'admin'.
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from database import get_db
from functools import wraps

admin_menu_bp = Blueprint('admin_menu', __name__, url_prefix='/api/admin/menu')


def admin_required(fn):
    """Decorator: tolak request jika role bukan 'admin'."""
    @wraps(fn)
    @jwt_required()
    def wrapper(*args, **kwargs):
        claims = get_jwt()
        if claims.get('role') != 'admin':
            return jsonify({'status': 'error',
                            'message': 'Akses ditolak. Hanya admin.'}), 403
        return fn(*args, **kwargs)
    return wrapper


# ── GET /api/admin/menu ────────────────────────────────────────────────────
@admin_menu_bp.route('', methods=['GET'])
@admin_required
def list_menu():
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT * FROM menu ORDER BY id")
        rows = cur.fetchall()
        return jsonify({'status': 'success', 'data': rows}), 200
    finally:
        cur.close()
        conn.close()


# ── POST /api/admin/menu ───────────────────────────────────────────────────
@admin_menu_bp.route('', methods=['POST'])
@admin_required
def tambah_menu():
    data = request.get_json() or {}
    required = ['nama_menu', 'makanan_berat', 'dessert',
                'energi', 'protein', 'lemak', 'karbohidrat', 'serat']
    missing = [f for f in required if f not in data]
    if missing:
        return jsonify({'status': 'error',
                        'message': f"Field wajib: {', '.join(missing)}"}), 400

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO menu (nama_menu, makanan_berat, dessert,
                              energi, protein, lemak, karbohidrat, serat)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['nama_menu'], data['makanan_berat'], data['dessert'],
            float(data['energi']), float(data['protein']),
            float(data['lemak']), float(data['karbohidrat']),
            float(data['serat']),
        ))
        conn.commit()
        new_id = cur.lastrowid
        cur.execute("SELECT * FROM menu WHERE id = %s", (new_id,))
        new = cur.fetchone()
        return jsonify({'status': 'success',
                        'message': 'Menu berhasil ditambahkan',
                        'data': new}), 201
    finally:
        cur.close()
        conn.close()


# ── PUT /api/admin/menu/<id> ───────────────────────────────────────────────
@admin_menu_bp.route('/<int:menu_id>', methods=['PUT'])
@admin_required
def update_menu(menu_id):
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT id FROM menu WHERE id = %s", (menu_id,))
        if not cur.fetchone():
            return jsonify({'status': 'error', 'message': 'Menu tidak ditemukan'}), 404

        data = request.get_json() or {}
        fields = ['nama_menu', 'makanan_berat', 'dessert',
                  'energi', 'protein', 'lemak', 'karbohidrat', 'serat']
        updates = {f: data[f] for f in fields if f in data}

        if not updates:
            return jsonify({'status': 'error',
                            'message': 'Tidak ada field yang diupdate'}), 400

        set_clause = ', '.join(f"{k} = %s" for k in updates)
        values     = list(updates.values()) + [menu_id]
        cur.execute(f"UPDATE menu SET {set_clause} WHERE id = %s", values)
        conn.commit()

        cur.execute("SELECT * FROM menu WHERE id = %s", (menu_id,))
        updated = cur.fetchone()
        return jsonify({'status': 'success',
                        'message': 'Menu berhasil diupdate',
                        'data': updated}), 200
    finally:
        cur.close()
        conn.close()


# ── DELETE /api/admin/menu/<id> ────────────────────────────────────────────
@admin_menu_bp.route('/<int:menu_id>', methods=['DELETE'])
@admin_required
def hapus_menu(menu_id):
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT id FROM menu WHERE id = %s", (menu_id,))
        if not cur.fetchone():
            return jsonify({'status': 'error', 'message': 'Menu tidak ditemukan'}), 404

        cur.execute("DELETE FROM menu WHERE id = %s", (menu_id,))
        conn.commit()
        return jsonify({'status': 'success',
                        'message': f'Menu ID {menu_id} berhasil dihapus'}), 200
    finally:
        cur.close()
        conn.close()

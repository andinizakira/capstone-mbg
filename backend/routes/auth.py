"""
routes/auth.py
==============
Endpoint autentikasi: register (siswa) dan login (siswa + admin).
JWT payload menyertakan field 'role' untuk otorisasi.
"""

import bcrypt
from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from database import get_db

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


# ── POST /api/auth/register ────────────────────────────────────────────────
@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Registrasi akun siswa baru.
    Body: { "nama": str, "email": str, "password": str }
    """
    if not request.is_json:
        return jsonify({'status': 'error', 'message': 'Request harus JSON'}), 400

    data  = request.get_json()
    nama  = data.get('nama', '').strip()
    email = data.get('email', '').strip().lower()
    pwd   = data.get('password', '')

    if not nama or not email or not pwd:
        return jsonify({'status': 'error',
                        'message': 'nama, email, dan password wajib diisi'}), 400

    if len(pwd) < 6:
        return jsonify({'status': 'error',
                        'message': 'Password minimal 6 karakter'}), 400

    hashed = bcrypt.hashpw(pwd.encode(), bcrypt.gensalt()).decode('utf-8')

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO users (nama, email, password, role) VALUES (%s, %s, %s, 'siswa')",
            (nama, email, hashed)
        )
        conn.commit()
        cur.execute(
            "SELECT id, nama, email, role FROM users WHERE email = %s", (email,)
        )
        user = cur.fetchone()

        token = create_access_token(
            identity=str(user['id']),
            additional_claims={'role': user['role'], 'nama': user['nama']}
        )
        return jsonify({
            'status': 'success',
            'message': 'Registrasi berhasil',
            'data': {
                'token': token,
                'user': {
                    'id':    user['id'],
                    'nama':  user['nama'],
                    'email': user['email'],
                    'role':  user['role'],
                }
            }
        }), 201

    except Exception as e:
        conn.rollback()
        err_str = str(e)
        if 'Duplicate entry' in err_str or '1062' in err_str:
            return jsonify({'status': 'error',
                            'message': 'Email sudah terdaftar'}), 409
        return jsonify({'status': 'error', 'message': err_str}), 500
    finally:
        cur.close()
        conn.close()


# ── POST /api/auth/login ───────────────────────────────────────────────────
@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Login untuk siswa DAN admin (role terdeteksi otomatis).
    Body: { "email": str, "password": str }
    """
    if not request.is_json:
        return jsonify({'status': 'error', 'message': 'Request harus JSON'}), 400

    data  = request.get_json()
    email = data.get('email', '').strip().lower()
    pwd   = data.get('password', '')

    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cur.fetchone()

        if not user:
            return jsonify({'status': 'error',
                            'message': 'Email atau password salah'}), 401

        is_valid = bcrypt.checkpw(pwd.encode(), user['password'].encode())
        if not is_valid:
            return jsonify({'status': 'error',
                            'message': 'Email atau password salah'}), 401

        token = create_access_token(
            identity=str(user['id']),
            additional_claims={'role': user['role'], 'nama': user['nama']}
        )
        return jsonify({
            'status': 'success',
            'message': 'Login berhasil',
            'data': {
                'token': token,
                'user': {
                    'id':    user['id'],
                    'nama':  user['nama'],
                    'email': user['email'],
                    'role':  user['role'],
                }
            }
        }), 200

    finally:
        cur.close()
        conn.close()

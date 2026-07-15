"""
database.py
===========
Koneksi MySQL (XAMPP) — Sistem Rekomendasi Menu MBG
Database: mbg_app
"""

import pymysql
import pymysql.cursors
import bcrypt

# ── Konfigurasi koneksi MySQL (XAMPP) ──────────────────────────────────────
DB_CONFIG = {
    'host':     'localhost',
    'port':     3306,
    'user':     'root',
    'password': '',          # XAMPP default: kosong
    'database': 'mbg_app',
    'charset':  'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,  # hasil query langsung jadi dict
    'autocommit': False,
}


def get_db():
    """Buka dan kembalikan koneksi MySQL."""
    conn = pymysql.connect(**DB_CONFIG)
    return conn


def init_db():
    """Buat semua tabel dan seed akun admin default jika belum ada."""
    conn = get_db()
    cur  = conn.cursor()

    # ── Tabel users ────────────────────────────────────────────────────────
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id         INT AUTO_INCREMENT PRIMARY KEY,
            nama       VARCHAR(150) NOT NULL,
            email      VARCHAR(150) UNIQUE NOT NULL,
            password   VARCHAR(255) NOT NULL,
            role       ENUM('siswa','admin') NOT NULL DEFAULT 'siswa',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    # ── Tabel menu ─────────────────────────────────────────────────────────
    cur.execute("""
        CREATE TABLE IF NOT EXISTS menu (
            id            INT AUTO_INCREMENT PRIMARY KEY,
            nama_menu     VARCHAR(255) NOT NULL,
            makanan_berat VARCHAR(255),
            dessert       VARCHAR(255),
            energi        FLOAT,
            protein       FLOAT,
            lemak         FLOAT,
            karbohidrat   FLOAT,
            serat         FLOAT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    # ── Tabel bahan_baku ───────────────────────────────────────────────────
    cur.execute("""
        CREATE TABLE IF NOT EXISTS bahan_baku (
            id         INT AUTO_INCREMENT PRIMARY KEY,
            nama_bahan VARCHAR(255) NOT NULL,
            takaran    VARCHAR(100),
            nama_baku  VARCHAR(255),
            energi     FLOAT,
            karbohidrat FLOAT,
            protein    FLOAT,
            lemak      FLOAT,
            serat      FLOAT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    # ── Tabel riwayat ──────────────────────────────────────────────────────
    cur.execute("""
        CREATE TABLE IF NOT EXISTS riwayat (
            id            INT AUTO_INCREMENT PRIMARY KEY,
            user_id       INT,
            umur          INT,
            jenis_kelamin VARCHAR(20),
            menu_id       INT,
            nama_menu     VARCHAR(255),
            makanan_berat VARCHAR(255),
            dessert       VARCHAR(255),
            energi        FLOAT,
            status        VARCHAR(50),
            waktu_makan   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX (user_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    # ── Seed akun admin default ─────────────────────────────────────────────
    cur.execute("SELECT id FROM users WHERE role = 'admin' LIMIT 1")
    existing_admin = cur.fetchone()

    if not existing_admin:
        hashed = bcrypt.hashpw(b'admin123', bcrypt.gensalt()).decode('utf-8')
        cur.execute(
            "INSERT INTO users (nama, email, password, role) VALUES (%s, %s, %s, %s)",
            ('Administrator', 'admin@mbg.id', hashed, 'admin')
        )
        print("[DB] Akun admin default dibuat: admin@mbg.id / admin123")

    conn.commit()
    cur.close()
    conn.close()
    print("[DB] Database MySQL (mbg_app) siap!")

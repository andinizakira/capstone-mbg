"""
seed_menu.py
============
Import semua data dari menu_tanpa_duplikat.csv ke tabel menu di MySQL.
Jalankan sekali saja: python seed_menu.py
"""

import os
import csv
import pymysql

# ── Koneksi MySQL ───────────────────────────────────────────────────────────
DB_CONFIG = {
    'host':     'localhost',
    'port':     3306,
    'user':     'root',
    'password': '',
    'database': 'mbg_app',
    'charset':  'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
}

CSV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'menu_tanpa_duplikat.csv')


def seed_menu():
    conn = pymysql.connect(**DB_CONFIG)
    cur  = conn.cursor()

    # Cek apakah sudah ada data
    cur.execute("SELECT COUNT(*) as total FROM menu")
    total = cur.fetchone()['total']
    if total > 0:
        print(f"[SEED] Tabel menu sudah ada {total} baris. Skip import.")
        cur.close()
        conn.close()
        return

    # Baca CSV
    with open(CSV_PATH, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    count = 0
    for row in rows:
        # Normalisasi nama kolom (strip + lowercase)
        row = {k.strip().lower(): v.strip() for k, v in row.items()}

        nama_menu    = row.get('menu', '')
        makanan_berat = row.get('makanan berat', '')
        dessert      = row.get('dessert', '')
        energi       = float(row.get('energi', 0) or 0)
        protein      = float(row.get('protein', 0) or 0)
        lemak        = float(row.get('lemak', 0) or 0)
        karbohidrat  = float(row.get('karbohidrat', 0) or 0)
        serat        = float(row.get('serat', 0) or 0)

        if not nama_menu:
            continue

        cur.execute("""
            INSERT INTO menu
                (nama_menu, makanan_berat, dessert,
                 energi, protein, lemak, karbohidrat, serat)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (nama_menu, makanan_berat, dessert,
              energi, protein, lemak, karbohidrat, serat))
        count += 1

    conn.commit()
    cur.close()
    conn.close()
    print(f"[SEED] Berhasil import {count} menu ke database MySQL!")


if __name__ == '__main__':
    seed_menu()

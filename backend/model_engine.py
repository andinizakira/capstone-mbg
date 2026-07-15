"""
model_engine.py
================
Mesin inti rekomendasi menu MBG menggunakan:
  - KNN manual (Euclidean Distance) untuk mencari kandidat menu terdekat
  - GaussianNB (Naive Bayes) untuk memprediksi kelayakan menu
"""

import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from sklearn.naive_bayes import GaussianNB


# ---------------------------------------------------------------------------
# 1. PEMETAAN AKG (Angka Kecukupan Gizi) INDONESIA — Umur 7–18 Tahun
# ---------------------------------------------------------------------------
AKG_TABLE = {
    # (umur, jenis_kelamin): (energi_kcal, protein_g, lemak_g, karbohidrat_g, serat_g)
    (7,  'L'): (1650, 40, 55, 250, 23),
    (8,  'L'): (1650, 40, 55, 250, 23),
    (9,  'L'): (1800, 45, 60, 275, 26),
    (10, 'L'): (2000, 50, 65, 300, 26),
    (11, 'L'): (2000, 50, 65, 300, 26),
    (12, 'L'): (2100, 60, 70, 320, 30),
    (13, 'L'): (2400, 70, 80, 350, 35),
    (14, 'L'): (2400, 70, 80, 350, 35),
    (15, 'L'): (2475, 75, 85, 360, 37),
    (16, 'L'): (2475, 75, 85, 360, 37),
    (17, 'L'): (2475, 75, 85, 360, 37),
    (18, 'L'): (2475, 75, 85, 360, 37),

    (7,  'P'): (1550, 40, 50, 235, 20),
    (8,  'P'): (1550, 40, 50, 235, 20),
    (9,  'P'): (1750, 45, 55, 265, 23),
    (10, 'P'): (1900, 55, 65, 280, 25),
    (11, 'P'): (1900, 55, 65, 280, 25),
    (12, 'P'): (2000, 60, 65, 300, 28),
    (13, 'P'): (2050, 65, 70, 300, 30),
    (14, 'P'): (2050, 65, 70, 300, 30),
    (15, 'P'): (2050, 65, 70, 300, 30),
    (16, 'P'): (2100, 65, 70, 300, 30),
    (17, 'P'): (2100, 65, 70, 300, 30),
    (18, 'P'): (2100, 65, 70, 300, 30),
}


def get_akg(umur: int, jenis_kelamin: str) -> dict:
    """
    Kembalikan target AKG berdasarkan umur dan jenis kelamin.
    Jenis kelamin diterima sebagai 'L', 'l', 'Laki-laki', 'P', 'p', 'Perempuan'.
    """
    jk = jenis_kelamin.strip().upper()
    if jk in ('LAKI-LAKI', 'LAKI', 'L'):
        jk = 'L'
    elif jk in ('PEREMPUAN', 'P'):
        jk = 'P'
    else:
        raise ValueError(f"Jenis kelamin tidak dikenal: '{jenis_kelamin}'. Gunakan 'L' atau 'P'.")

    if umur < 7 or umur > 18:
        raise ValueError(f"Umur {umur} di luar rentang yang didukung (7–18 tahun).")

    energi, protein, lemak, karbohidrat, serat = AKG_TABLE[(umur, jk)]
    return {
        'energi':      energi,
        'protein':     protein,
        'lemak':       lemak,
        'karbohidrat': karbohidrat,
        'serat':       serat,
    }


# ---------------------------------------------------------------------------
# 2. LOAD & CLEANING DATASET
# ---------------------------------------------------------------------------
_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
_CSV_PATH = os.path.join(_BASE_DIR, 'menu_tanpa_duplikat.csv')


def _load_and_clean(csv_path: str = _CSV_PATH) -> pd.DataFrame:
    """
    Membaca CSV menu, membersihkan data, dan menormalisasi nama kolom.
    """
    df = pd.read_csv(csv_path)

    # Normalkan nama kolom → lowercase + strip spasi
    df.columns = [c.strip().lower() for c in df.columns]

    # Buang baris kosong
    df.dropna(inplace=True)

    # Pastikan kolom numeris memiliki tipe float
    numeric_cols = ['energi', 'protein', 'lemak', 'karbohidrat', 'serat']
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    # Buang baris yang masih mengandung NaN setelah konversi
    df.dropna(subset=numeric_cols, inplace=True)
    df.reset_index(drop=True, inplace=True)

    return df


# ---------------------------------------------------------------------------
# 3. KNN MANUAL — Euclidean Distance
# ---------------------------------------------------------------------------
def _euclidean_distance(vec_a: np.ndarray, vec_b: np.ndarray) -> float:
    return float(np.sqrt(np.sum((vec_a - vec_b) ** 2)))


def _knn_rekomendasi(df: pd.DataFrame,
                     target_vector_scaled: np.ndarray,
                     scaler: MinMaxScaler,
                     k: int = 15) -> pd.DataFrame:
    """
    Hitung jarak Euclidean semua baris dataset terhadap target vektor AKG,
    kembalikan K baris terdekat.
    """
    fitur_cols = ['energi', 'lemak', 'karbohidrat']
    X = df[fitur_cols].values
    X_scaled = scaler.transform(X)

    distances = np.array([
        _euclidean_distance(row, target_vector_scaled)
        for row in X_scaled
    ])

    df = df.copy()
    df['_distance'] = distances
    df_sorted = df.sort_values('_distance').head(k)
    return df_sorted


# ---------------------------------------------------------------------------
# 4. DIVERSITY FILTERING — ambil 4 menu unik berdasarkan 'makanan berat'
# ---------------------------------------------------------------------------
def _diversity_filter(df_knn: pd.DataFrame, n: int = 4) -> pd.DataFrame:
    """
    Dari K kandidat KNN, pilih 4 menu yang memiliki variasi 'makanan berat'
    paling beragam. Jika jumlah varian < 4, ambil menu berikutnya berdasarkan
    jarak terpendek hingga total 4 item.
    """
    col = 'makanan berat'

    seen_mb = set()
    selected = []

    for _, row in df_knn.iterrows():
        mb = str(row.get(col, '')).strip().lower()
        if mb not in seen_mb:
            seen_mb.add(mb)
            selected.append(row)
        if len(selected) == n:
            break

    # Jika masih kurang dari n, tambahkan menu berikutnya (meski duplikat 'makanan berat')
    if len(selected) < n:
        already_indices = {r.name for r in selected}
        for _, row in df_knn.iterrows():
            if row.name not in already_indices:
                selected.append(row)
            if len(selected) == n:
                break

    return pd.DataFrame(selected).reset_index(drop=True)


# ---------------------------------------------------------------------------
# 5. RULE-BASED LABELING + PELATIHAN GaussianNB
# ---------------------------------------------------------------------------
def _buat_label(df: pd.DataFrame, energi_target: float) -> pd.DataFrame:
    """
    Label 'Layak'  → energi berada di rentang 20%–50% dari target AKG energi
    Label 'Tidak'  → di luar rentang tersebut
    """
    batas_bawah = 0.20 * energi_target
    batas_atas  = 0.50 * energi_target

    df = df.copy()
    df['label'] = df['energi'].apply(
        lambda e: 'Layak' if batas_bawah <= e <= batas_atas else 'Tidak'
    )
    return df


def _latih_naive_bayes(df_labeled: pd.DataFrame) -> tuple[GaussianNB, list[str]]:
    """
    Latih GaussianNB menggunakan fitur energi, protein, lemak, karbohidrat, serat.
    Kembalikan (model, fitur_cols).
    """
    fitur_cols = ['energi', 'protein', 'lemak', 'karbohidrat', 'serat']
    X_train = df_labeled[fitur_cols].values
    y_train = df_labeled['label'].values

    model = GaussianNB()
    model.fit(X_train, y_train)
    return model, fitur_cols


# ---------------------------------------------------------------------------
# 6. FUNGSI UTAMA: proses_rekomendasi
# ---------------------------------------------------------------------------
def proses_rekomendasi(umur: int, jenis_kelamin: str) -> list[dict]:
    """
    Pipeline lengkap:
      1. Load & cleaning dataset
      2. Dapatkan target AKG user
      3. MinMaxScaler pada fitur KNN
      4. KNN (K=15) → diversity filter → 4 kandidat
      5. Rule-based labeling → latih GaussianNB
      6. Prediksi kelayakan 4 kandidat
      7. Return list of dict (JSON-serializable)
    """

    # --- Step 1: Load data ---
    df = _load_and_clean()

    # --- Step 2: Target AKG ---
    akg = get_akg(umur, jenis_kelamin)
    energi_target   = akg['energi']
    lemak_target    = akg['lemak']
    karbohidrat_target = akg['karbohidrat']

    # --- Step 3: Fit MinMaxScaler pada fitur KNN ---
    fitur_knn = ['energi', 'lemak', 'karbohidrat']
    scaler = MinMaxScaler()
    scaler.fit(df[fitur_knn].values)

    # Transformasi target vektor AKG
    target_raw = np.array([[energi_target, lemak_target, karbohidrat_target]])
    target_scaled = scaler.transform(target_raw)[0]

    # --- Step 4: KNN → Diversity Filter ---
    df_knn = _knn_rekomendasi(df, target_scaled, scaler, k=15)
    df_kandidat = _diversity_filter(df_knn, n=4)

    # --- Step 5: Labeling seluruh dataset & latih NB ---
    df_labeled = _buat_label(df, energi_target)
    nb_model, fitur_nb = _latih_naive_bayes(df_labeled)

    # --- Step 6: Prediksi kelayakan 4 kandidat ---
    X_kandidat = df_kandidat[fitur_nb].values
    prediksi   = nb_model.predict(X_kandidat)

    # --- Step 7: Bangun hasil JSON ---
    # Deteksi nama kolom menu secara fleksibel (support variasi nama kolom CSV)
    def _get_col(row, *candidates):
        for c in candidates:
            val = row.get(c)
            if val is not None:
                return str(val)
        return '-'

    hasil = []
    for i, (_, row) in enumerate(df_kandidat.iterrows()):
        item = {
            'nama_menu':    _get_col(row, 'menu', 'nama menu', 'nama_menu'),
            'makanan_berat': _get_col(row, 'makanan berat', 'makanan_berat'),
            'dessert':      _get_col(row, 'dessert'),
            'energi':       round(float(row['energi']), 2),
            'protein':      round(float(row['protein']), 2),
            'lemak':        round(float(row['lemak']), 2),
            'karbohidrat':  round(float(row['karbohidrat']), 2),
            'serat':        round(float(row['serat']), 2),
            'status':       str(prediksi[i]),
            'jarak':        round(float(row['_distance']), 4),
        }
        hasil.append(item)

    return hasil

"""
evaluate_nb.py
==============
Script untuk menghitung akurasi Naive Bayes pada model MBG.

Karena label dibuat secara rule-based (energi 20-50% dari AKG target),
kita evaluasi seberapa akurat GaussianNB mempelajari rule tersebut.

Metode evaluasi:
  1. Akurasi training (seluruh data) - seberapa fit model terhadap data training
  2. Cross-validation (5-fold) - estimasi generalisasi model
  3. Per kombinasi umur & jenis kelamin
"""

import numpy as np
import pandas as pd
from sklearn.naive_bayes import GaussianNB
from sklearn.model_selection import cross_val_score, train_test_split
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)

from model_engine import _load_and_clean, get_akg, AKG_TABLE, _buat_label

def evaluate():
    df = _load_and_clean()
    print(f"Total data menu: {len(df)} baris")
    print(f"Kolom: {list(df.columns)}")
    print("=" * 70)

    fitur_cols = ['energi', 'protein', 'lemak', 'karbohidrat', 'serat']

    # -----------------------------------------------------------------------
    # Evaluasi per setiap kombinasi umur & jenis kelamin
    # -----------------------------------------------------------------------
    all_results = []

    for (umur, jk), akg_vals in sorted(AKG_TABLE.items()):
        energi_target = akg_vals[0]  # energi

        # Buat label berdasarkan rule
        df_labeled = _buat_label(df, energi_target)

        X = df_labeled[fitur_cols].values
        y = df_labeled['label'].values

        # Hitung distribusi label
        unique, counts = np.unique(y, return_counts=True)
        dist = dict(zip(unique, counts))

        # --- Training accuracy ---
        model = GaussianNB()
        model.fit(X, y)
        y_pred = model.predict(X)
        train_acc = accuracy_score(y, y_pred)

        # --- Cross-validation (5-fold) ---
        # Jika hanya ada 1 class, cross-val tidak bermakna
        if len(unique) > 1:
            cv_scores = cross_val_score(model, X, y, cv=5, scoring='accuracy')
            cv_mean = cv_scores.mean()
            cv_std = cv_scores.std()
        else:
            cv_mean = 1.0  # semua data 1 class, model selalu benar
            cv_std = 0.0

        all_results.append({
            'Umur': umur,
            'JK': jk,
            'Energi_Target': energi_target,
            'Distribusi': dist,
            'Train_Acc': train_acc,
            'CV_Mean': cv_mean,
            'CV_Std': cv_std,
        })

    # -----------------------------------------------------------------------
    # Tampilkan hasil per kombinasi
    # -----------------------------------------------------------------------
    print(f"\n{'Umur':<6} {'JK':<4} {'Energi Target':<15} {'Distribusi Label':<30} {'Train Acc':<12} {'CV Acc (5-fold)':<20}")
    print("-" * 90)

    for r in all_results:
        dist_str = str(r['Distribusi'])
        print(f"{r['Umur']:<6} {r['JK']:<4} {r['Energi_Target']:<15} {dist_str:<30} {r['Train_Acc']:<12.4f} {r['CV_Mean']:.4f} ± {r['CV_Std']:.4f}")

    # -----------------------------------------------------------------------
    # Rata-rata keseluruhan
    # -----------------------------------------------------------------------
    avg_train = np.mean([r['Train_Acc'] for r in all_results])
    avg_cv = np.mean([r['CV_Mean'] for r in all_results])
    print("-" * 90)
    print(f"{'RATA-RATA':<55} {avg_train:<12.4f} {avg_cv:.4f}")

    # -----------------------------------------------------------------------
    # Detail classification report untuk satu contoh (umur=13, JK='L')
    # -----------------------------------------------------------------------
    print("\n" + "=" * 70)
    print("DETAIL EVALUASI — Contoh: Umur=13, JK=L (Energi Target=2400)")
    print("=" * 70)

    akg = get_akg(13, 'L')
    df_labeled = _buat_label(df, akg['energi'])
    X = df_labeled[fitur_cols].values
    y = df_labeled['label'].values

    unique, counts = np.unique(y, return_counts=True)
    print(f"\nDistribusi label: {dict(zip(unique, counts))}")

    model = GaussianNB()
    model.fit(X, y)
    y_pred = model.predict(X)

    print(f"\nTraining Accuracy: {accuracy_score(y, y_pred):.4f}")
    print(f"\nConfusion Matrix:\n{confusion_matrix(y, y_pred)}")
    print(f"\nClassification Report:\n{classification_report(y, y_pred)}")

    if len(unique) > 1:
        cv_scores = cross_val_score(model, X, y, cv=5, scoring='accuracy')
        print(f"Cross-Validation Accuracy (5-fold): {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")
        print(f"Per-fold scores: {cv_scores}")

    # -----------------------------------------------------------------------
    # Train/Test Split 80/20 (contoh umur=13, JK=L)
    # -----------------------------------------------------------------------
    if len(unique) > 1:
        print("\n--- Train/Test Split 80/20 ---")
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        model2 = GaussianNB()
        model2.fit(X_train, y_train)
        y_test_pred = model2.predict(X_test)
        print(f"Test Accuracy (80/20 split): {accuracy_score(y_test, y_test_pred):.4f}")
        print(f"Test Classification Report:\n{classification_report(y_test, y_test_pred)}")


if __name__ == '__main__':
    evaluate()

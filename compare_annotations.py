#!/usr/bin/env python3
"""
Compare Claude annotations against gold standard labels.
Computes Cohen's kappa and per-label metrics.
"""

import pandas as pd
import numpy as np
from sklearn.metrics import cohen_kappa_score, precision_recall_fscore_support, confusion_matrix

# Load data
gold_ytrue = pd.read_csv('gold/sample_gold_Ytrue.csv', header=None)
claude_annotations = pd.read_csv('gold/claude_annotations.csv')

# Extract label columns
label_names = ['IRB', 'Liquidity_LCR', 'AML_KYC', 'Securitisation', 'LeverageRatio']
Y_true = gold_ytrue.values
Y_claude = claude_annotations[label_names].values

# Verify dimensions
assert Y_true.shape == Y_claude.shape, f"Shape mismatch: {Y_true.shape} vs {Y_claude.shape}"
n_chunks, n_labels = Y_true.shape

print("=" * 70)
print("CLAUDE vs GOLD ANNOTATION COMPARISON")
print("=" * 70)
print(f"\nDataset: {n_chunks} chunks × {n_labels} labels")
print(f"Total annotations: {n_chunks * n_labels}")

# Overall metrics
y_true_flat = Y_true.flatten()
y_claude_flat = Y_claude.flatten()

kappa_overall = cohen_kappa_score(y_true_flat, y_claude_flat)
accuracy_overall = np.mean(y_true_flat == y_claude_flat)

print(f"\n{'--- OVERALL METRICS ---'}")
print(f"Cohen's kappa:     κ = {kappa_overall:.3f}")
print(f"Overall accuracy:      {100 * accuracy_overall:.1f}%")

# Interpret kappa
print(f"\nInterpretation: ", end="")
if kappa_overall >= 0.81:
    print("✅ ALMOST PERFECT agreement (0.81-1.00)")
elif kappa_overall >= 0.61:
    print("✅ SUBSTANTIAL agreement (0.61-0.80)")
elif kappa_overall >= 0.41:
    print("⚠️  MODERATE agreement (0.41-0.60)")
elif kappa_overall >= 0.21:
    print("⚠️  FAIR agreement (0.21-0.40)")
else:
    print("❌ POOR agreement (< 0.21)")

# Per-label metrics
print(f"\n{'--- PER-LABEL METRICS ---'}")
print(f"{'Label':<20}  {'κ':>6}  {'Prec':>6}  {'Rec':>6}  {'F1':>6}  {'TP':>3}  {'FP':>3}  {'FN':>3}  {'TN':>3}")
print("-" * 70)

per_label_results = []

for i, label in enumerate(label_names):
    y_true_i = Y_true[:, i]
    y_claude_i = Y_claude[:, i]

    # Kappa
    kappa_i = cohen_kappa_score(y_true_i, y_claude_i)

    # Precision, Recall, F1
    precision, recall, f1, _ = precision_recall_fscore_support(
        y_true_i, y_claude_i, average='binary', zero_division=0
    )

    # Confusion matrix
    tn, fp, fn, tp = confusion_matrix(y_true_i, y_claude_i).ravel()

    print(f"{label:<20}  {kappa_i:6.3f}  {precision:6.3f}  {recall:6.3f}  {f1:6.3f}  {tp:3d}  {fp:3d}  {fn:3d}  {tn:3d}")

    per_label_results.append({
        'Label': label,
        'Kappa': kappa_i,
        'Precision': precision,
        'Recall': recall,
        'F1': f1,
        'TP': tp,
        'FP': fp,
        'FN': fn,
        'TN': tn
    })

# Identify disagreements
print(f"\n{'--- DISAGREEMENTS ---'}")

chunks_df = pd.read_csv('gold/sample_gold_chunks.csv')
disagreements = []

for i in range(n_chunks):
    true_labels = [label_names[j] for j in range(n_labels) if Y_true[i, j] == 1]
    claude_labels = [label_names[j] for j in range(n_labels) if Y_claude[i, j] == 1]

    if true_labels != claude_labels:
        text_preview = chunks_df.iloc[i]['text'][:80] + "..."

        disagreements.append({
            'Chunk ID': chunks_df.iloc[i]['chunk_id'],
            'Text Preview': text_preview,
            'Gold Labels': ', '.join(true_labels) if true_labels else '(none)',
            'Claude Labels': ', '.join(claude_labels) if claude_labels else '(none)',
        })

n_disagree = len(disagreements)
n_agree = n_chunks - n_disagree

print(f"Agreement:     {n_agree} / {n_chunks} chunks ({100 * n_agree / n_chunks:.1f}%)")
print(f"Disagreements: {n_disagree} / {n_chunks} chunks ({100 * n_disagree / n_chunks:.1f}%)")

if disagreements:
    print(f"\nDisagreement details:")
    disagree_df = pd.DataFrame(disagreements)
    print(disagree_df.to_string(index=False))

# Per-label quality assessment
print(f"\n{'--- PER-LABEL QUALITY ---'}")
for result in per_label_results:
    label = result['Label']
    kappa_i = result['Kappa']
    print(f"  {label}: ", end="")
    if kappa_i >= 0.80:
        print(f"✅ EXCELLENT (κ={kappa_i:.3f})")
    elif kappa_i >= 0.60:
        print(f"✓  GOOD (κ={kappa_i:.3f})")
    elif kappa_i >= 0.40:
        print(f"⚠️  MODERATE (κ={kappa_i:.3f}) - needs improvement")
    else:
        print(f"❌ POOR (κ={kappa_i:.3f}) - not reliable")

# Recommendation
print(f"\n{'--- RECOMMENDATION ---'}")
if kappa_overall >= 0.70:
    print("✅ PROCEED with Claude-as-annotator")
    print("   Agreement is GOOD/EXCELLENT for automated annotation.")
    print("   Consider using Claude to bootstrap labels on full corpus.\n")
elif kappa_overall >= 0.60:
    print("⚠️  CAUTIOUS PROCEED - refine guidelines first")
    print("   Agreement is MODERATE. Review disagreements and clarify edge cases.")
    print("   Re-test on 50 chunks after guideline update.\n")
else:
    print("❌ DO NOT PROCEED - approach needs rework")
    print("   Agreement is too low for reliable annotation.")
    print("   Consider: (1) Refine label definitions, (2) Add examples, (3) Simplify labels.\n")

print("=" * 70)

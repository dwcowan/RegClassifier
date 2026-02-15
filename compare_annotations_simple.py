#!/usr/bin/env python3
"""
Compare Claude annotations against gold standard labels.
Computes Cohen's kappa and per-label metrics (no dependencies).
"""

import csv

def read_csv_matrix(filename):
    """Read CSV file into list of lists."""
    with open(filename, 'r') as f:
        reader = csv.reader(f)
        return [row for row in reader]

def compute_kappa(y1, y2):
    """Compute Cohen's kappa for binary labels."""
    n = len(y1)
    assert len(y2) == n

    # Observed agreement
    p_o = sum(1 for i in range(n) if y1[i] == y2[i]) / n

    # Expected agreement
    p_1 = sum(y1) / n
    p_0 = 1 - p_1
    q_1 = sum(y2) / n
    q_0 = 1 - q_1
    p_e = p_1 * q_1 + p_0 * q_0

    kappa = (p_o - p_e) / max(1 - p_e, 1e-10)
    return kappa

def compute_metrics(y_true, y_pred):
    """Compute TP, FP, FN, TN, precision, recall, F1."""
    tp = sum(1 for i in range(len(y_true)) if y_true[i] == 1 and y_pred[i] == 1)
    fp = sum(1 for i in range(len(y_true)) if y_true[i] == 0 and y_pred[i] == 1)
    fn = sum(1 for i in range(len(y_true)) if y_true[i] == 1 and y_pred[i] == 0)
    tn = sum(1 for i in range(len(y_true)) if y_true[i] == 0 and y_pred[i] == 0)

    precision = tp / max(tp + fp, 1)
    recall = tp / max(tp + fn, 1)
    f1 = 2 * precision * recall / max(precision + recall, 1e-10)

    return tp, fp, fn, tn, precision, recall, f1

# Load data
print("Loading data...")
gold_rows = read_csv_matrix('gold/sample_gold_Ytrue.csv')
Y_true = [[int(val) for val in row] for row in gold_rows if row]

claude_rows = read_csv_matrix('gold/claude_annotations.csv')
header = claude_rows[0]
claude_data = claude_rows[1:]

# Extract label columns (columns 2-6: IRB, Liquidity_LCR, AML_KYC, Securitisation, LeverageRatio)
Y_claude = [[int(row[2]), int(row[3]), int(row[4]), int(row[5]), int(row[6])] for row in claude_data]

chunks_rows = read_csv_matrix('gold/sample_gold_chunks.csv')
chunks_header = chunks_rows[0]
chunks_data = chunks_rows[1:]

label_names = ['IRB', 'Liquidity_LCR', 'AML_KYC', 'Securitisation', 'LeverageRatio']
n_chunks = len(Y_true)
n_labels = len(label_names)

print("=" * 70)
print("CLAUDE vs GOLD ANNOTATION COMPARISON")
print("=" * 70)
print(f"\nDataset: {n_chunks} chunks × {n_labels} labels")
print(f"Total annotations: {n_chunks * n_labels}")

# Flatten for overall metrics
y_true_flat = [Y_true[i][j] for i in range(n_chunks) for j in range(n_labels)]
y_claude_flat = [Y_claude[i][j] for i in range(n_chunks) for j in range(n_labels)]

kappa_overall = compute_kappa(y_true_flat, y_claude_flat)
accuracy_overall = sum(1 for i in range(len(y_true_flat)) if y_true_flat[i] == y_claude_flat[i]) / len(y_true_flat)

print(f"\n--- OVERALL METRICS ---")
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
print(f"\n--- PER-LABEL METRICS ---")
print(f"{'Label':<20}  {'κ':>6}  {'Prec':>6}  {'Rec':>6}  {'F1':>6}  {'TP':>3}  {'FP':>3}  {'FN':>3}  {'TN':>3}")
print("-" * 70)

per_label_results = []

for j, label in enumerate(label_names):
    y_true_j = [Y_true[i][j] for i in range(n_chunks)]
    y_claude_j = [Y_claude[i][j] for i in range(n_chunks)]

    kappa_j = compute_kappa(y_true_j, y_claude_j)
    tp, fp, fn, tn, precision, recall, f1 = compute_metrics(y_true_j, y_claude_j)

    print(f"{label:<20}  {kappa_j:6.3f}  {precision:6.3f}  {recall:6.3f}  {f1:6.3f}  {tp:3d}  {fp:3d}  {fn:3d}  {tn:3d}")

    per_label_results.append({
        'label': label,
        'kappa': kappa_j,
        'precision': precision,
        'recall': recall,
        'f1': f1
    })

# Identify disagreements
print(f"\n--- DISAGREEMENTS ---")

disagreements = []
for i in range(n_chunks):
    true_labels = [label_names[j] for j in range(n_labels) if Y_true[i][j] == 1]
    claude_labels = [label_names[j] for j in range(n_labels) if Y_claude[i][j] == 1]

    if true_labels != claude_labels:
        chunk_id = chunks_data[i][0]
        text = chunks_data[i][2]
        text_preview = text[:80] + "..." if len(text) > 80 else text

        disagreements.append({
            'chunk_id': chunk_id,
            'text': text_preview,
            'gold': ', '.join(true_labels) if true_labels else '(none)',
            'claude': ', '.join(claude_labels) if claude_labels else '(none)'
        })

n_disagree = len(disagreements)
n_agree = n_chunks - n_disagree

print(f"Agreement:     {n_agree} / {n_chunks} chunks ({100 * n_agree / n_chunks:.1f}%)")
print(f"Disagreements: {n_disagree} / {n_chunks} chunks ({100 * n_disagree / n_chunks:.1f}%)")

if disagreements:
    print(f"\nDisagreement details:")
    for d in disagreements:
        print(f"\n  {d['chunk_id']}")
        print(f"    Text: {d['text']}")
        print(f"    Gold:   {d['gold']}")
        print(f"    Claude: {d['claude']}")

# Per-label quality assessment
print(f"\n--- PER-LABEL QUALITY ---")
for result in per_label_results:
    label = result['label']
    kappa_j = result['kappa']
    print(f"  {label}: ", end="")
    if kappa_j >= 0.80:
        print(f"✅ EXCELLENT (κ={kappa_j:.3f})")
    elif kappa_j >= 0.60:
        print(f"✓  GOOD (κ={kappa_j:.3f})")
    elif kappa_j >= 0.40:
        print(f"⚠️  MODERATE (κ={kappa_j:.3f}) - needs improvement")
    else:
        print(f"❌ POOR (κ={kappa_j:.3f}) - not reliable")

# Recommendation
print(f"\n--- RECOMMENDATION ---")
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

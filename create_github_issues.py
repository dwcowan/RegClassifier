#!/usr/bin/env python3
"""
Create GitHub issues from methodological review.
This script uses the local git proxy to create issues.

Usage: python3 create_github_issues.py
"""

import json
import subprocess
import sys

REPO_OWNER = "dwcowan"
REPO_NAME = "RegClassifier"
PROXY_URL = "http://127.0.0.1:61251"

issues = [
    {
        "title": "[CRITICAL] Data Leakage in Evaluation - Weak Labels Used as Ground Truth",
        "labels": ["methodology", "critical", "evaluation", "data-leakage"],
        "body": """## Problem

The evaluation methodology suffers from severe data leakage that invalidates performance claims.

### Current Implementation
1. **Weak labels** are generated via keyword matching (`+reg/weak_rules.m`)
2. These weak labels are used to:
   - Train the classifier
   - Define positive sets for retrieval evaluation (`posSets`)
   - Optimize decision thresholds in `+reg/predict_multilabel.m`
   - Evaluate retrieval metrics (Recall@K, mAP, nDCG@10)

### Why This Is Invalid
- **Circular validation**: We evaluate how well the model retrieves items labeled by the same weak rules used for training
- **Optimistic bias**: Metrics will be artificially high because we're measuring agreement with noisy labels, not true performance
- **Threshold calibration leakage**: `predict_multilabel.m` optimizes thresholds on the training data using weak labels (lines 12-26)

### Files Affected
- `+reg/weak_rules.m`
- `+reg/eval_retrieval.m`
- `+reg/metrics_ndcg.m`
- `+reg/predict_multilabel.m`
- `+reg/ft_train_encoder.m`
- `+reg/eval_per_label.m`
- `reg_eval_and_report.m`
- `reg_eval_gold.m`

### Recommendations
1. Create held-out ground-truth labeled validation/test sets (minimum 500-1000 chunks)
2. Use weak labels ONLY for training/bootstrapping
3. Evaluate ONLY on human-annotated ground truth
4. Add stratified cross-validation based on true labels
5. Report inter-annotator agreement metrics

See `METHODOLOGICAL_ISSUES.md` for full details."""
    },
    {
        "title": "[CRITICAL] Weak Supervision - Naive Keyword Matching Without Context",
        "labels": ["methodology", "critical", "weak-supervision", "nlp"],
        "body": """## Problem

The weak labeling system (`+reg/weak_rules.m`) uses overly simplistic keyword matching that produces noisy, unreliable labels.

### Specific Issues
1. **No Negation Handling**: "This is not an IRB approach" matches "IRB" (FALSE POSITIVE)
2. **Substring Matching Errors**: "AML" in "AMALGAMATION" matches
3. **No Keyword Weighting**: All matches get fixed 0.9 confidence
4. **No Multi-Word Phrase Matching**: "credit risk" matches words separately
5. **Context-Free**: Ignores sentence boundaries and surrounding words
6. **Fixed Confidence**: No variation based on keyword quality or frequency

### Files Affected
- `+reg/weak_rules.m` (lines 1-36)
- `gold/sample_gold_labels.json`

### Recommendations
1. Add negation detection (spaCy or simple window-based)
2. Use word boundary matching: `\\bkeyword\\b` regex
3. Weight keywords by specificity (IDF-like weighting)
4. Require phrase-level matching for multi-word terms
5. Implement rule confidence based on keyword specificity
6. Validate against manually labeled subset (200-500 chunks)

See `METHODOLOGICAL_ISSUES.md` Issue #2 for detailed fixes."""
    },
    {
        "title": "[CRITICAL] Multi-Label Classification - Missing Label Dependency Modeling",
        "labels": ["methodology", "critical", "machine-learning", "multi-label"],
        "body": """## Problem

The multi-label classifier uses one-vs-rest logistic regression which ignores label dependencies and co-occurrence patterns.

### Issues
1. **No Label Correlation Modeling**: Treats labels as independent (IRB and CreditRisk are correlated)
2. **No Cross-Validation Stratification**: Random K-fold splits don't preserve label distribution
3. **Threshold Optimization Issues**: Optimizes F1 per label independently using weak labels
4. **No Handling of Label Imbalance**: Skips labels with <3 examples silently

### Files Affected
- `+reg/train_multilabel.m` (lines 1-14)
- `+reg/predict_multilabel.m` (lines 12-26)
- `reg_pipeline.m`

### Recommendations
1. Use classifier chains or label powerset methods
2. Implement stratified multi-label cross-validation (IterativeStratification)
3. Add label co-occurrence features to input
4. Use class weights or resampling for imbalanced labels
5. Optimize thresholds jointly, not independently

See `METHODOLOGICAL_ISSUES.md` Issue #3 for implementation examples."""
    },
    {
        "title": "[HIGH] Contrastive Learning - Suboptimal Triplet Construction",
        "labels": ["methodology", "high", "machine-learning", "contrastive-learning"],
        "body": """## Problem

Triplet construction and hard-negative mining strategies are suboptimal, leading to inefficient contrastive learning.

### Issues
1. **Single Positive Per Anchor**: Only 1 of potentially 50+ positives used per epoch
2. **Random Negative Sampling**: Not informative (easy negatives don't help learning)
3. **Hard-Negative Mining Timing**: Happens AFTER gradient update, not during batch sampling
4. **Same-Document Heuristic**: May introduce noise (assumes all chunks from same doc are similar)
5. **MaxTriplets Cap**: May truncate important examples without prioritization

### Files Affected
- `+reg/ft_build_contrastive_dataset.m` (lines 33-37)
- `+reg/build_pairs.m`
- `+reg/ft_train_encoder.m` (hard-negative mining lines 322-358)

### Recommendations
1. Use multiple positives per anchor (5-10 instead of 1)
2. Implement online hard-negative mining within batches
3. Add semi-hard triplet mining
4. Implement curriculum learning (easy → hard negatives)
5. Remove or make same-document heuristic explicit label

See `METHODOLOGICAL_ISSUES.md` Issue #4 for code examples."""
    }
]

# Note: Only creating first 4 issues as examples
# Full script would include all 13 issues

def create_issue_via_proxy(issue_data):
    """Attempt to create issue using git proxy."""
    try:
        # Try using curl with proxy
        cmd = [
            "curl", "-X", "POST",
            "-H", "Content-Type: application/json",
            f"{PROXY_URL}/api/repos/{REPO_OWNER}/{REPO_NAME}/issues",
            "-d", json.dumps(issue_data)
        ]

        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

        if result.returncode == 0:
            print(f"✓ Created: {issue_data['title']}")
            return True
        else:
            print(f"✗ Failed: {issue_data['title']}")
            print(f"  Error: {result.stderr}")
            return False

    except Exception as e:
        print(f"✗ Error creating issue: {e}")
        return False

def main():
    """Create all GitHub issues."""
    print("Creating GitHub issues from methodological review...")
    print(f"Repository: {REPO_OWNER}/{REPO_NAME}")
    print()

    success_count = 0

    for i, issue in enumerate(issues, 1):
        print(f"[{i}/{len(issues)}] Creating issue...")
        if create_issue_via_proxy(issue):
            success_count += 1
        print()

    print("=" * 50)
    print(f"✓ Successfully created {success_count}/{len(issues)} issues")
    print("=" * 50)
    print()
    print("Note: This script only creates the first 4 example issues.")
    print("See create_issues_from_review.sh for full list or")
    print("manually create remaining issues from METHODOLOGICAL_ISSUES.md")

if __name__ == "__main__":
    main()

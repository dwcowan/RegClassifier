#!/bin/bash
# Script to create GitHub issues from METHODOLOGICAL_ISSUES.md
# This script requires gh CLI to be installed
# Run: ./create_issues_from_review.sh

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed"
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo "Alternatively, manually create issues from METHODOLOGICAL_ISSUES.md"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not in a git repository"
    exit 1
fi

echo "Creating GitHub issues from methodological review..."
echo ""

# Issue 1: Data Leakage (CRITICAL)
gh issue create \
  --title "[CRITICAL] Data Leakage in Evaluation - Weak Labels Used as Ground Truth" \
  --label "methodology,critical,evaluation,data-leakage" \
  --body "## Problem

The evaluation methodology suffers from severe data leakage that invalidates performance claims.

### Current Implementation
1. **Weak labels** are generated via keyword matching (\`+reg/weak_rules.m\`)
2. These weak labels are used to:
   - Train the classifier
   - Define positive sets for retrieval evaluation (\`posSets\`)
   - Optimize decision thresholds in \`+reg/predict_multilabel.m\`
   - Evaluate retrieval metrics (Recall@K, mAP, nDCG@10)

### Why This Is Invalid
- **Circular validation**: We evaluate how well the model retrieves items labeled by the same weak rules used for training
- **Optimistic bias**: Metrics will be artificially high because we're measuring agreement with noisy labels, not true performance
- **Threshold calibration leakage**: \`predict_multilabel.m\` optimizes thresholds on the training data using weak labels (lines 12-26)

### Files Affected
- \`+reg/weak_rules.m\`
- \`+reg/eval_retrieval.m\`
- \`+reg/metrics_ndcg.m\`
- \`+reg/predict_multilabel.m\`
- \`+reg/ft_train_encoder.m\`
- \`+reg/eval_per_label.m\`
- \`reg_eval_and_report.m\`
- \`reg_eval_gold.m\`

### Recommendations
1. Create held-out ground-truth labeled validation/test sets (minimum 500-1000 chunks)
2. Use weak labels ONLY for training/bootstrapping
3. Evaluate ONLY on human-annotated ground truth
4. Add stratified cross-validation based on true labels
5. Report inter-annotator agreement metrics

See \`METHODOLOGICAL_ISSUES.md\` for full details.
" && echo "✓ Created issue #1: Data Leakage"

# Issue 2: Weak Supervision (CRITICAL)
gh issue create \
  --title "[CRITICAL] Weak Supervision - Naive Keyword Matching Without Context" \
  --label "methodology,critical,weak-supervision,nlp" \
  --body "## Problem

The weak labeling system (\`+reg/weak_rules.m\`) uses overly simplistic keyword matching that produces noisy, unreliable labels.

### Specific Issues
1. **No Negation Handling**: \"This is not an IRB approach\" matches \"IRB\" (FALSE POSITIVE)
2. **Substring Matching Errors**: \"AML\" in \"AMALGAMATION\" matches
3. **No Keyword Weighting**: All matches get fixed 0.9 confidence
4. **No Multi-Word Phrase Matching**: \"credit risk\" matches words separately
5. **Context-Free**: Ignores sentence boundaries and surrounding words
6. **Fixed Confidence**: No variation based on keyword quality or frequency

### Files Affected
- \`+reg/weak_rules.m\` (lines 1-36)
- \`gold/sample_gold_labels.json\`

### Recommendations
1. Add negation detection (spaCy or simple window-based)
2. Use word boundary matching: \`\\bkeyword\\b\` regex
3. Weight keywords by specificity (IDF-like weighting)
4. Require phrase-level matching for multi-word terms
5. Implement rule confidence based on keyword specificity
6. Validate against manually labeled subset (200-500 chunks)

See \`METHODOLOGICAL_ISSUES.md\` Issue #2 for detailed fixes.
" && echo "✓ Created issue #2: Weak Supervision"

# Issue 3: Multi-Label Classification (CRITICAL)
gh issue create \
  --title "[CRITICAL] Multi-Label Classification - Missing Label Dependency Modeling" \
  --label "methodology,critical,machine-learning,multi-label" \
  --body "## Problem

The multi-label classifier uses one-vs-rest logistic regression which ignores label dependencies and co-occurrence patterns.

### Issues
1. **No Label Correlation Modeling**: Treats labels as independent (IRB and CreditRisk are correlated)
2. **No Cross-Validation Stratification**: Random K-fold splits don't preserve label distribution
3. **Threshold Optimization Issues**: Optimizes F1 per label independently using weak labels
4. **No Handling of Label Imbalance**: Skips labels with <3 examples silently

### Files Affected
- \`+reg/train_multilabel.m\` (lines 1-14)
- \`+reg/predict_multilabel.m\` (lines 12-26)
- \`reg_pipeline.m\`

### Recommendations
1. Use classifier chains or label powerset methods
2. Implement stratified multi-label cross-validation (IterativeStratification)
3. Add label co-occurrence features to input
4. Use class weights or resampling for imbalanced labels
5. Optimize thresholds jointly, not independently

See \`METHODOLOGICAL_ISSUES.md\` Issue #3 for implementation examples.
" && echo "✓ Created issue #3: Multi-Label Classification"

# Issue 4: Contrastive Learning (HIGH)
gh issue create \
  --title "[HIGH] Contrastive Learning - Suboptimal Triplet Construction" \
  --label "methodology,high,machine-learning,contrastive-learning" \
  --body "## Problem

Triplet construction and hard-negative mining strategies are suboptimal, leading to inefficient contrastive learning.

### Issues
1. **Single Positive Per Anchor**: Only 1 of potentially 50+ positives used per epoch
2. **Random Negative Sampling**: Not informative (easy negatives don't help learning)
3. **Hard-Negative Mining Timing**: Happens AFTER gradient update, not during batch sampling
4. **Same-Document Heuristic**: May introduce noise (assumes all chunks from same doc are similar)
5. **MaxTriplets Cap**: May truncate important examples without prioritization

### Files Affected
- \`+reg/ft_build_contrastive_dataset.m\` (lines 33-37)
- \`+reg/build_pairs.m\`
- \`+reg/ft_train_encoder.m\` (hard-negative mining lines 322-358)

### Recommendations
1. Use multiple positives per anchor (5-10 instead of 1)
2. Implement online hard-negative mining within batches
3. Add semi-hard triplet mining (d(a,p) < d(a,n) < d(a,p) + margin)
4. Implement curriculum learning (easy → hard negatives)
5. Remove or make same-document heuristic explicit label

See \`METHODOLOGICAL_ISSUES.md\` Issue #4 for code examples.
" && echo "✓ Created issue #4: Contrastive Learning"

# Issue 5: Statistical Rigor (HIGH)
gh issue create \
  --title "[HIGH] Statistical Rigor - Missing Significance Testing and Confidence Intervals" \
  --label "methodology,high,statistics,evaluation" \
  --body "## Problem

No statistical testing or uncertainty quantification in evaluation, making it impossible to determine if improvements are significant or due to random variation.

### Issues
1. **No Significance Testing**: Cannot determine if baseline vs. projection vs. fine-tuned differences are real
2. **No Confidence Intervals**: Metrics reported as point estimates only
3. **No Variance Across Runs**: Training not repeated with different seeds
4. **No Power Analysis**: Gold pack size (~50-200) may be insufficient for reliable measurement
5. **Incomplete Seed Management**: \`+reg/set_seeds.m\` is stub, \`parfor\` introduces non-determinism

### Files Affected
- \`+reg/eval_retrieval.m\`
- \`+reg/metrics_ndcg.m\`
- \`+reg/eval_per_label.m\`
- \`reg_eval_and_report.m\`
- \`+reg/set_seeds.m\`

### Recommendations
1. Implement paired t-test / Wilcoxon signed-rank for method comparisons
2. Add bootstrap confidence intervals (95% CI)
3. Run experiments 5-10 times with different seeds, report mean ± std
4. Implement proper seed management for CPU and GPU
5. Conduct power analysis for sample size determination
6. Report: \"Recall@10: 0.82 ± 0.03 (p < 0.001*)\"

See \`METHODOLOGICAL_ISSUES.md\` Issue #5 for implementation details.
" && echo "✓ Created issue #5: Statistical Rigor"

# Issue 6: Feature Engineering (HIGH)
gh issue create \
  --title "[HIGH] Feature Engineering - Unnormalized Concatenation of Heterogeneous Features" \
  --label "methodology,high,machine-learning,feature-engineering" \
  --body "## Problem

Features from different modalities (TF-IDF sparse, LDA dense, BERT embeddings dense) are concatenated without normalization, leading to scale imbalance.

### Issues
1. **Scale Imbalance**:
   - TF-IDF: Unbounded, values > 10 possible
   - LDA: Bounded in [0,1]
   - BERT: L2-normalized, values ~ [-1,1]
2. **Logistic Regression Sensitivity**: Features with larger magnitude dominate loss function
3. **No Feature Scaling**: No standardization or normalization applied
4. **No Ablation Study**: No evidence that all three modalities are necessary

### Files Affected
- \`+reg/ta_features.m\` (line 21: TF-IDF computation)
- \`reg_pipeline.m\` (feature concatenation)
- \`+reg/train_multilabel.m\`

### Recommendations
1. L2-normalize each modality before concatenation
2. Alternatively: Z-score standardization per feature
3. Consider feature weighting by importance
4. Conduct ablation study: TF-IDF only, BERT only, combinations
5. Consider late fusion (separate classifiers, combined predictions)

Example:
\`\`\`matlab
% L2-normalize TF-IDF
Xtfidf_norm = Xtfidf ./ sqrt(sum(Xtfidf.^2, 2));
features = [Xtfidf_norm, sparse(topicDist_norm), E_norm];
\`\`\`

See \`METHODOLOGICAL_ISSUES.md\` Issue #6 for complete fix.
" && echo "✓ Created issue #6: Feature Engineering"

# Issue 7: Evaluation Metrics (HIGH)
gh issue create \
  --title "[HIGH] Evaluation Metrics - Binary Relevance in nDCG Ignores Graded Judgments" \
  --label "methodology,high,evaluation,metrics" \
  --body "## Problem

nDCG implementation treats relevance as binary (0 or 1), losing the benefit of nDCG which is designed for graded relevance judgments.

### Current Implementation
\`+reg/metrics_ndcg.m\` line 15:
\`\`\`matlab
rel = ismember(ord, pos);  % Binary: 1 if relevant, 0 otherwise
\`\`\`

### Issue
- nDCG designed for multi-level relevance: highly (2), somewhat (1), not (0)
- Current: relevant (1) or not (0)
- In regulatory retrieval, some chunks more relevant than others:
  - Highly relevant: Direct answer (e.g., IRB calibration formula)
  - Somewhat relevant: Related but not directly applicable
  - Not relevant: Different topic

### Files Affected
- \`+reg/metrics_ndcg.m\` (lines 15-20)
- \`gold/\` directory (need graded annotations)

### Recommendations
1. Add graded relevance to gold pack (0/1/2 scale)
2. Modify nDCG to use graded relevance: DCG = Σ((2^rel - 1) / log₂(i+1))
3. Define annotation protocol for relevance grades
4. Measure inter-annotator agreement on graded judgments
5. Report both binary and graded nDCG

See \`METHODOLOGICAL_ISSUES.md\` Issue #7 for implementation.
" && echo "✓ Created issue #7: Evaluation Metrics"

# Issue 8: Hyperparameter Tuning (MEDIUM)
gh issue create \
  --title "[MEDIUM] Hyperparameter Tuning - No Systematic Search or Validation" \
  --label "methodology,medium,hyperparameters,validation" \
  --body "## Problem

Hyperparameters (learning rates, layer unfreezing, margins, batch sizes) are set heuristically without systematic search or validation-based tuning.

### Issues
1. **EncoderLR (2e-5)**: Standard for BERT, but not validated for regulatory text
2. **HeadLR (1e-3)**: 50x higher than encoder, ratio not tuned
3. **UnfreezeTopLayers (4)**: No ablation (2 vs 4 vs 6 vs 12 layers)
4. **Triplet Margin (0.2)**: Common default, task-specific optimal unknown
5. **NT-Xent Temperature (0.07)**: Hardcoded, not exposed in config
6. **Projection Head (768→512→384)**: Architecture not validated

### Files Affected
- \`+reg/ft_train_encoder.m\` (line 283: hardcoded temperature)
- \`knobs.json\`, \`params.json\`

### Recommendations
1. Implement grid search / random search / Bayesian optimization
2. Use MATLAB's \`bayesopt\` for efficient search
3. Add learning rate scheduling (warmup + decay)
4. Conduct ablation studies for architecture choices
5. Tune on validation set, report on test set
6. Expose all hyperparameters in configuration
7. Document sensitivity analysis

See \`METHODOLOGICAL_ISSUES.md\` Issue #8 for search implementations.
" && echo "✓ Created issue #8: Hyperparameter Tuning"

# Issue 9: Clustering Evaluation (MEDIUM)
gh issue create \
  --title "[MEDIUM] Clustering Evaluation - Inappropriate for Multi-Label Settings" \
  --label "methodology,medium,evaluation,clustering" \
  --body "## Problem

Clustering evaluation uses k-means and purity metric, both of which are ill-suited for multi-label data.

### Issues
1. **Single Label Assumption**: Line 15 \`max(labelsLogical)\` collapses multi-label to single label
2. **K-Means Assumption**: Assigns each item to ONE cluster (inappropriate for multi-label)
3. **Number of Clusters**: \`sqrt(N/10)\` formula is ad-hoc
4. **Purity Metric**: Increases trivially with more clusters, doesn't account for multi-label
5. **Silhouette**: Valid for k-means but doesn't validate multi-label structure

### Files Affected
- \`+reg/eval_clustering.m\` (lines 1-35)

### Recommendations
1. Use multi-label clustering (Fuzzy C-Means, hierarchical)
2. Implement multi-label aware metrics:
   - Label co-occurrence preservation score
   - Label distribution KL divergence
   - Multi-label purity (micro/macro)
3. kNN classification evaluation
4. Visualize with t-SNE/UMAP colored by label combinations

See \`METHODOLOGICAL_ISSUES.md\` Issue #9 for multi-label metric implementations.
" && echo "✓ Created issue #9: Clustering Evaluation"

# Issue 10: Gold Pack (MEDIUM)
gh issue create \
  --title "[MEDIUM] Gold Pack - Insufficient Size and Scope for Robust Evaluation" \
  --label "methodology,medium,evaluation,gold-standard" \
  --body "## Problem

The gold pack is too small (50-200 chunks) and covers only 5 of 14 labels, limiting its utility for robust evaluation.

### Issues
1. **Sample Size**: 50-200 chunks insufficient (standard IR test collections: 1000s)
2. **Label Coverage**: Only 5/14 labels (36%): IRB, Liquidity_LCR, AML_KYC, Securitisation, LeverageRatio
3. **Simulated Data**: Generated from synthetic data, may not reflect real regulatory text
4. **Fixed Thresholds**: 0.8, 0.6 appear arbitrary without justification
5. **No Inter-Annotator Agreement**: No protocol or quality metrics
6. **No Graded Relevance**: Binary labels only

### Files Affected
- \`gold/\` directory
- \`gold/sample_gold_labels.json\`
- \`gold/expected_metrics.json\`

### Recommendations
1. Expand to 1000-2000 labeled chunks minimum
2. Include all 14 regulatory topic labels
3. Use real regulatory text (CRR, Basel III, EBA guidelines)
4. Annotation protocol:
   - 2-3 annotators per chunk
   - Measure inter-annotator agreement (Fleiss' kappa ≥ 0.7)
   - Graded relevance (0/1/2)
5. Split: 500 dev / 1000 test (stratified)
6. Use active learning to reduce annotation cost

See \`METHODOLOGICAL_ISSUES.md\` Issue #10 for annotation process.
" && echo "✓ Created issue #10: Gold Pack"

# Issue 11: Reproducibility (LOW)
gh issue create \
  --title "[LOW] Reproducibility - Incomplete Seed Management and Non-Determinism" \
  --label "methodology,low,reproducibility,engineering" \
  --body "## Problem

Incomplete random seed management and use of parallel processing may cause non-reproducible results.

### Issues
1. \`+reg/set_seeds.m\` is stub (not implemented)
2. Some functions use \`rng(seed)\` locally but not consistently
3. \`parfor\` loops may introduce non-determinism
4. GPU random number generation not seeded

### Files Affected
- \`+reg/set_seeds.m\`
- All main workflow scripts

### Recommendations
1. Implement \`set_seeds.m\`:
\`\`\`matlab
function set_seeds(seed)
    rng(seed, 'twister');
    if gpuDeviceCount > 0
        gpurng(seed, 'Philox4x32-10');
    end
end
\`\`\`
2. Call at start of all workflows
3. Document non-determinism sources (parfor, GPU ops)
4. Provide deterministic mode (disable parfor)

See \`METHODOLOGICAL_ISSUES.md\` Issue #11.
" && echo "✓ Created issue #11: Reproducibility"

# Issue 12: Configuration Management (LOW)
gh issue create \
  --title "[LOW] Configuration Management - Incomplete Knobs Integration" \
  --label "methodology,low,engineering,configuration" \
  --body "## Problem

\`knobs.json\` loading is incomplete (\`config.m\` lines 67-68 have TODO comment).

### Current State
\`\`\`matlab
% config.m lines 67-68
% TODO: implement reg.load_knobs to populate C.knobs
C.knobs = struct();
\`\`\`

### Impact
- Users cannot easily tune hyperparameters via \`knobs.json\`
- Must edit code directly instead of configuration files

### Files Affected
- \`+reg/load_knobs.m\` (implement)
- \`config.m\`
- \`+reg/validate_knobs.m\` (implement validation)

### Recommendations
1. Implement \`+reg/load_knobs.m\`
2. Apply knobs in \`config.m\`
3. Validate knobs (required fields, value ranges)

See \`METHODOLOGICAL_ISSUES.md\` Issue #12.
" && echo "✓ Created issue #12: Configuration Management"

# Issue 13: Hybrid Search (LOW)
gh issue create \
  --title "[LOW] Hybrid Search - Hardcoded Fusion Weight and BM25 Approximation" \
  --label "methodology,low,search,retrieval" \
  --body "## Problem

Hybrid search uses hardcoded 50/50 fusion weight and TF-IDF approximation instead of proper BM25.

### Issues
1. Hardcoded α = 0.5 (optimal weight may differ)
2. TF-IDF ≠ BM25 (missing document length normalization, saturation)

### Files Affected
- \`+reg/hybrid_search.m\` (line 45)

### Recommendations
1. Learn fusion weight α via validation set optimization
2. Implement proper BM25 with k1=1.5, b=0.75 parameters
3. Add BM25 saturation function

See \`METHODOLOGICAL_ISSUES.md\` Issue #13.
" && echo "✓ Created issue #13: Hybrid Search"

echo ""
echo "========================================="
echo "✓ Successfully created 13 GitHub issues!"
echo "========================================="
echo ""
echo "Summary:"
echo "  CRITICAL: 3 issues (#1-3)"
echo "  HIGH:     4 issues (#4-7)"
echo "  MEDIUM:   3 issues (#8-10)"
echo "  LOW:      3 issues (#11-13)"
echo ""
echo "View issues: gh issue list"
echo "Full details: METHODOLOGICAL_ISSUES.md"

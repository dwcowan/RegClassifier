# Methodological Issues - RegClassifier

**Generated:** 2026-02-03
**Review Type:** Comprehensive Methodological Review
**Severity Levels:** CRITICAL, HIGH, MEDIUM, LOW

---

## CRITICAL ISSUES

### Issue 1: Data Leakage in Evaluation - Weak Labels Used as Ground Truth

**Severity:** CRITICAL
**Labels:** `methodology`, `critical`, `evaluation`, `data-leakage`

**Problem:**
The evaluation methodology suffers from severe data leakage that invalidates performance claims:

**Current Implementation:**
1. **Weak labels** are generated via keyword matching (`+reg/weak_rules.m`)
2. These weak labels are used to:
   - Train the classifier
   - Define positive sets for retrieval evaluation (`posSets`)
   - Optimize decision thresholds in `+reg/predict_multilabel.m`
   - Evaluate retrieval metrics (Recall@K, mAP, nDCG@10)

**Why This Is Invalid:**
- **Circular validation**: We evaluate how well the model retrieves items labeled by the same weak rules used for training
- **Optimistic bias**: Metrics will be artificially high because we're measuring agreement with noisy labels, not true performance
- **Threshold calibration leakage**: `predict_multilabel.m` optimizes thresholds on the training data using weak labels (lines 12-26)
- **K-fold leakage**: Cross-validation predictions (`kfoldPredict`) are used to tune thresholds on the same folds

**Evidence:**
- `+reg/eval_retrieval.m`: Lines 1-30 - posSets derived from weak labels
- `+reg/ft_train_encoder.m`: Lines 360-387 - evaluation uses Ylogical (weak labels)
- `+reg/predict_multilabel.m`: Lines 12-26 - threshold tuning on Yboot (weak labels)
- `+reg/build_pairs.m`: Lines 16-24 - positive sets from weak labels
- `reg_eval_and_report.m` - entire evaluation pipeline uses weak labels

**Impact:**
- **HIGH SEVERITY**: Reported metrics (Recall@10, mAP, nDCG@10) do not reflect true model performance
- Cannot compare baseline/projection/fine-tuned methods reliably
- Gold pack evaluation also affected (initialized from simulated data)
- Published results would be invalidated

**Recommendations:**
1. **Mandatory**: Create held-out ground-truth labeled validation/test sets (minimum 500-1000 chunks, separate from weak labels)
2. Use weak labels ONLY for training/bootstrapping
3. Evaluate ONLY on human-annotated ground truth
4. Split data: 70% training (weak labels OK), 15% validation (human labels), 15% test (human labels)
5. Optimize thresholds on validation set, report final metrics on test set
6. Add stratified cross-validation based on true labels, not weak labels
7. Report inter-annotator agreement (Cohen's kappa, Fleiss' kappa)
8. Add significance testing between methods (McNemar's test, bootstrap confidence intervals)

**References:**
- Ratner et al. 2017 - "Snorkel: Rapid Training Data Creation with Weak Supervision"
- Bishop 2006 - Pattern Recognition and Machine Learning (Ch 1.3)
- Hastie et al. 2009 - Elements of Statistical Learning (Ch 7.10)

**Files Affected:**
- `+reg/weak_rules.m`
- `+reg/eval_retrieval.m`
- `+reg/metrics_ndcg.m`
- `+reg/predict_multilabel.m`
- `+reg/ft_train_encoder.m`
- `+reg/eval_per_label.m`
- `reg_eval_and_report.m`
- `reg_eval_gold.m`

---

### Issue 2: Weak Supervision - Naive Keyword Matching Without Context

**Severity:** CRITICAL
**Labels:** `methodology`, `critical`, `weak-supervision`, `nlp`

**Problem:**
The weak labeling system (`+reg/weak_rules.m`) uses overly simplistic keyword matching that produces noisy, unreliable labels.

**Current Implementation (lines 1-36):**
```matlab
- Case-insensitive substring matching: `contains(textStr, keyword)`
- Fixed confidence of 0.9 for any keyword match
- No context awareness, phrase boundaries, or linguistic features
- 14 label categories with hand-picked keywords
```

**Specific Issues:**

1. **No Negation Handling:**
   - "This is not an IRB approach" → matches "IRB" → labeled as IRB (FALSE POSITIVE)
   - "Exclusions from LCR requirements" → matches "LCR" → labeled as Liquidity_LCR (FALSE POSITIVE)

2. **Substring Matching Errors:**
   - "FRTB" in "FRTB_2" or "FRTB-SA" → multiple spurious matches
   - "AML" in "AMALGAMATION" → false positive
   - "SA" (Standardised Approach) is extremely ambiguous

3. **No Keyword Weighting:**
   - "PD" (very common, ambiguous) gets same confidence as "slotting" (specific)
   - High-quality signals (e.g., "Article 180") treated same as noisy signals

4. **No Multi-Word Phrase Matching:**
   - "credit risk" matches both words separately, not as a phrase
   - "stress test" could match "stress" in unrelated context + "test" elsewhere

5. **Context-Free:**
   - Ignores sentence boundaries
   - No consideration of surrounding words
   - "IRB" in footnote vs. main regulatory text treated identically

6. **Fixed Confidence:**
   - All matches → 0.9 confidence regardless of:
     - Keyword frequency in document
     - Keyword specificity
     - Presence of multiple keywords for same label
     - Document structure/context

**Impact:**
- High label noise propagates to all downstream models
- Weak label quality directly determines model quality (GIGO)
- No quantification of label noise levels
- Cannot identify which labels are unreliable

**Recommendations:**

1. **Immediate fixes:**
   - Add negation detection: spaCy dependency parsing or simple "not/no/without" windows
   - Use word boundary matching: `\bkeyword\b` regex instead of `contains()`
   - Weight keywords by specificity (IDF-like weighting)
   - Require phrase-level matching for multi-word terms

2. **Medium-term improvements:**
   - Implement rule confidence based on:
     - Keyword specificity (inverse document frequency)
     - Number of matching keywords per label
     - Document structure (main text vs. footnote vs. table)
   - Add rule conflict resolution (what if doc matches IRB and CreditRisk?)
   - Use spaCy or similar for linguistic features (POS tags, NER, dependency parsing)

3. **Long-term (research-grade):**
   - Learn keyword weights from labeled data
   - Use pre-trained NER models for regulatory entity recognition
   - Implement Snorkel-style label function learning
   - Add adversarial debiasing for keyword noise
   - Use active learning to identify and label high-uncertainty examples

4. **Validation:**
   - Manually label 200-500 chunks as gold standard
   - Compute weak label precision/recall against gold
   - Report label noise levels per category
   - Analyze failure modes (false positive/negative patterns)

**Example Fix (Pseudo-code):**
```matlab
% Instead of:
hit = hit | contains(textStr, lower(pats(p)));

% Use:
pattern = ['\b' regexptranslate('escape', lower(pats(p))) '\b'];
hit = hit | ~cellfun(@isempty, regexp(textStr, pattern));

% Add negation check:
negation_window = {'not', 'no', 'without', 'except', 'excluding'};
for neg = negation_window
    if contains(textStr, [neg + " " + pats(p)])
        hit = false;  % negated match
    end
end
```

**Files Affected:**
- `+reg/weak_rules.m` (primary implementation)
- `gold/sample_gold_labels.json` (keyword definitions)
- All downstream models depend on this

**References:**
- Ratner et al. 2019 - "Weak Supervision: A New Programming Paradigm for Machine Learning"
- Dehghani et al. 2017 - "FUSE: Multi-Faceted Set Expansion by Coherent Clustering of Skip-grams"

---

### Issue 3: Multi-Label Classification - Missing Label Dependency Modeling

**Severity:** HIGH
**Labels:** `methodology`, `machine-learning`, `multi-label`

**Problem:**
The multi-label classifier uses one-vs-rest logistic regression which ignores label dependencies and co-occurrence patterns.

**Current Implementation:**
`+reg/train_multilabel.m` (lines 1-14):
```matlab
% Independent binary classifiers per label
parfor j = 1:labelsK
    models{j} = fitclinear(X, y, 'Learner','logistic', 'KFold', kfold);
end
```

**Issues:**

1. **No Label Correlation Modeling:**
   - IRB and CreditRisk are highly correlated (both relate to credit risk measurement)
   - Liquidity_LCR and Liquidity_NSFR are mutually related
   - One-vs-rest treats labels as independent
   - Missing opportunity to leverage label structure

2. **No Cross-Validation Stratification:**
   - K-fold splits are random, not stratified by label distribution
   - In multi-label settings, need to preserve label co-occurrence patterns
   - Rare labels may have zero support in some folds
   - Line 12: `'KFold', kfold` - no stratification option used

3. **Threshold Optimization Issues:**
   - `+reg/predict_multilabel.m` lines 12-26: Grid search over [0.2, 0.9]
   - Optimizes F1 score per label independently
   - Ignores label interactions
   - Uses weak labels as ground truth (data leakage)

4. **No Handling of Label Imbalance:**
   - Some labels (e.g., AML_KYC) may be very rare
   - Line 7-9: Skips labels with <3 examples (silent failure)
   - No class weighting or resampling strategies

**Impact:**
- Suboptimal multi-label predictions
- Cannot model regulatory topic relationships
- Poor generalization on co-occurring labels
- Missed opportunities for transfer learning across labels

**Recommendations:**

1. **Model Improvements:**
   - Use classifier chains or label powerset methods
   - Implement multi-label neural network (sigmoid output per label)
   - Add label co-occurrence features to input
   - Use structured prediction (CRF, structured SVM)

2. **Cross-Validation:**
   - Implement stratified multi-label cross-validation (IterativeStratification)
   - Ensure each fold preserves label distribution
   - Handle rare labels with special care

3. **Threshold Calibration:**
   - Use Platt scaling or isotonic regression for probability calibration
   - Optimize thresholds jointly, not independently
   - Use proper validation set (not training data)
   - Consider macro-F1 or micro-F1 optimization

4. **Class Imbalance:**
   - Add class weights: `'ClassWeight', 'balanced'` or custom weights
   - Use SMOTE or ADASYN for oversampling rare labels
   - Report per-label performance (already done in `eval_per_label.m`)

**Example Fix:**
```matlab
% Use multi-label k-fold with stratification
import iterative_stratification.*  % hypothetical MATLAB equivalent

% Build label co-occurrence features
label_cooccur = Yboot' * Yboot;  % L x L matrix
cooccur_features = Yboot * label_cooccur;  % N x L features
X_augmented = [X, cooccur_features];

% Classifier chains
models = cell(labelsK, 1);
for j = 1:labelsK
    % Add predictions from previous labels as features
    if j > 1
        X_with_chain = [X, Yboot(:, 1:j-1)];
    else
        X_with_chain = X;
    end
    models{j} = fitclinear(X_with_chain, Yboot(:,j), ...
        'Learner', 'logistic', ...
        'ClassWeight', 'balanced');
end
```

**Files Affected:**
- `+reg/train_multilabel.m`
- `+reg/predict_multilabel.m`
- `reg_pipeline.m` (orchestration)

**References:**
- Read et al. 2011 - "Classifier chains for multi-label classification"
- Tsoumakas & Katakis 2007 - "Multi-label classification: An overview"
- Szyma'nski & Kajdanowicz 2017 - "A scikit-learn compatible package for multi-label classification"

---

### Issue 4: Contrastive Learning - Suboptimal Triplet Construction

**Severity:** HIGH
**Labels:** `methodology`, `machine-learning`, `contrastive-learning`, `fine-tuning`

**Problem:**
Triplet construction and hard-negative mining strategies are suboptimal, leading to inefficient contrastive learning.

**Current Implementation:**

**`+reg/ft_build_contrastive_dataset.m` (lines 1-42):**
```matlab
% Only ONE positive per anchor per epoch
pidx = pos(randi(numel(pos)));

% Random negative sampling (not informative)
negCandidates = find(overlap==0 & (1:N)'~=i);
nidx = negCandidates(randi(numel(negCandidates)));
```

**`+reg/ft_train_encoder.m` Hard-Negative Mining (lines 322-358):**
```matlab
% Mining happens AFTER gradient update
% Not integrated into batch sampling
% Only updates negatives, doesn't resample triplets
```

**Issues:**

1. **Single Positive Per Anchor:**
   - Line 33: `pidx = pos(randi(numel(pos)))`
   - Wastes informative positive pairs
   - If anchor has 50 positives, only 1 is used per epoch
   - No hardest-positive mining (semi-hard triplets)

2. **Random Negative Sampling:**
   - Line 35-37: Uniform random from `overlap==0` candidates
   - Not informative (easy negatives don't help learning)
   - Misses opportunity for hard-negative mining from start

3. **Hard-Negative Mining Timing:**
   - Lines 158-168: Mining happens at epoch start (AFTER previous epoch's gradient updates)
   - Should be integrated into mini-batch sampling
   - Mining uses `maxN=2000` subset (line 64, 326) - may miss global hard negatives

4. **Same-Document Heuristic:**
   - Line 23-24: `sameDoc = find(chunksT.doc_id == chunksT.doc_id(i))`
   - Assumes chunks from same document are semantically similar
   - May not hold for long regulatory documents covering multiple topics
   - Could introduce noise

5. **MaxTriplets Cap:**
   - Line 39: `if size(trip,2) >= R.MaxTriplets, break; end`
   - Default 300,000 triplets
   - May truncate important examples
   - No prioritization of which triplets to keep

6. **No Semi-Hard Mining:**
   - Standard triplet loss benefits from semi-hard negatives:
     `d(anchor, pos) < d(anchor, neg) < d(anchor, pos) + margin`
   - Current implementation doesn't select these explicitly

**Impact:**
- Slower convergence during fine-tuning
- Suboptimal embedding space
- Inefficient use of training data (1/Nth positives used per epoch if N positives exist)
- May not learn fine-grained distinctions between similar regulatory topics

**Recommendations:**

1. **Multiple Positives Per Anchor:**
   ```matlab
   % Instead of one positive:
   num_pos_per_anchor = min(5, numel(pos));  % use up to 5 positives
   selected_pos = pos(randperm(numel(pos), num_pos_per_anchor));

   % Create multiple triplets per anchor
   for each positive:
       create triplet(anchor, positive, negative)
   ```

2. **Online Hard-Negative Mining:**
   - Compute embeddings for current mini-batch
   - Find hardest negative within batch (highest cosine similarity among negatives)
   - Update triplet negatives dynamically

3. **Semi-Hard Triplet Mining:**
   ```matlab
   % Select negatives where:
   % d(a,p) < d(a,n) < d(a,p) + margin
   valid_negatives = negatives where:
       cosine(anchor, neg) > cosine(anchor, pos) AND
       cosine(anchor, neg) < cosine(anchor, pos) + margin
   ```

4. **Curriculum Learning:**
   - Start with easy negatives (random sampling)
   - Gradually increase difficulty (hard-negative mining)
   - Adjust margin over time

5. **Remove Same-Document Heuristic:**
   - Only use label-based positives
   - If document-level continuity is important, add it as an explicit label
   - Or use contiguous chunk pairs (chunk_i, chunk_i+1) as separate positive source

6. **Prioritize Triplets:**
   - If capping at MaxTriplets, prioritize:
     - Rare labels (higher weight)
     - Diverse anchor-positive pairs
     - Semi-hard configurations

**Example Fix:**
```matlab
function P = ft_build_contrastive_dataset(chunksT, Ylogical, varargin)
    % ... existing setup ...

    % Build multiple triplets per anchor
    trip = zeros(3,0,'uint32');
    for i = 1:N
        pos = posSets{i};
        if numel(pos) < R.MinPosPerAnchor, continue; end

        % Select multiple positives
        num_pos = min(R.MaxPositivesPerAnchor, numel(pos));
        selected_pos = pos(randperm(numel(pos), num_pos));

        % For each positive, create triplet
        for p = selected_pos
            % Find semi-hard negative
            overlap = labels * labels(i,:)';
            negCandidates = find(overlap==0 & (1:N)'~=i);
            if isempty(negCandidates), continue; end

            % Hardest negative (if embeddings available from previous epoch)
            if exist('prev_embeddings', 'var')
                sims = prev_embeddings(negCandidates,:) * prev_embeddings(i,:)';
                [~, hardest_idx] = max(sims);
                nidx = negCandidates(hardest_idx);
            else
                nidx = negCandidates(randi(numel(negCandidates)));
            end

            trip(:,end+1) = uint32([i; p; nidx]);
            if size(trip,2) >= R.MaxTriplets, break; end
        end
        if size(trip,2) >= R.MaxTriplets, break; end
    end

    P.anchor = trip(1,:);
    P.positive = trip(2,:);
    P.negative = trip(3,:);
end
```

**Files Affected:**
- `+reg/ft_build_contrastive_dataset.m`
- `+reg/build_pairs.m` (projection head triplets)
- `+reg/ft_train_encoder.m` (hard-negative mining function)

**References:**
- Schroff et al. 2015 - "FaceNet: A Unified Embedding for Face Recognition and Clustering"
- Hermans et al. 2017 - "In Defense of the Triplet Loss for Person Re-Identification"
- Xuan et al. 2020 - "Hard Negative Mixing for Contrastive Learning"

---

## HIGH PRIORITY ISSUES

### Issue 5: Statistical Rigor - Missing Significance Testing and Confidence Intervals

**Severity:** HIGH
**Labels:** `methodology`, `statistics`, `evaluation`

**Problem:**
No statistical testing or uncertainty quantification in evaluation, making it impossible to determine if improvements are significant or due to random variation.

**Current Issues:**

1. **No Significance Testing:**
   - Baseline vs. Projection vs. Fine-tuned comparisons report point estimates only
   - No hypothesis testing (paired t-test, Wilcoxon signed-rank, McNemar's test)
   - Cannot determine if differences are statistically significant
   - Example: If Recall@10 improves from 0.82 → 0.84, is this real or noise?

2. **No Confidence Intervals:**
   - Metrics (Recall@10, mAP, nDCG@10) reported as single numbers
   - No bootstrap confidence intervals or standard errors
   - Cannot assess uncertainty in estimates

3. **No Variance Across Runs:**
   - Training runs not repeated with different random seeds
   - Stochastic components:
     - Random negative sampling
     - K-fold splits
     - Mini-batch sampling
     - Layer initialization (if not using pretrained BERT)
   - Single run may be lucky/unlucky

4. **No Power Analysis:**
   - Gold pack has ~50-200 labeled chunks (very small)
   - No calculation of statistical power to detect meaningful differences
   - May not have enough data to reliably measure improvements

5. **Seed Management:**
   - `+reg/set_seeds.m` is a stub (not implemented)
   - `rng(R.Seed)` used in some places but not consistently
   - Parallel processing (`parfor`) may introduce non-determinism

**Evidence:**
- `reg_eval_and_report.m`: Reports metrics table without confidence intervals
- `+reg/eval_retrieval.m`: Returns point estimates only
- `+reg/metrics_ndcg.m`: No uncertainty quantification
- Gold pack `expected_metrics.json`: Hard thresholds without variance tolerance

**Impact:**
- Cannot conclude if projection head or fine-tuning actually improve performance
- Risk of publishing false positive results
- Cannot compare to other methods reliably
- Difficult to reproduce results

**Recommendations:**

1. **Implement Significance Testing:**
   ```matlab
   % For paired comparisons (same queries, different methods)
   [h, p] = ttest(recall_baseline, recall_finetuned);  % paired t-test

   % Or for non-parametric:
   p = signrank(recall_baseline, recall_finetuned);  % Wilcoxon

   % For binary metrics (Recall@K):
   % McNemar's test on hit/miss matrix
   ```

2. **Bootstrap Confidence Intervals:**
   ```matlab
   function [ci_lower, ci_upper] = bootstrap_ci(metric_fn, data, alpha)
       % metric_fn: function handle to compute metric
       % data: input data for metric
       % alpha: significance level (default 0.05)

       B = 10000;  % bootstrap samples
       boot_stats = zeros(B, 1);
       N = size(data, 1);

       for b = 1:B
           sample_idx = randi(N, N, 1);  % resample with replacement
           boot_data = data(sample_idx, :);
           boot_stats(b) = metric_fn(boot_data);
       end

       ci_lower = prctile(boot_stats, alpha/2 * 100);
       ci_upper = prctile(boot_stats, (1-alpha/2) * 100);
   end
   ```

3. **Multiple Runs:**
   - Run each experiment 5-10 times with different seeds
   - Report mean ± std dev
   - Use boxplots to show distribution

4. **Proper Seed Management:**
   - Implement `+reg/set_seeds.m`:
   ```matlab
   function set_seeds(seed)
       rng(seed, 'twister');  % MATLAB RNG
       gpurng(seed, 'Philox4x32-10');  % GPU RNG
       % Note: parfor may still introduce non-determinism
   end
   ```

5. **Power Analysis:**
   - Use G*Power or MATLAB `sampsizepwr` to determine required sample size
   - Report statistical power for detecting meaningful effect sizes
   - Example: "With N=200 samples, we have 80% power to detect a 0.05 difference in Recall@10"

6. **Report Format:**
   ```
   Metric         Baseline      Projection    Fine-tuned    p-value
   Recall@10      0.82 ± 0.03   0.85 ± 0.02   0.87 ± 0.02   <0.001*
   mAP            0.65 ± 0.04   0.68 ± 0.03   0.71 ± 0.03    0.002*
   nDCG@10        0.70 ± 0.04   0.72 ± 0.03   0.75 ± 0.03    0.012*

   * p < 0.05 (paired t-test, Bonferroni corrected)
   ± indicates 95% bootstrap CI
   ```

**Files Affected:**
- `+reg/eval_retrieval.m`
- `+reg/metrics_ndcg.m`
- `+reg/eval_per_label.m`
- `reg_eval_and_report.m`
- `+reg/set_seeds.m` (implement)
- `+reg/+view/ReportView.m` (add CI to tables)

**References:**
- Dror et al. 2018 - "The Hitchhiker's Guide to Testing Statistical Significance in Natural Language Processing"
- Dietterich 1998 - "Approximate Statistical Tests for Comparing Supervised Classification Learning Algorithms"
- Efron & Tibshirani 1994 - "An Introduction to the Bootstrap"

---

### Issue 6: Feature Engineering - Unnormalized Concatenation of Heterogeneous Features

**Severity:** HIGH
**Labels:** `methodology`, `machine-learning`, `feature-engineering`

**Problem:**
Features from different modalities (TF-IDF sparse, LDA dense, BERT embeddings dense) are concatenated without normalization, leading to scale imbalance.

**Current Implementation:**
From documentation and typical pipeline usage:
```matlab
% TF-IDF: sparse, values typically in range [0, 10+] (unnormalized)
Xtfidf = X .* idf;  % from ta_features.m line 21

% LDA: dense, values are probabilities in [0, 1]
topicDist = transform(lda, bag);

% BERT embeddings: dense, L2-normalized to unit norm (values ~ [-1, 1])
E = doc_embeddings_bert_gpu(texts);  % already normalized

% Concatenation (from documentation):
features = [Xtfidf, sparse(topicDist), E];
```

**Issues:**

1. **Scale Imbalance:**
   - TF-IDF: Unbounded, depends on term frequency and document length
     - High-frequency terms can have values > 10
     - Sparse representation with many zeros
   - LDA: Bounded in [0, 1], typically normalized probability distribution
   - BERT: L2-normalized, each dimension ~ [-1, 1], total norm = 1

2. **Logistic Regression Sensitivity:**
   - `fitclinear` (logistic regression) is sensitive to feature scales
   - Features with larger magnitude dominate the loss function
   - TF-IDF features may overwhelm LDA and BERT features
   - Regularization (L2 penalty) affected by scale differences

3. **No Feature Scaling:**
   - No standardization (z-score)
   - No min-max normalization
   - No feature-wise normalization

4. **Sparse/Dense Mixing:**
   - Concatenating sparse (TF-IDF) with dense (LDA, BERT) may be inefficient
   - MATLAB sparse matrices don't play well with some operations

5. **No Ablation Study:**
   - No evidence that all three modalities are necessary
   - TF-IDF and BERT both capture lexical information (redundancy?)
   - No analysis of feature importance or contribution

**Impact:**
- Suboptimal classifier performance
- TF-IDF features likely dominate, reducing benefit of BERT embeddings
- Regularization parameter tuning is complicated by scale differences
- Cannot interpret feature importance reliably

**Recommendations:**

1. **Normalize Each Modality:**
   ```matlab
   % TF-IDF: L2-normalize each document (row)
   Xtfidf_norm = Xtfidf ./ sqrt(sum(Xtfidf.^2, 2));

   % LDA: Already probability distribution, but could L2-normalize
   topicDist_norm = topicDist ./ sqrt(sum(topicDist.^2, 2));

   % BERT: Already L2-normalized (no change needed)
   E_norm = E;

   % Concatenate normalized features
   features = [Xtfidf_norm, sparse(topicDist_norm), E_norm];
   ```

2. **Alternative: Z-Score Standardization:**
   ```matlab
   % Standardize each feature to mean=0, std=1
   % (per feature, across documents)

   Xtfidf_std = (Xtfidf - mean(Xtfidf, 1)) ./ std(Xtfidf, 0, 1);
   topicDist_std = (topicDist - mean(topicDist, 1)) ./ std(topicDist, 0, 1);
   % BERT already normalized, but could standardize if desired

   features = [Xtfidf_std, sparse(topicDist_std), E];
   ```

3. **Feature Weighting:**
   ```matlab
   % Weight each modality by importance
   alpha_tfidf = 0.3;
   alpha_lda = 0.2;
   alpha_bert = 0.5;

   features = [alpha_tfidf * Xtfidf_norm, ...
               alpha_lda * sparse(topicDist_norm), ...
               alpha_bert * E_norm];

   % Learn weights via cross-validation
   ```

4. **Ablation Study:**
   - Train classifiers with:
     - TF-IDF only
     - LDA only
     - BERT only
     - TF-IDF + BERT
     - TF-IDF + LDA
     - BERT + LDA
     - All three
   - Compare performance to determine necessity of each modality

5. **Consider Late Fusion:**
   - Train separate classifiers for each modality
   - Combine predictions (average, weighted average, stacking)
   - May be more effective than early fusion (concatenation)

6. **Dimensionality Considerations:**
   - TF-IDF: Thousands of dimensions (vocab size)
   - LDA: Configurable (e.g., 20-100 topics)
   - BERT: 768 dimensions
   - High-dimensional concatenation may cause overfitting
   - Consider PCA or feature selection

**Example Fix:**
```matlab
function [docsTok, vocab, Xtfidf_norm, topicDist_norm] = ta_features_normalized(textStr, lda_topics)
    % Existing TF-IDF extraction
    [docsTok, vocab, Xtfidf] = reg.ta_features(textStr);

    % L2-normalize TF-IDF (row-wise)
    row_norms = sqrt(sum(Xtfidf.^2, 2));
    row_norms(row_norms == 0) = 1;  % avoid division by zero
    Xtfidf_norm = Xtfidf ./ row_norms;

    % LDA topics (if requested)
    if lda_topics > 0
        bag = bagOfWords(docsTok);
        lda = fitlda(bag, lda_topics);
        topicDist = transform(lda, bag);

        % L2-normalize LDA (row-wise)
        row_norms = sqrt(sum(topicDist.^2, 2));
        row_norms(row_norms == 0) = 1;
        topicDist_norm = topicDist ./ row_norms;
    else
        topicDist_norm = [];
    end
end

% In reg_pipeline.m:
[docsTok, vocab, Xtfidf_norm, topicDist_norm] = reg.ta_features_normalized(chunksT.text, C.lda_topics);
E = reg.precompute_embeddings(chunksT.text, C);  % already normalized
features = [Xtfidf_norm, sparse(topicDist_norm), E];

% Train with normalized features
models = reg.train_multilabel(features, Yboot, C.kfold);
```

**Files Affected:**
- `+reg/ta_features.m` (add normalization)
- `reg_pipeline.m` (feature concatenation)
- `+reg/train_multilabel.m` (receives normalized features)
- Any code that constructs feature matrices

**References:**
- Shalev-Shwartz & Ben-David 2014 - "Understanding Machine Learning" (Ch 13.2 on feature normalization)
- Pedregosa et al. 2011 - "Scikit-learn: Machine Learning in Python" (StandardScaler, Normalizer)
- Raschka 2014 - "About Feature Scaling and Normalization"

---

### Issue 7: Evaluation Metrics - Binary Relevance in nDCG Ignores Graded Judgments

**Severity:** MEDIUM
**Labels:** `methodology`, `evaluation`, `metrics`

**Problem:**
nDCG implementation treats relevance as binary (0 or 1), losing the benefit of nDCG which is designed for graded relevance judgments.

**Current Implementation:**
`+reg/metrics_ndcg.m` (lines 15-20):
```matlab
rel = ismember(ord, pos);  % Binary: 1 if relevant, 0 otherwise
dcg = 0;
for j = 1:numel(ord)
    dcg = dcg + (rel(j) / log2(j+1));  % rel(j) is always 0 or 1
end
```

**Issue:**
- nDCG is designed for multi-level relevance: highly relevant (2), somewhat relevant (1), not relevant (0)
- Current implementation: relevant (1) or not (0)
- In regulatory retrieval, some chunks are more relevant than others:
  - **Highly relevant**: Direct answer to query (e.g., IRB calibration formula)
  - **Somewhat relevant**: Related but not directly applicable (e.g., IRB general principles)
  - **Marginally relevant**: Same topic but different aspect
  - **Not relevant**: Different topic
- Binary relevance doesn't distinguish these nuances

**Impact:**
- nDCG metric is underutilized
- Cannot assess ranking quality properly
- May reward systems that rank marginally relevant items higher than highly relevant ones
- Less informative than it could be

**Recommendations:**

1. **Add Graded Relevance to Gold Pack:**
   ```json
   // In gold/sample_gold_Ytrue.csv or labels.json
   {
       "chunk_id": "CH_001_0",
       "label": "IRB",
       "relevance": 2  // 0 = not relevant, 1 = somewhat, 2 = highly relevant
   }
   ```

2. **Modify nDCG Implementation:**
   ```matlab
   function ndcg = metrics_ndcg_graded(scores, relevanceMatrix, K)
       % relevanceMatrix: N x N matrix where entry (i,j) is relevance of j to query i
       % Values in {0, 1, 2} for not/somewhat/highly relevant

       N = size(scores, 1);
       ndcg_i = zeros(N, 1);

       for i = 1:N
           s = scores(i,:);
           s(i) = -inf;  % remove self
           [~, ord] = sort(s, 'descend');
           ord = ord(1:min(K, end));

           % Get relevance scores (graded)
           rel = relevanceMatrix(i, ord);  % Values in {0, 1, 2}

           % DCG with graded relevance
           dcg = 0;
           for j = 1:numel(ord)
               dcg = dcg + ((2^rel(j) - 1) / log2(j+1));  % Standard nDCG formula
           end

           % IDCG (ideal: sort relevance scores descending)
           ideal_rel = sort(relevanceMatrix(i,:), 'descend');
           ideal_rel = ideal_rel(1:min(K, nnz(relevanceMatrix(i,:))));
           idcg = 0;
           for j = 1:numel(ideal_rel)
               idcg = idcg + ((2^ideal_rel(j) - 1) / log2(j+1));
           end

           if idcg > 0
               ndcg_i(i) = dcg / idcg;
           else
               ndcg_i(i) = 0;
           end
       end

       ndcg = mean(ndcg_i);
   end
   ```

3. **Annotation Protocol:**
   - For gold pack, have annotators assign relevance grades:
     - **2 (Highly relevant)**: Chunk directly addresses the query topic
     - **1 (Somewhat relevant)**: Chunk mentions the topic but not central focus
     - **0 (Not relevant)**: Chunk is about a different topic
   - Compute inter-annotator agreement on graded judgments (weighted kappa)

4. **Alternative Metrics:**
   - If graded relevance is not available, consider:
     - **MRR (Mean Reciprocal Rank)**: Position of first relevant item
     - **Precision@K**: Fraction of top-K that are relevant
     - **MAP**: Already implemented, good for binary relevance
   - Report multiple metrics for comprehensive evaluation

5. **Weak Label Confidence as Relevance:**
   - If no human judgments, use weak label confidence as proxy:
     - Confidence 0.9 → relevance 2
     - Confidence 0.5-0.9 → relevance 1
     - Confidence <0.5 → relevance 0
   - This is a weak proxy but better than binary

**Example Usage:**
```matlab
% In reg_eval_gold.m or evaluation pipeline:

% Option 1: Binary relevance (current)
ndcg_binary = reg.metrics_ndcg(S, posSets, K);

% Option 2: Graded relevance (if available)
% relevanceMatrix(i,j) = how relevant is j to query i
relevanceMatrix = load_graded_relevance('gold/graded_relevance.mat');
ndcg_graded = reg.metrics_ndcg_graded(S, relevanceMatrix, K);

fprintf('nDCG@10 (binary): %.3f\n', ndcg_binary);
fprintf('nDCG@10 (graded): %.3f\n', ndcg_graded);
```

**Files Affected:**
- `+reg/metrics_ndcg.m` (modify or add new function)
- `gold/` directory (add graded relevance annotations)
- Annotation guidelines (specify grading criteria)
- Evaluation scripts (`reg_eval_gold.m`, `reg_eval_and_report.m`)

**References:**
- Järvelin & Kekäläinen 2002 - "Cumulated gain-based evaluation of IR techniques"
- Manning et al. 2008 - "Introduction to Information Retrieval" (Ch 8.4)
- Burges et al. 2005 - "Learning to rank using gradient descent"

---

## MEDIUM PRIORITY ISSUES

### Issue 8: Hyperparameter Tuning - No Systematic Search or Validation

**Severity:** MEDIUM
**Labels:** `methodology`, `hyperparameters`, `validation`

**Problem:**
Hyperparameters (learning rates, layer unfreezing, margins, batch sizes) are set heuristically without systematic search or validation-based tuning.

**Current Implementation:**

**`knobs.json` and `params.json` provide defaults, but:**
- No evidence of grid search, random search, or Bayesian optimization
- Values appear chosen by intuition or literature defaults
- No ablation studies showing sensitivity to hyperparameter choices

**Example Hyperparameters:**
```json
// params.json
{
    "FineTune": {
        "EncoderLR": 2e-5,      // Why 2e-5 specifically?
        "HeadLR": 1e-3,         // Why 1e-3?
        "UnfreezeTopLayers": 4, // Why 4 layers?
        "Margin": 0.2,          // Why 0.2?
        "BatchSize": 32,        // Why 32?
        "Epochs": 5             // Why 5?
    }
}
```

**Issues:**

1. **Encoder Learning Rate (2e-5):**
   - Standard for BERT fine-tuning, but not validated for this task
   - Regulatory text may have different optimal LR than general domain
   - No learning rate scheduling (warmup, decay)

2. **Head Learning Rate (1e-3):**
   - 50x higher than encoder LR
   - Ratio not tuned or justified
   - May cause instability if head learns too fast

3. **UnfreezeTopLayers (4):**
   - Why top 4 layers specifically?
   - No ablation: 2 vs. 4 vs. 6 vs. all 12 layers
   - Trade-off between expressiveness and overfitting not explored

4. **Triplet Margin (0.2):**
   - Common default, but task-specific optimal margin unknown
   - No comparison with other values (0.1, 0.5, 1.0)

5. **Batch Size (32):**
   - Chosen for GPU memory constraints, not learning dynamics
   - Smaller batches → noisier gradients, slower convergence
   - Larger batches → better gradient estimates, but may generalize worse

6. **NT-Xent Temperature (0.07):**
   - Hardcoded in `+reg/ft_train_encoder.m` line 283: `tau = 0.07`
   - Not exposed in configuration
   - Very influential parameter (controls softmax sharpness)
   - No tuning or justification

7. **Projection Head Architecture:**
   - 768 → 512 → 384 dimensions (lines 96-103)
   - Why this specific architecture?
   - No comparison with: 768 → 384 (simpler), 768 → 1024 → 512 → 384 (deeper), etc.

**Impact:**
- Suboptimal model performance
- Cannot claim "best" results without hyperparameter search
- Difficult to reproduce (results may be sensitive to unlucky hyperparameter choices)
- May miss significant improvements

**Recommendations:**

1. **Systematic Hyperparameter Search:**

   **a) Grid Search (exhaustive, expensive):**
   ```matlab
   % Define grid
   encoder_lrs = [1e-5, 2e-5, 5e-5];
   head_lrs = [5e-4, 1e-3, 2e-3];
   unfreeze_layers = [2, 4, 6];
   margins = [0.1, 0.2, 0.5];

   % Search
   best_score = -inf;
   best_config = struct();

   for e_lr = encoder_lrs
       for h_lr = head_lrs
           for n_layers = unfreeze_layers
               for m = margins
                   % Train model with these hyperparameters
                   config = struct('EncoderLR', e_lr, 'HeadLR', h_lr, ...
                                   'UnfreezeTopLayers', n_layers, 'Margin', m);
                   score = train_and_validate(config);

                   if score > best_score
                       best_score = score;
                       best_config = config;
                   end
               end
           end
       end
   end

   % Use best_config for final training
   ```

   **b) Random Search (more efficient):**
   ```matlab
   % Sample from distributions
   n_trials = 50;

   for trial = 1:n_trials
       config.EncoderLR = 10^(unifrnd(-6, -4));  % log-uniform in [1e-6, 1e-4]
       config.HeadLR = 10^(unifrnd(-4, -2));
       config.UnfreezeTopLayers = randi([2, 8]);
       config.Margin = unifrnd(0.1, 1.0);

       score = train_and_validate(config);
       % Track best config
   end
   ```

   **c) Bayesian Optimization (most efficient):**
   ```matlab
   % Use MATLAB's bayesopt

   % Define objective function
   objective = @(params) -train_and_validate(params);  % minimize negative score

   % Define parameter ranges
   params = [
       optimizableVariable('EncoderLR', [1e-6, 1e-4], 'Transform', 'log');
       optimizableVariable('HeadLR', [1e-4, 1e-2], 'Transform', 'log');
       optimizableVariable('UnfreezeTopLayers', [2, 8], 'Type', 'integer');
       optimizableVariable('Margin', [0.1, 1.0]);
   ];

   % Run optimization
   results = bayesopt(objective, params, 'MaxObjectiveEvaluations', 50);
   best_params = results.XAtMinObjective;
   ```

2. **Learning Rate Scheduling:**
   ```matlab
   % Warmup + linear decay
   function lr = lr_schedule(epoch, total_epochs, base_lr, warmup_epochs)
       if epoch <= warmup_epochs
           lr = base_lr * (epoch / warmup_epochs);  % Linear warmup
       else
           lr = base_lr * (1 - (epoch - warmup_epochs) / (total_epochs - warmup_epochs));  % Linear decay
       end
   end
   ```

3. **Ablation Studies:**
   - **Unfreeze layers:** Train with 0, 2, 4, 6, 8, 12 layers unfrozen
   - **Architecture:** Test different projection head depths/widths
   - **Loss functions:** Compare triplet vs. supcon systematically
   - **Margins:** Plot validation performance vs. margin value

4. **Validation-Based Tuning:**
   - Reserve 15% of data as validation set (with ground-truth labels)
   - Tune hyperparameters to maximize validation performance
   - Report final results on held-out test set

5. **Expose All Hyperparameters:**
   ```json
   // params.json - make NT-Xent temperature configurable
   {
       "FineTune": {
           "Temperature": 0.07,  // Add this
           "LRSchedule": "linear_warmup_decay",  // Add scheduling
           "WarmupEpochs": 1,
           "WeightDecay": 0.01  // Add regularization
       }
   }
   ```

6. **Document Hyperparameter Choices:**
   - Add section to documentation explaining each hyperparameter
   - Provide sensitivity analysis plots
   - Report which hyperparameters were tuned vs. defaults

**Example Sensitivity Analysis:**
```matlab
% Study effect of margin on validation nDCG@10
margins = [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0];
val_scores = zeros(size(margins));

for i = 1:numel(margins)
    config.Margin = margins(i);
    netFT = reg.ft_train_encoder(chunksT, P, 'Margin', config.Margin, ...
                                  'EvalY', val_labels);
    metrics = evaluate_on_validation(netFT, val_data);
    val_scores(i) = metrics.ndcg10;
end

figure;
plot(margins, val_scores, '-o');
xlabel('Triplet Margin');
ylabel('Validation nDCG@10');
title('Sensitivity to Margin Hyperparameter');
grid on;
```

**Files Affected:**
- `+reg/ft_train_encoder.m` (add LR scheduling, expose temperature)
- `knobs.json`, `params.json` (add more configurable parameters)
- New file: `+reg/hyperparameter_search.m` (implement search procedures)
- Documentation: `docs/hyperparameter_tuning_guide.md`

**References:**
- Bergstra & Bengio 2012 - "Random Search for Hyper-Parameter Optimization"
- Snoek et al. 2012 - "Practical Bayesian Optimization of Machine Learning Algorithms"
- Devlin et al. 2019 - "BERT: Pre-training of Deep Bidirectional Transformers" (Appendix A.3 - fine-tuning details)

---

### Issue 9: Clustering Evaluation - Inappropriate for Multi-Label Settings

**Severity:** MEDIUM
**Labels:** `methodology`, `evaluation`, `clustering`

**Problem:**
Clustering evaluation uses k-means and purity metric, both of which are ill-suited for multi-label data.

**Current Implementation:**
`+reg/eval_clustering.m` (lines 1-35):
```matlab
% k-means clustering (assumes single cluster per item)
[idx, ~] = kmeans(E, Kclusters, 'Distance', 'cosine');

% Purity: assign each cluster to most common label
[~, y] = max(labelsLogical, [], 2);  % Collapse multi-label to single label (line 15)
% ...
maj = mode(yk);  % Majority vote
purity = purity + sum(yk==maj);
```

**Issues:**

1. **Single Label Assumption:**
   - Line 15: `[~, y] = max(labelsLogical, [], 2)`
   - Collapses multi-label to single label by taking argmax
   - Arbitrary tie-breaking (first label wins if equal scores)
   - Loses multi-label structure

2. **K-Means Assumption:**
   - K-means assigns each item to exactly ONE cluster
   - Regulatory chunks may belong to multiple topics (e.g., IRB + CreditRisk)
   - Hard clustering is inappropriate for soft/multi-label data

3. **Number of Clusters:**
   - Line 11: `Kclusters = max(2, round(sqrt(N/10)))`
   - Formula is ad-hoc, no justification
   - May not align with actual number of regulatory topics (14 labels in weak rules)

4. **Purity Metric Limitations:**
   - Purity increases with more clusters (trivially = 1 when K = N)
   - No penalty for over-clustering
   - Doesn't account for cluster balance

5. **Silhouette Limitations:**
   - Silhouette measures cluster compactness/separation
   - Valid for k-means, but doesn't validate multi-label structure
   - Can be high even if multi-label relationships are ignored

**Impact:**
- Clustering metrics don't validate multi-label embedding quality
- Purity is misleading (forced single-label assignment)
- Cannot assess if embeddings preserve label co-occurrence patterns
- Comparison across methods may be uninformative

**Recommendations:**

1. **Use Multi-Label Clustering:**
   - **Fuzzy C-Means**: Allows soft cluster membership
   - **Hierarchical Clustering**: Can capture label hierarchies
   - **Label Powerset Clustering**: Cluster based on label combinations

2. **Multi-Label Aware Metrics:**

   **a) Label Co-Occurrence Preservation:**
   ```matlab
   % Measure if nearby embeddings share labels
   function score = label_cooccurrence_score(E, labelsLogical, k_neighbors)
       % For each item, check if k nearest neighbors share labels
       N = size(E, 1);
       S = E * E';  % cosine similarity

       score = 0;
       for i = 1:N
           [~, neighbors] = sort(S(i,:), 'descend');
           neighbors = neighbors(2:k_neighbors+1);  % exclude self

           my_labels = labelsLogical(i,:);
           neighbor_labels = labelsLogical(neighbors,:);

           % Jaccard similarity: |intersection| / |union|
           intersection = sum(my_labels & any(neighbor_labels, 1));
           union = sum(my_labels | any(neighbor_labels, 1));

           if union > 0
               score = score + (intersection / union);
           end
       end
       score = score / N;
   end
   ```

   **b) Label Distribution Distance:**
   ```matlab
   % Compare label distribution in embedding neighborhoods vs. global
   function kl_div = label_distribution_kl(E, labelsLogical, k_neighbors)
       % KL divergence between local and global label distributions
       N = size(E, 1);
       L = size(labelsLogical, 2);

       global_dist = sum(labelsLogical, 1) / N;  % Global label frequencies

       kl_divs = zeros(N, 1);
       for i = 1:N
           [~, neighbors] = sort(E * E(i,:)', 'descend');
           neighbors = neighbors(2:k_neighbors+1);

           local_dist = sum(labelsLogical(neighbors,:), 1) / k_neighbors;

           % KL divergence: sum(p * log(p/q))
           kl = sum(global_dist .* log((global_dist + 1e-9) ./ (local_dist + 1e-9)));
           kl_divs(i) = kl;
       end

       kl_div = mean(kl_divs);
   end
   ```

   **c) Multi-Label Purity (Micro/Macro):**
   ```matlab
   function [micro_purity, macro_purity] = multilabel_purity(idx, labelsLogical)
       % For each cluster, compute label-wise purity
       K = max(idx);
       L = size(labelsLogical, 2);

       macro_purities = zeros(L, 1);

       for label = 1:L
           label_purity = 0;
           for cluster = 1:K
               cluster_members = find(idx == cluster);
               if isempty(cluster_members), continue; end

               % Fraction of cluster with this label
               frac = sum(labelsLogical(cluster_members, label)) / numel(cluster_members);
               label_purity = label_purity + numel(cluster_members) * max(frac, 1-frac);
           end
           macro_purities(label) = label_purity / size(labelsLogical, 1);
       end

       macro_purity = mean(macro_purities);
       micro_purity = sum(macro_purities .* sum(labelsLogical, 1)') / sum(labelsLogical(:));
   end
   ```

3. **Topic Coherence (from LDA literature):**
   ```matlab
   % Measure coherence of top-K nearest neighbors
   function coherence = topic_coherence(E, texts, k_neighbors)
       % For each item, check if neighbors are semantically coherent
       % Use PMI (pointwise mutual information) of words
       % Or human evaluation of neighborhood coherence
   end
   ```

4. **Alternative Evaluation:**
   - **kNN Classification**: For each query, predict labels from k nearest neighbors
     - Micro/Macro F1 from kNN predictions
   - **Label Ranking**: For each item, rank its labels by similarity to neighbors
     - Rank correlation with true labels

5. **Visualize Multi-Label Structure:**
   - t-SNE or UMAP projection to 2D
   - Color items by label combinations
   - Check if multi-label items are in-between single-label clusters

**Example Usage:**
```matlab
% In reg_eval_and_report.m or evaluation pipeline:

% Current (problematic) metrics
S_old = reg.eval_clustering(E, labelsLogical, Kclusters);
fprintf('Purity (single-label, problematic): %.3f\n', S_old.purity);

% New multi-label aware metrics
cooccur_score = label_cooccurrence_score(E, labelsLogical, 10);
fprintf('Label co-occurrence@10: %.3f\n', cooccur_score);

kl_div = label_distribution_kl(E, labelsLogical, 10);
fprintf('Label distribution KL divergence: %.3f\n', kl_div);

[micro_pur, macro_pur] = multilabel_purity(S_old.idx, labelsLogical);
fprintf('Multi-label purity (micro): %.3f\n', micro_pur);
fprintf('Multi-label purity (macro): %.3f\n', macro_pur);
```

**Files Affected:**
- `+reg/eval_clustering.m` (modify or add new functions)
- Evaluation scripts (`reg_eval_and_report.m`, `reg_projection_workflow.m`)
- Documentation: `docs/evaluation_metrics_guide.md`

**References:**
- Schütze et al. 2008 - "Introduction to Information Retrieval" (Ch 16.3 on clustering evaluation)
- Tsoumakas et al. 2010 - "Mining Multi-label Data"
- Madjarov et al. 2012 - "An extensive experimental comparison of methods for multi-label learning"

---

### Issue 10: Gold Pack - Insufficient Size and Scope for Robust Evaluation

**Severity:** MEDIUM
**Labels:** `methodology`, `evaluation`, `gold-standard`

**Problem:**
The gold pack is too small (50-200 chunks) and covers only 5 of 14 labels, limiting its utility for robust evaluation.

**Current Gold Pack:**
- **Size**: 50-200 labeled chunks (from documentation)
- **Labels**: 5 categories (IRB, Liquidity_LCR, AML_KYC, Securitisation, LeverageRatio)
  - From `gold/sample_gold_labels.json`
- **Thresholds**: Fixed values (Recall@10 ≥ 0.8, mAP ≥ 0.6, nDCG@10 ≥ 0.6)
  - From `gold/expected_metrics.json`
- **Source**: Initially generated from simulated data

**Issues:**

1. **Sample Size Too Small:**
   - 50-200 chunks is insufficient for reliable evaluation
   - Standard IR test collections: 1000s to 100,000s of queries
   - With 5 labels, only ~10-40 examples per label
   - High variance in metrics due to small sample

2. **Label Coverage:**
   - Only 5 of 14 labels (36% coverage)
   - Missing critical labels:
     - CreditRisk, SRT, MarketRisk_FRTB, Liquidity_NSFR, OperationalRisk
     - Governance, Reporting_COREP_FINREP, StressTesting, Outsourcing_ICT_DORA
   - Cannot evaluate model performance on these labels

3. **Simulated Data:**
   - `testutil.make_gold_from_simulated` generates initial gold pack from synthetic data
   - May not reflect real regulatory text complexity
   - Easier to classify than real CRR/Basel documents

4. **Fixed Thresholds:**
   - Thresholds (0.8, 0.6) appear arbitrary
   - No justification or baseline comparison
   - Different labels may warrant different thresholds (e.g., IRB vs. AML_KYC)

5. **No Inter-Annotator Agreement:**
   - No protocol for human labeling
   - No measurement of labeling quality (Cohen's kappa, Fleiss' kappa)
   - Single annotator may introduce bias

6. **No Graded Relevance:**
   - Binary labels only (relevant / not relevant)
   - Missing opportunity for graded judgments (highly / somewhat / not relevant)

**Impact:**
- Gold pack metrics have high variance (unreliable)
- Cannot detect regressions on 9 missing labels
- Overoptimistic performance estimates (simulated data is easier)
- Cannot publish results with such limited gold standard

**Recommendations:**

1. **Expand Gold Pack Size:**
   - Target: **1000-2000 labeled chunks** minimum
   - Ensures sufficient statistical power
   - Reduces metric variance
   - Allows for proper train/val/test splits

2. **Full Label Coverage:**
   - Include all 14 regulatory topic labels
   - Aim for balanced representation (min 50 examples per label)
   - Capture label co-occurrence patterns

3. **Use Real Regulatory Text:**
   - Sample from actual CRR, Basel III, EBA guidelines
   - Use diverse document types (articles, recitals, annexes, technical standards)
   - Include challenging cases (ambiguous, multi-topic chunks)

4. **Annotation Protocol:**

   **a) Define Clear Guidelines:**
   ```
   Label: IRB
   Definition: Internal Ratings Based approach for credit risk

   Inclusion criteria:
   - Chunk discusses IRB model requirements
   - Mentions PD, LGD, EAD calibration
   - References IRB articles (e.g., Article 180)

   Exclusion criteria:
   - Generic credit risk (use CreditRisk label)
   - Non-IRB approaches (standardized approach)

   Examples:
   - Positive: "Institutions using the IRB approach shall estimate PD..."
   - Negative: "Credit institutions shall calculate credit risk..."
   ```

   **b) Multiple Annotators:**
   - 2-3 annotators per chunk
   - Measure inter-annotator agreement (Fleiss' kappa, Cohen's kappa)
   - Resolve disagreements through discussion or adjudication
   - Require kappa ≥ 0.7 for acceptable quality

   **c) Annotation Interface:**
   - Use annotation tool (Prodigy, Label Studio, or custom MATLAB GUI)
   - Present chunk with surrounding context
   - Multi-select labels (support multi-label annotation)
   - Optional: Graded relevance (0/1/2)

5. **Data Splitting:**
   ```
   Total: 1500 labeled chunks
   - Development set: 500 chunks (for threshold tuning, hyperparameter search)
   - Test set: 1000 chunks (held-out for final evaluation)

   Stratify by labels to preserve distribution
   ```

6. **Adaptive Thresholds:**
   - Compute per-label thresholds based on development set
   - Use confidence intervals instead of point values
   - Report variance across bootstrap samples

7. **Versioning:**
   - Track gold pack versions (v1.0, v1.1, etc.)
   - Document changes (added labels, fixed errors, expanded size)
   - Ensure reproducibility by archiving each version

8. **Annotation Cost Reduction:**
   - **Active Learning**: Use model to identify uncertain examples for annotation
   - **Weak Supervision**: Bootstrap from weak labels, manually correct
   - **Semi-Automated**: Use keyword matching + human verification

**Example Annotation Process:**
```matlab
% 1. Sample candidate chunks for annotation
all_chunks = load('all_chunks.mat');
candidate_idx = active_learning_sample(all_chunks, 'n_samples', 2000);

% 2. Export for annotation
export_for_annotation(all_chunks(candidate_idx), 'annotation_batch.json');

% 3. Human annotation (external tool)
% ...

% 4. Import annotated data
annotated = import_annotations('annotated_batch.json');

% 5. Compute inter-annotator agreement
kappa = compute_fleiss_kappa(annotated);
fprintf('Inter-annotator agreement (Fleiss kappa): %.3f\n', kappa);

% 6. Resolve disagreements
resolved = adjudicate_disagreements(annotated);

% 7. Split into dev/test
[dev_set, test_set] = stratified_split(resolved, 'dev_ratio', 0.33);

% 8. Save as gold pack
save('gold/dev_set_v2.mat', 'dev_set');
save('gold/test_set_v2.mat', 'test_set');
```

**Files Affected:**
- `gold/` directory (expand with more labeled data)
- `gold/sample_gold_labels.json` (add all 14 labels)
- `gold/expected_metrics.json` (update thresholds with confidence intervals)
- `+testutil/make_gold_from_simulated.m` (replace with real data sampling)
- `+reg/load_gold.m` (support versioning)
- New file: `+reg/annotation_tools.m` (helper functions for annotation process)
- Documentation: `docs/gold_pack_annotation_guide.md`

**References:**
- Voorhees & Harman 2005 - "TREC: Experiment and Evaluation in Information Retrieval"
- Hripcsak & Rothschild 2005 - "Agreement, the F-Measure, and Reliability in Information Retrieval"
- Artstein & Poesio 2008 - "Inter-Coder Agreement for Computational Linguistics"

---

## LOWER PRIORITY ISSUES

### Issue 11: Reproducibility - Incomplete Seed Management and Non-Determinism

**Severity:** LOW
**Labels:** `methodology`, `reproducibility`, `engineering`

**Problem:**
Incomplete random seed management and use of parallel processing may cause non-reproducible results.

**Current State:**
- `+reg/set_seeds.m` is a stub (not implemented)
- Some functions use `rng(seed)` locally (e.g., `build_pairs.m` line 13)
- `parfor` loops in `train_multilabel.m` (line 5) and `predict_multilabel.m` (line 5) may introduce non-determinism
- GPU random number generation not seeded

**Impact:**
- Results may vary across runs
- Difficult to reproduce experiments
- Cannot verify bug fixes or improvements reliably

**Recommendations:**

1. **Implement `set_seeds.m`:**
   ```matlab
   function set_seeds(seed)
       % CPU random number generator
       rng(seed, 'twister');

       % GPU random number generator (if GPU available)
       if gpuDeviceCount > 0
           gpurng(seed, 'Philox4x32-10');
       end

       % Note: parfor may still introduce non-determinism
       % Consider documenting this limitation
   end
   ```

2. **Call `set_seeds` at start of all workflows:**
   ```matlab
   % In reg_pipeline.m, reg_finetune_encoder_workflow.m, etc.
   reg.set_seeds(42);  % Or load from config
   ```

3. **Document Non-Determinism Sources:**
   - `parfor` with random operations (may execute in different orders)
   - GPU operations (some operations are non-deterministic for performance)
   - K-fold splits (if not seeded)

4. **Provide Deterministic Mode:**
   ```matlab
   % Option to disable parallelism for reproducibility
   C.deterministic_mode = true;

   if C.deterministic_mode
       warning('Deterministic mode: parfor disabled, may be slower');
       % Use 'for' instead of 'parfor'
   else
       % Use 'parfor' for speed
   end
   ```

**Files Affected:**
- `+reg/set_seeds.m` (implement)
- All main workflow scripts (call set_seeds)
- Documentation: Add reproducibility section

**References:**
- MATLAB documentation on Reproducibility
- Henderson et al. 2018 - "Deep Reinforcement Learning that Matters"

---

### Issue 12: Configuration Management - Incomplete Knobs Integration

**Severity:** LOW
**Labels:** `engineering`, `configuration`, `usability`

**Problem:**
`knobs.json` loading is incomplete (`config.m` line 67-68: TODO comment).

**Current State:**
```matlab
% config.m lines 67-68
% === Load knobs.json and apply Chunk overrides ===
% TODO: implement reg.load_knobs to populate C.knobs and override fields.
C.knobs = struct();
```

**Impact:**
- Users cannot easily tune hyperparameters via `knobs.json`
- Must edit code directly instead of configuration files
- Defeats purpose of centralized configuration

**Recommendations:**

1. **Implement `+reg/load_knobs.m`:**
   ```matlab
   function K = load_knobs(filepath)
       if nargin < 1, filepath = 'knobs.json'; end

       if ~isfile(filepath)
           warning('knobs.json not found, using defaults');
           K = struct();
           return;
       end

       try
           K = jsondecode(fileread(filepath));
       catch ME
           warning('Failed to load knobs.json: %s', ME.message);
           K = struct();
       end
   end
   ```

2. **Apply Knobs in `config.m`:**
   ```matlab
   % config.m (replace lines 67-68)
   C.knobs = reg.load_knobs('knobs.json');

   % Apply Chunk overrides
   if isfield(C.knobs, 'Chunk')
       if isfield(C.knobs.Chunk, 'SizeTokens')
           C.chunk_size_tokens = C.knobs.Chunk.SizeTokens;
       end
       if isfield(C.knobs.Chunk, 'Overlap')
           C.chunk_overlap = C.knobs.Chunk.Overlap;
       end
   end
   ```

3. **Validate Knobs:**
   - Implement `+reg/validate_knobs.m` (currently stub)
   - Check for required fields
   - Validate ranges (e.g., learning rates > 0, batch size positive)

**Files Affected:**
- `+reg/load_knobs.m` (implement)
- `config.m` (apply knobs)
- `+reg/validate_knobs.m` (implement validation)

---

### Issue 13: Hybrid Search - Hardcoded Fusion Weight and BM25 Approximation

**Severity:** LOW
**Labels:** `methodology`, `search`, `retrieval`

**Problem:**
Hybrid search uses hardcoded 50/50 fusion weight and TF-IDF approximation instead of proper BM25.

**Current Implementation:**
`+reg/hybrid_search.m` (line 45):
```matlab
% Hardcoded α = 0.5 (equal weighting)
score = alpha * bm_scores + (1 - alpha) * em_scores;
```

**Issues:**
- Optimal α may not be 0.5 (depends on relative quality of lexical vs. semantic search)
- TF-IDF ≠ BM25 (missing document length normalization, saturation)

**Recommendations:**

1. **Learn Fusion Weight:**
   - Use validation set to optimize α via grid search
   - Or learn via linear combination with training data

2. **Implement Proper BM25:**
   ```matlab
   % BM25 with k1=1.5, b=0.75 (standard parameters)
   function scores = bm25(term_freqs, doc_lengths, avg_doc_length, idf, k1, b)
       % term_freqs: term frequency in each document
       % doc_lengths: length of each document
       % idf: inverse document frequency

       % Saturation function
       numerator = term_freqs .* (k1 + 1);
       denominator = term_freqs + k1 * (1 - b + b * (doc_lengths / avg_doc_length));
       scores = (numerator ./ denominator) .* idf;
   end
   ```

**Files Affected:**
- `+reg/hybrid_search.m`

---

## Summary Statistics

**Total Issues Identified:** 13

**By Severity:**
- **CRITICAL:** 3 issues (#1 Data Leakage, #2 Weak Supervision, #3 Multi-Label Methodology)
- **HIGH:** 4 issues (#4 Contrastive Learning, #5 Statistical Rigor, #6 Feature Engineering, #7 Evaluation Metrics)
- **MEDIUM:** 3 issues (#8 Hyperparameter Tuning, #9 Clustering, #10 Gold Pack)
- **LOW:** 3 issues (#11 Reproducibility, #12 Configuration, #13 Hybrid Search)

**By Category:**
- **Evaluation Methodology:** 5 issues (#1, #5, #7, #9, #10)
- **Machine Learning:** 5 issues (#2, #3, #4, #6, #8)
- **Engineering/Infrastructure:** 3 issues (#11, #12, #13)

**Estimated Impact:**
- **High Impact (CRITICAL + HIGH):** 7 issues - These fundamentally affect the validity of results
- **Medium Impact:** 3 issues - These limit the scope and robustness of evaluation
- **Low Impact:** 3 issues - These affect reproducibility and usability but not core methodology

---

## Next Steps

1. **Immediate Actions (Address CRITICAL issues):**
   - Create held-out ground-truth validation/test sets (Issue #1)
   - Improve weak supervision with negation handling and phrase matching (Issue #2)
   - Implement stratified multi-label cross-validation (Issue #3)

2. **Short-term (Address HIGH priority issues):**
   - Optimize triplet construction and hard-negative mining (Issue #4)
   - Add significance testing and confidence intervals (Issue #5)
   - Normalize feature concatenation (Issue #6)
   - Implement graded relevance for nDCG (Issue #7)

3. **Medium-term (Address MEDIUM priority issues):**
   - Systematic hyperparameter search (Issue #8)
   - Multi-label clustering metrics (Issue #9)
   - Expand and improve gold pack (Issue #10)

4. **Long-term (Address LOW priority issues + research improvements):**
   - Complete reproducibility infrastructure (Issue #11)
   - Finish configuration system (Issue #12)
   - Improve hybrid search (Issue #13)
   - Explore advanced weak supervision (Snorkel, label model)
   - Investigate transformer-based multi-label classification
   - Add explainability (attention weights, feature importance)

---

## References & Further Reading

**Weak Supervision:**
- Ratner et al. 2017 - "Snorkel: Rapid Training Data Creation with Weak Supervision"
- Ratner et al. 2019 - "Weak Supervision: A New Programming Paradigm for Machine Learning"

**Multi-Label Learning:**
- Tsoumakas & Katakis 2007 - "Multi-label classification: An overview"
- Read et al. 2011 - "Classifier chains for multi-label classification"
- Zhang & Zhou 2014 - "A review on multi-label learning algorithms"

**Contrastive Learning:**
- Schroff et al. 2015 - "FaceNet: A Unified Embedding for Face Recognition and Clustering"
- Khosla et al. 2020 - "Supervised Contrastive Learning"
- Chen et al. 2020 - "A Simple Framework for Contrastive Learning of Visual Representations"

**Evaluation & Metrics:**
- Manning et al. 2008 - "Introduction to Information Retrieval"
- Voorhees & Harman 2005 - "TREC: Experiment and Evaluation in Information Retrieval"
- Dror et al. 2018 - "The Hitchhiker's Guide to Testing Statistical Significance in NLP"

**Machine Learning Best Practices:**
- Bishop 2006 - "Pattern Recognition and Machine Learning"
- Hastie et al. 2009 - "The Elements of Statistical Learning"
- Goodfellow et al. 2016 - "Deep Learning"

---

**End of Methodological Review**

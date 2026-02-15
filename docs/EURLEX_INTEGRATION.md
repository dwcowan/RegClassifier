# EUR-Lex Public Benchmark Integration

This document describes the EUR-Lex public benchmark integration for RegClassifier.

## Overview

The EUR-Lex integration allows you to validate RegClassifier's performance against **publicly available EU legal documents** with established EUROVOC label taxonomy. This provides:

1. ✅ **Zero-cost validation** - No manual annotation needed
2. ✅ **Reproducible benchmarks** - Compare against published baselines
3. ✅ **Large-scale testing** - 65,000+ documents available
4. ✅ **Real regulatory text** - Actual EU banking regulations (CRR, CRD, etc.)

## Files Created

### Core Components

| File | Purpose |
|------|---------|
| `+reg/load_eurlex.m` | MATLAB loader for EUR-Lex JSON/JSONL data |
| `reg_eval_eurlex.m` | Evaluation script with PDF report generation |
| `data/eurovoc_regulatory_mapping.json` | Curated EUROVOC → RegClassifier label mapping |
| `data/eurlex/eurlex_samples.json` | Synthetic test data (6 documents) |
| `test_eurlex_loader.m` | Quick test script for the loader |
| `docs/EURLEX_INTEGRATION.md` | This documentation file |

### EUROVOC Label Mapping

The mapping file connects EUROVOC taxonomy codes to your 5 regulatory labels:

| RegClassifier Label | EUROVOC Codes | Examples |
|---------------------|---------------|----------|
| **IRB** | c_896e199b, c_dcf3f7c0, 100200, 2149 | Credit rating, financial risk, banking |
| **Liquidity_LCR** | 178, 1676, 1677, 3220 | Liquidity control, money-market liquidity |
| **AML_KYC** | 5465, 3870, 3483 | Money laundering, sanctions |
| **Securitisation** | 1459, 100200, 1804, c_834b57c4 | Financial instruments, shadow banking |
| **LeverageRatio** | 3942, c_3e6af2e7, 100200 | Financial solvency, stability |

## Quick Start

### 1. Test with Synthetic Data (Immediate)

```matlab
% Test the loader
run('test_eurlex_loader.m')

% Run evaluation on synthetic data (6 docs, ~20-30 chunks)
run('reg_eval_eurlex.m')
```

**Expected output:**
- Console metrics (Recall@10, mAP, nDCG@10)
- PDF report: `eurlex_eval_report.pdf`

### 2. Use Real EUR-Lex Data (Recommended)

#### Option A: Download MultiEURLEX from Hugging Face

```python
# Python script to download full dataset
from datasets import load_dataset
import json

# Download English subset
dataset = load_dataset('nlpaueb/multi_eurlex', 'en')

# Save to JSONL (filter financial documents)
financial_codes = ['100148', '100200', '2149', '1452', '1804', '178',
                   '3942', '5465', 'c_896e199b', 'c_8f89faac']

with open('data/eurlex/multieurlex_financial.jsonl', 'w') as f:
    for doc in dataset['train']:
        # Filter for financial/banking documents
        if any(code in doc['labels'] for code in financial_codes):
            f.write(json.dumps(doc) + '\n')
```

**Note:** MultiEURLEX dataset has compatibility issues with latest `datasets` library. See Alternative below.

#### Option B: Download from EUR-Lex GitHub (Alternative)

```bash
# Clone the MultiEURLEX repository
cd data/eurlex
git clone https://github.com/nlpaueb/multi-eurlex.git repo

# Download data files (follow repo instructions)
# Or download pre-processed data from Zenodo/Hugging Face datasets viewer
```

#### Option C: Use Your Own CRR/CRD Documents

```matlab
% Use your existing CRR PDFs with weak labels
% This is actually the most relevant benchmark for your use case!

% 1. Ingest your CRR documents
docs = reg.ingest_pdfs('data/pdfs');

% 2. Chunk them
chunks = reg.chunk_all_documents(docs);

% 3. Apply weak rules (uses your synonym dictionary)
[Y, labelNames] = reg.weak_rules(chunks.text);

% 4. Manually validate 100-200 chunks as gold standard
% 5. Run evaluation against gold labels
```

### 3. Update EUR-Lex Data Path

Edit `reg_eval_eurlex.m` line 29:

```matlab
% Change this:
eurlexDataPath = "data/eurlex/eurlex_samples.json";

% To your real data:
eurlexDataPath = "data/eurlex/multieurlex_financial.jsonl";
% OR
eurlexDataPath = "data/eurlex/eurlex_train_en.json";
```

## EUROVOC Mapping

### Structure

```json
{
  "mapping": {
    "IRB": {
      "eurovoc_codes": ["c_896e199b", "c_dcf3f7c0", ...],
      "eurovoc_terms": ["credit rating", "financial risk", ...],
      "keywords": ["internal ratings", "pd", "lgd", ...]
    },
    ...
  },
  "general_financial_codes": {
    "codes": [
      {"code": "100200", "term": "financial institutions and credit"},
      {"code": "2149", "term": "banking"},
      ...
    ]
  }
}
```

### Customization

To add more EUROVOC codes or refine the mapping:

1. Browse EUROVOC thesaurus: https://op.europa.eu/en/web/eu-vocabularies/th-concept-scheme/-/resource/eurovoc/100142
2. Find relevant concept codes (e.g., `5465` = "money laundering")
3. Add to `eurovoc_regulatory_mapping.json`:

```json
{
  "mapping": {
    "AML_KYC": {
      "eurovoc_codes": ["5465", "3870", "YOUR_NEW_CODE"],
      ...
    }
  }
}
```

4. Reload and re-evaluate

## Evaluation Metrics

The evaluation script (`reg_eval_eurlex.m`) computes:

| Metric | Description | Gold Threshold |
|--------|-------------|----------------|
| **Recall@10** | % of relevant chunks in top-10 | ≥ 0.80 |
| **mAP** | Mean Average Precision | ≥ 0.60 |
| **nDCG@10** | Normalized Discounted Cumulative Gain | ≥ 0.60 |
| **Per-Label Recall@10** | Recall for each of 5 labels | - |

### Interpretation

- **Recall@10 < 0.80**: Embeddings may not capture regulatory semantics well
- **mAP < 0.60**: Ranking quality needs improvement
- **High variance in per-label recall**: Some labels harder to distinguish (normal)

### Comparison to Gold Pack

Your existing gold pack (`gold/`) tests on **your specific CRR corpus**. EUR-Lex tests **generalization to broader EU regulations**.

**Expected behavior:**
- EUR-Lex scores may be **lower** than gold pack (more diverse documents)
- EUR-Lex is a **harder benchmark** (cross-domain generalization)
- If EUR-Lex scores are competitive, your system generalizes well!

## Dataset Statistics

### Synthetic Test Data (Provided)

- **Documents:** 6
- **Topics:** IRB, LCR, AML, Securitisation, Leverage Ratio, Mixed
- **Avg document length:** ~1,300 characters
- **Expected chunks:** ~20-30 (depending on chunking params)

### Full MultiEURLEX Dataset

- **English documents:** 17,000 (train + dev + test)
- **EUROVOC labels:** ~4,300 total (100-200 financial/banking)
- **Multi-label:** Yes (avg 5-7 labels per document)
- **Splits:** Train (11k), Dev (1k), Test (5k)

### Recommended Subsets for Testing

| Subset | Size | Purpose |
|--------|------|---------|
| Synthetic (provided) | 6 docs | Quick sanity check |
| Financial filtered | 500-1000 docs | Validation benchmark |
| Full MultiEURLEX | 17k docs | Research/publication |

## Workflow Integration

### Standard Pipeline

```matlab
% 1. Load EUR-Lex data
[chunks, labels, metadata] = reg.load_eurlex(...);

% 2. Generate embeddings (auto-selects best model)
E = reg.precompute_embeddings(chunks.text, config());

% 3. Evaluate retrieval
[recall, mAP] = reg.eval_retrieval(E, posSets, 10);

% 4. Generate report
run('reg_eval_eurlex.m')
```

### Compare Baseline vs Fine-tuned

```matlab
% Baseline BERT
C = config();
C.embeddings_backend = 'bert';
E_baseline = reg.doc_embeddings_bert_gpu(chunks.text, ...
    'MiniBatchSize', 96, 'MaxSeqLength', 256);

[recall_base, mAP_base] = reg.eval_retrieval(E_baseline, posSets, 10);

% Fine-tuned BERT (if available)
load('fine_tuned_bert.mat', 'mdl');
E_ft = reg.ft_encode_batch(chunks.text, mdl, ...
    'BatchSize', 96, 'MaxSeqLength', 256);

[recall_ft, mAP_ft] = reg.eval_retrieval(E_ft, posSets, 10);

% Compare
fprintf('Baseline: Recall@10=%.3f, mAP=%.3f\n', recall_base, mAP_base);
fprintf('Fine-tuned: Recall@10=%.3f, mAP=%.3f\n', recall_ft, mAP_ft);
fprintf('Improvement: +%.1f%% Recall, +%.1f%% mAP\n', ...
    100*(recall_ft - recall_base)/recall_base, ...
    100*(mAP_ft - mAP_base)/mAP_base);
```

## Troubleshooting

### Issue: "EUR-Lex data file not found"

**Solution:** Update the path in `reg_eval_eurlex.m` or create synthetic data:

```matlab
run('test_eurlex_loader.m')  % Creates synthetic data if needed
```

### Issue: "No documents matched filter criteria"

**Cause:** Your EUR-Lex data doesn't have financial EUROVOC codes.

**Solution:** Disable filtering:

```matlab
[chunks, labels] = reg.load_eurlex(..., 'FilterFinancial', false);
```

### Issue: Low scores on EUR-Lex vs Gold Pack

**This is expected!** EUR-Lex is a harder, cross-domain benchmark. Your gold pack is in-domain (CRR).

**Action:**
1. Verify gold pack still passes (≥ 0.80 Recall@10)
2. Use EUR-Lex to identify generalization gaps
3. Consider domain-adaptive fine-tuning on EUR-Lex + CRR

### Issue: Python `datasets` library errors

**Cause:** HuggingFace datasets no longer supports loading scripts (as of 2024).

**Solutions:**
1. **Use synthetic data** (provided) for initial testing
2. **Download pre-processed files** from Hugging Face datasets viewer
3. **Clone GitHub repo** and access raw data files
4. **Use your own CRR corpus** (most relevant anyway!)

## Published Baselines

From Chalkidis et al. (2021) MultiEURLEX paper:

| Model | Level | Micro-F1 | Macro-F1 |
|-------|-------|----------|----------|
| BERT-EN | 1 | 71.7 | 55.3 |
| BERT-EN | 2 | 63.1 | 44.2 |
| BERT-EN | 3 | 58.4 | 39.5 |
| XLM-R | 1 | 70.1 | 52.8 |

**Note:** These are classification F1 scores, not retrieval metrics. For retrieval (your use case), baselines vary by task setup.

## Next Steps

1. ✅ **Test with synthetic data** - Verify the pipeline works
2. ⏳ **Download real EUR-Lex data** - Get 500-1000 financial documents
3. ⏳ **Run full evaluation** - Benchmark your system
4. ⏳ **Compare to gold pack** - Understand in-domain vs cross-domain performance
5. ⏳ **Iterate** - Use EUR-Lex to identify weak labels or improve embeddings

## References

- **MultiEURLEX Paper:** Chalkidis et al. (2021) "MultiEURLEX - A multi-lingual and multi-label legal document classification dataset for zero-shot cross-lingual transfer"
- **Dataset:** https://huggingface.co/datasets/nlpaueb/multi_eurlex
- **GitHub:** https://github.com/nlpaueb/multi-eurlex
- **EUROVOC:** https://op.europa.eu/en/web/eu-vocabularies/th-concept-scheme/-/resource/eurovoc/100142

## Contact

For issues with the EUR-Lex integration, check:
1. This documentation
2. Test script: `test_eurlex_loader.m`
3. Example evaluation: `reg_eval_eurlex.m`
4. Gold pack evaluation (reference): `reg_eval_gold.m`

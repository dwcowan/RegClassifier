# Evaluation Pseudocode

## Retrieval Metric Computation
1. Begin with a `resultsTbl` table containing retrieval scores:
   - `docId` (string): identifier of the retrieved document.
   - `score` (double): similarity score, higher is better.
2. Load gold annotations into `goldTbl` (see *Gold Loading*).
3. Compute retrieval metrics:
   ```matlab
   metricsTbl = reg.evalRetrieval(resultsTbl, goldTbl);
   ```
4. `metricsTbl` schema:
   - `metric` (string): name such as `recallAt10`, `meanAveragePrecision`, `nDCGAt10`.
   - `value` (double): metric value.
   - `k` (double, optional): cutoff for @k metrics.
5. A PDF report and metric CSVs are written to `reports/reg_eval_report.pdf` and related files in the `reports/` directory.

## Gold Loading
Load a curated gold mini-pack when available:
```matlab
goldPath = 'path/to/gold';
goldTbl = reg.loadGold(goldPath);
```
`goldTbl` schema:
- `docId` (string): document identifier.
- `y` (matrix or logical vector): ground-truth labels aligned to documents.

## Per-Label Evaluation
Evaluate performance for each label:
```matlab
perLabelTbl = reg.evalPerLabel(predYMat, goldTbl.y);
```
`perLabelTbl` schema:
- `labelId` (string or double): label identifier.
- `precision` (double)
- `recall` (double)
- `f1` (double): harmonic mean of precision and recall.

The per-label table can be merged into the main metrics and included in the evaluation report stored under `reports/`.

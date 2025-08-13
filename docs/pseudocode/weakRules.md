# weakRules Pseudocode

## Rule Application
- Inputs:
  - `textVec` (string array): chunk content.
  - `labelVec` (string array): label identifiers listed in `configStruct.labels`.
- For each label in `labelVec`, define rule patterns (regex or keyword).
- For each chunk in `textVec`:
  1. Apply each label's patterns to the chunk text.
  2. Aggregate match confidence into `weakLabelMat(rowIdx, labelIdx)`.

## Matrix Shape
- `weakLabelMat`: sparse double matrix sized `numel(textVec)` × `numel(labelVec)` where rows map to chunks and columns map to labels (see [LabelMatrix schema](../identifier_registry.md#L175-L180)).
- `bootLabelMat`: sparse logical matrix with the same shape after thresholding.

## Thresholding
- Use confidence cutoff `MIN_RULE_CONFIDENCE` from the identifier registry.
- `bootLabelMat = weakLabelMat >= minRuleConf`.

## Rule Patterns & Label Identifiers
- Example mappings:
  - Pattern `/tax/i` → label `taxCompliance`.
  - Pattern `/refund/i` → label `refundProcess`.
- Ensure each label identifier used above is recorded in [identifier_registry.md](../identifier_registry.md).

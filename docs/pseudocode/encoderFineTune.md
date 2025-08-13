# Encoder Fine-Tuning Pseudocode

## Triplet Sampling Strategy

1. Iterate over `chunksTbl` to collect anchors.
2. For each `anchorIdx`:
   - `anchorLabelsVec = bootLabelMat(anchorIdx, :)`
   - `posCandidatesVec = find(any(bootLabelMat(:, anchorLabelsVec), 2));`
   - `negCandidatesVec = find(~any(bootLabelMat(:, anchorLabelsVec), 2));`
   - `posIdx = randsample(posCandidatesVec, 1);`
   - `negIdx = randsample(negCandidatesVec, 1);`
   - Append to `contrastiveDatasetTbl` as new row.
3. Save to `data/contrastive_ds.mat`.

## Layer Unfreezing and Training

1. Load `pretrainedEncoderStruct`.
2. Freeze all encoder layers.
3. Unfreeze top `unfreezeTop` layers:
   ```matlab
   for layerIdx = numLayers - unfreezeTop + 1 : numLayers
       encoderLayers(layerIdx).learnRate = baseLearnRate;
   end
   ```
4. For each epoch:
   - Pull batch of `(anchorIdx, posIdx, negIdx)` from `contrastiveDatasetTbl`.
   - Encode triplets.
   - Compute `contrastiveLoss = infoNCELoss(anchorEmb, posEmb, negEmb);`
   - Backpropagate through unfrozen layers.
5. Save model as `models/fine_tuned_bert.mat`.
6. Optionally log metrics to `derived/fine_tune_log.txt`.

## Outputs

- `data/contrastive_ds.mat` – triples dataset.
- `models/fine_tuned_bert.mat` – fine-tuned encoder weights.
- `derived/fine_tune_log.txt` – training diagnostics.

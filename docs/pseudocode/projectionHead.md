# Projection Head Pseudocode

**Goal:** freeze encoder embeddings and train a lightweight MLP projection head.

## Freeze Embeddings
1. Load `embeddingMat` and `bootLabelMat`.
2. Invoke `freezeEmbeddingLayer` so encoder parameters remain fixed.

## Train MLP
1. Initialize `weightMat` and `biasVec`.
2. For each minibatch:
   - Generate `logitMat` by applying `weightMat` and `biasVec` to the current embeddings.
   - Compute loss between `logitMat` and `bootLabelMat`.
   - Update `weightMat` and `biasVec` to reduce the loss.
3. Encapsulate the routine as `trainProjectionHead(embeddingMat, bootLabelMat)`.

## Returned Struct
- Return `projectionHeadStruct` with fields:
  - `weightMat`
  - `biasVec`

## Reusable Identifiers
`embeddingMat`, `bootLabelMat`, `freezeEmbeddingLayer`, `trainProjectionHead`, `projectionHeadStruct`, `weightMat`, `biasVec`
# Embedding Generation Pseudocode

This sketch outlines how to compute and persist document embeddings. The routine prefers a GPU backend but falls back to the CPU when necessary.

## 1. Load Chunks
```matlab
chunksTbl = load('data/chunks.mat').chunks;
numChunks = height(chunksTbl);
```

## 2. Select Backend and Compute
```matlab
if gpuDeviceCount > 0
    embeddingMat = reg.docEmbeddingsBertGpu(chunksTbl);
else
    embeddingMat = reg.docEmbeddingsBertCpu(chunksTbl);
end
```
`embeddingMat` is a double matrix sized `[numChunks x 768]`.

## 3. Persist Embeddings
```matlab
outPath = fullfile('data','embeddingMat.mat');
reg.precomputeEmbeddings(embeddingMat, outPath);
% Saves variable `embeddingMat` in MAT-file format (-v7.3 for large arrays)
```

The saved file can be reloaded for downstream tasks without recomputing embeddings.

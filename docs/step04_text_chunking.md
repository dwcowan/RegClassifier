# Step 4: Text Chunking

**Goal:** Split long documents into overlapping token chunks.

**Depends on:** [Step 3: Data Ingestion](step03_data_ingestion.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load the ingested documents table:
   ```matlab
   load('data/docs.mat','docs')
   ```
2. Chunk each document with the helper function (default `chunkSizeTokens=300`, `chunkOverlap=80`):
   ```matlab
   chunks = reg.chunkText(docs, 'chunkSizeTokens', 300, 'chunkOverlap', 80);
   ```
3. Save the chunks for later modules:
   ```matlab
   save('data/chunks.mat','chunks')
   ```

## Function Interface
- `reg.chunkText(docs, 'chunkSizeTokens', n, 'chunkOverlap', m)`
  - `docs` (table): Step 3 output following the **Document** schema.
  - `n` (double): tokens per chunk.
  - `m` (double): overlap between chunks.
  - returns `chunks` (`table`): follows the **Chunk** schema (`chunkId`, `docId`, `text`).
  - See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema.

## Verification
- `chunks` contains `chunkId`, `docId`, and `text` for each segment.
- Run the chunking test:
  ```matlab
  runtests('tests/TestIngestAndChunk.m')
  ```
  The test confirms expected chunk counts and boundaries.

## Next Steps
Continue to [Step 5: Weak Labeling](step05_weak_labeling.md).

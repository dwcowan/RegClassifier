# Step 4: Text Chunking

**Goal:** Split long documents into overlapping token chunks.

**Depends on:** [Step 3: Data Ingestion](step03_data_ingestion.md).

## Instructions
1. Load the ingested documents table:
   ```matlab
   load('data/docs.mat','docs')
   ```
2. Chunk each document with the helper function (default `chunk_size_tokens=300`, `chunk_overlap=80`):
   ```matlab
   chunks = reg.chunk_text(docs, 'chunk_size_tokens', 300, 'chunk_overlap', 80);
   ```
3. Save the chunks for later modules:
   ```matlab
   save('data/chunks.mat','chunks')
   ```

## Function Interface
- `reg.chunk_text(docs, 'chunk_size_tokens', n, 'chunk_overlap', m)`  
  - `docs` (table): from Step 3 with `docId` and `text` fields.  
  - `n` (double): tokens per chunk.  
  - `m` (double): overlap between chunks.  
  - returns `chunks` (`table`): columns `chunkId` (string), `docId` (string), `text` (string).  
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

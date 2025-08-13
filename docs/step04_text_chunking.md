# Step 4: Text Chunking

**Goal:** Split long documents into overlapping token chunks.

**Depends on:** [Step 3: Data Ingestion](step03_data_ingestion.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Load the ingested documents table `docsTbl`:
   ```matlab
   load('data/docsTbl.mat','docsTbl')
   ```
2. Chunk each document with the helper function (default `chunkSizeTokens=300`, `chunkOverlap=80`):
   ```matlab
   chunksTbl = reg.chunkText(docsTbl, 'chunkSizeTokens', 300, 'chunkOverlap', 80);
   ```
3. Save the chunksTbl for later modules:
   ```matlab
   save('data/chunksTbl.mat','chunksTbl')
   ```

## Function Interface

### reg.chunkText
- **Parameters:**
  - `docsTbl` (table): from Step 3 with `docId` and `text` fields.
  - `'chunkSizeTokens'` (double): tokens per chunk.
  - `'chunkOverlap'` (double): overlap between chunks.
- **Returns:** table `chunksTbl` with columns `chunkId` (double), `docId` (string), and `text` (string).
- **Side Effects:** none; pure transformation of input table.
- **Usage Example:**
  ```matlab
  chunksTbl = reg.chunkText(docsTbl, 'chunkSizeTokens', 100, 'chunkOverlap', 20);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema.


## Verification
- `chunksTbl` contains numeric `chunkId`, along with `docId` and `text` for each segment.
- Run the chunking test:
  ```matlab
  runtests('tests/testIngestAndChunk.m')
  ```
  The test confirms expected chunk counts and boundaries.

## Next Steps
Continue to [Step 5: Weak Labeling](step05_weak_labeling.md).

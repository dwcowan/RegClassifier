# Step 3: Data Ingestion

**Goal:** Convert PDF documents into raw text records.

**Depends on:** [Step 2: Repository Setup](step02_repository_setup.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Place source PDFs in a folder referenced by `pipeline.json` (e.g., `data/pdfs`). Fetcher utilities save downloaded PDFs to `data/raw`.
2. Before running `reg.ingestPdfs`, either copy PDFs into `data/pdfs` or update `pipeline.json` to read from `data/raw`.
3. In MATLAB, call the ingestion routine:
   ```matlab
   docsTbl = reg.ingestPdfs('data/pdfs');
   ```
4. The function extracts text from each PDF. Image-only pages fall back to OCR if the Report Generator toolbox is installed.
5. Save the resulting table for later steps:
   ```matlab
   save('data/docsTbl.mat','docsTbl')
   ```

## Function Interface

### reg.ingestPdfs
- **Parameters:**
  - `inputDir` (string): folder containing source PDFs.
- **Returns:** table `docsTbl` with columns `docId` (string) and `text` (string).
- **Side Effects:** reads PDFs from disk and uses OCR for image-only pages.
- **Usage Example:**
  ```matlab
  docsTbl = reg.ingestPdfs("data/pdfs_mock");
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema.


## Verification
- `docsTbl` is a table with columns such as `docId` and `text`.
- Run the unit test for ingestion:
  ```matlab
  runtests('tests/testPDFIngest.m')
  ```
  The test should pass, confirming OCR fallback and basic parsing.

## Next Steps
Continue to [Step 4: Text Chunking](step04_text_chunking.md).

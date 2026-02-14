# Step 3: Data Ingestion

**Goal:** Convert PDF documents into raw text records.

**Depends on:** [Step 2: Repository Setup](step02_repository_setup.md).

## Instructions
1. Place source PDFs in a folder referenced by `pipeline.json` (e.g., `data/pdfs`). Fetcher utilities save downloaded PDFs to `data/raw`.
2. Before running `reg.ingest_pdfs`, either copy PDFs into `data/pdfs` or update `pipeline.json` to read from `data/raw`.
3. In MATLAB, call the ingestion routine:
   ```matlab
   docs = reg.ingest_pdfs('data/pdfs');
   ```
4. The function extracts text from each PDF. Image-only pages fall back to OCR if the Report Generator toolbox is installed.
5. Save the resulting table for later steps:
   ```matlab
   save('data/docs.mat','docs')
   ```

## Verification
- `docs` is a table with columns such as `doc_id` and `text`.
- Run the unit test for ingestion:
  ```matlab
  runtests('tests/TestPDFIngest.m')
  ```
  The test should pass, confirming OCR fallback and basic parsing.

## Next Steps
Continue to [Step 4: Text Chunking](step04_text_chunking.md).

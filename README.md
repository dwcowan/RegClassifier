# Regulatory Topic Classifier (MATLAB)

End-to-end MATLAB project for ingesting banking regulations (PDFs), chunking, weak-rule bootstrapping,
multi-label training, hybrid retrieval, and reporting. Includes a full MATLAB Test suite and a DB
test using SQLite (no external server required).

## Layout
- `config.m` — configurable parameters (labels, chunking, DB, etc.)
- `reg_pipeline.m` — end-to-end driver
- `+reg/` — package with modules (ingest, chunking, features, embeddings, rules, train/predict, search, DB helpers)
- `tests/` — MATLAB unit tests (no network required), plus sample fixture PDF text.

## Running
1. Put PDFs under `data/pdfs` (or use the provided dummy).
2. Open MATLAB in this folder and run:
   ```matlab
   results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);
   table(results)
   ```
3. To run the full pipeline (requires your toolboxes): `run('reg_pipeline.m')`

## DB in tests
Tests use **SQLite** via Database Toolbox (`sqlite` class) so no server is needed.
The production helpers support both Postgres and SQLite (see `+reg/ensure_db.m`).


### MATLAB R2024a Notes
- Defaults tuned for RTX 4060 Ti 16 GB:
  - BERT GPU embeddings: `MiniBatchSize=96`, `MaxSeqLength=256`
  - Projection head training: `BatchSize=768`
- If you see GPU headroom, raise BERT batch to 128; if you hit OOM, drop to 64.

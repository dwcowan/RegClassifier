**Model Layer**


| Class            | Purpose & Key Data                                                                                 |
| ---------------- | -------------------------------------------------------------------------------------------------- |
| `Document`       | Represents raw PDF text with identifiers (`doc_id`, `text`)\:codex-file-citation                   |
| `Chunk`          | Overlapping token segments of documents (`chunk_id`, `doc_id`, `text`)\:codex-file-citation        |
| `LabelMatrix`    | Sparse weak labels (`Yboot`) aligned to chunks and topics\:codex-file-citation                     |
| `Embedding`      | Vector representation of each chunk (`X`) produced by BERT or fallback models\:codex-file-citation |
| `BaselineModel`  | Multi‑label classifier and hybrid retrieval artifacts\:codex-file-citation                         |
| `ProjectionHead` | MLP fine-tuning frozen embeddings to enhance retrieval\:codex-file-citation                        |
| `Encoder`        | Fine‑tuned BERT weights for contrastive learning workflows\:codex-file-citation                    |
| `Metrics`        | Evaluation results and per‑label performance data\:codex-file-citation                             |
| `CorpusVersion`  | Versioned corpora for diff operations and reports\:codex-file-citation                             |


**View Layer**

| Class              | Purpose                                                                        |
| ------------------ | ------------------------------------------------------------------------------ |
| `EvalReportView`   | Generates PDF/HTML reports summarizing metrics and trends\:codex-file-citation |
| `DiffReportView`   | Presents HTML or PDF diffs between regulatory versions\:codex-file-citation    |
| `MetricsPlotsView` | Visualizes metrics/heatmaps (e.g., coretrieval, trend plots).                  |


**Controller Layer**

| Class                       | Coordinates                                                                                                    |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `IngestionController`       | Runs `reg.ingest_pdfs` to populate `Document` models\:codex-file-citation                                      |
| `ChunkingController`        | Splits documents into `Chunk` models via `reg.chunk_text`:codex-file-citation                                  |
| `WeakLabelingController`    | Applies heuristic rules to create `LabelMatrix` models\:codex-file-citation                                    |
| `EmbeddingController`       | Generates and caches `Embedding` models (`reg.doc_embeddings_bert_gpu`)\:codex-file-citation                   |
| `BaselineController`        | Trains `BaselineModel` and serves retrieval (`reg.train_multilabel`, `reg.hybrid_search`)\:codex-file-citation |
| `ProjectionHeadController`  | Fits `ProjectionHead` and integrates it into the pipeline\:codex-file-citation                                 |
| `FineTuneController`        | Builds contrastive datasets and produces `Encoder` models\:codex-file-citation                                 |
| `EvaluationController`      | Computes metrics and invokes `EvalReportView` and gold pack evaluation\:codex-file-citation                    |
| `DataAcquisitionController` | Fetches regulatory corpora and triggers diff analyses with `DiffReportView`:codex-file-citation                |
| `PipelineController`        | Orchestrates end‑to‑end execution based on module dependencies\:codex-file-citation                            |
| `TestController`            | Executes continuous test suite to maintain reliability\:codex-file-citation                                    |

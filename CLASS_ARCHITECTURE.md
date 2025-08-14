# MVC Clean-Room Class Architecture

This document defines a stubbed class structure for refactoring the
Regulatory Topic Classifier into a modular Model–View–Controller (MVC)
application.  All classes are free of business logic and only expose
interfaces, data flow, and orchestration.

---

## Interfaces

| Interface | Responsibility | Key Methods |
|-----------|----------------|-------------|
| `reg.mvc.BaseModel` | Access and transform data | `load(varargin)` → raw input<br>`process(data)` → structured output |
| `reg.mvc.BaseView` | Present controller output | `display(data)` |
| `reg.mvc.BaseController` | Coordinate model and view | `run()` |
| `reg.mvc.Application` | Wire components and start execution | `start()` → `Controller.run()` |

---

## Model Layer

| Class | Purpose |
|-------|---------|
| `reg.model.ConfigModel` | Retrieve configuration parameters |
| `reg.model.PDFIngestModel` | Convert PDFs into a document table |
| `reg.model.TextChunkModel` | Split documents into token chunks |
| `reg.model.FeatureModel` | Generate TF‑IDF, topics, and embeddings |
| `reg.model.ProjectionHeadModel` | Apply optional projection head |
| `reg.model.WeakLabelModel` | Produce weak and bootstrapped labels |
| `reg.model.ClassifierModel` | Train models and produce predictions |
| `reg.model.SearchIndexModel` | Build hybrid retrieval index |
| `reg.model.DatabaseModel` | Persist chunk predictions and scores |
| `reg.model.ReportModel` | Assemble data for final reports |
| `reg.model.FineTuneDataModel` | Build contrastive triplet datasets |
| `reg.model.EncoderFineTuneModel` | Fine‑tune base encoder |
| `reg.model.EvaluationModel` | Compute retrieval and classification metrics |
| `reg.model.LoggingModel` | Save experiment metrics |
| `reg.model.GoldPackModel` | Provide labelled gold data |

---

## View Layer

| Class | Purpose |
|-------|---------|
| `reg.view.ReportView` | Render report artifacts |
| `reg.view.MetricsView` | Present metrics or progress |

---

## Controller Layer

| Class | Collaborators | Responsibility |
|-------|---------------|---------------|
| `reg.controller.PipelineController` | All pipeline models + `ReportView` | Ingest → chunk → features → labels → classifier → index → DB → report |
| `reg.controller.ProjectionHeadController` | Feature, fine‑tune data, projection head, evaluation models + `MetricsView` | Train and evaluate projection head |
| `reg.controller.FineTuneController` | PDF ingest, chunk, weak label, fine‑tune data, encoder fine‑tune, evaluation models + `MetricsView` | Build contrastive set and fine‑tune encoder |
| `reg.controller.EvalController` | Evaluation, logging, report models + `ReportView` | Evaluate embeddings and generate reports |

---

## Data Flow Overview

1. **Pipeline**: PDFs → documents → chunks → features → labels → classifier →
   search index → database → report.
2. **Projection Head**: features → triplets → head training → evaluation.
3. **Fine‑Tune**: ingest → chunks → labels → triplets → encoder training → evaluation.
4. **Evaluation**: embeddings & labels → metrics → logging → report.

This structure establishes a clean foundation for further development while
keeping implementation details out of scope.


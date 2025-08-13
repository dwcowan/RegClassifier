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



## Class Definitions

**Model Layer (+model)**

classdef Document
  %DOCUMENT Represents a regulatory PDF document.
  properties
    docID   % Unique identifier
    text    % Raw text content
  end
  methods
    function obj = Document(docID, text)
      obj.docID = docID;
      obj.text = text;
    end
    function n = tokenCount(obj)
      % Return number of tokens in text.
      n = [];  %#ok<*NASGU>
    end
    function md = metadata(obj)
      % Return additional metadata (source, title, etc.).
      md = struct();
    end
  end
end


classdef Chunk
  %CHUNK Overlapping text segment from a document.
  properties
    chunkID
    docID
    text
    startIndex
    endIndex
  end
  methods
    function obj = Chunk(chunkID, docID, text, startIndex, endIndex)
      obj.chunkID = chunkID;
      obj.docID = docID;
      obj.text = text;
      obj.startIndex = startIndex;
      obj.endIndex = endIndex;
    end
    function len = length(obj)
      % Return number of tokens in text.
      len = [];
    end
    function tf = overlaps(obj, other)
      % Determine if two chunks overlap in a document.
      tf = false;
    end
  end
end


classdef LabelMatrix
  %LABELMATRIX Sparse weak labels per chunk and topic.
  properties
    chunkIDs
    topicIDs
    matrix  % Sparse representation
  end
  methods
    function obj = LabelMatrix(chunkIDs, topicIDs, matrix)
      obj.chunkIDs = chunkIDs;
      obj.topicIDs = topicIDs;
      obj.matrix = matrix;
    end
    function addLabel(obj, chunkID, topicID, weight)
      % Insert or update a label weight.
    end
    function labels = getLabelsForChunk(obj, chunkID)
      % Return topic:weight pairs for a chunk.
      labels = struct();
    end
  end
end


classdef Embedding
  %EMBEDDING Vector representation of a chunk.
  properties
    chunkID
    vector
    modelName
  end
  methods
    function obj = Embedding(chunkID, vector, modelName)
      obj.chunkID = chunkID;
      obj.vector = vector;
      obj.modelName = modelName;
    end
    function sim = cosineSimilarity(obj, other)
      % Compute cosine similarity with another embedding.
      sim = 0;
    end
    function normalize(obj)
      % Normalize vector in-place.
    end
  end
end

classdef BaselineModel
  %BASELINEMODEL Multi-label classifier and hybrid retrieval index.
  properties
    labelMatrix
    embeddings
    modelWeights
  end
  methods
    function obj = BaselineModel(labelMatrix, embeddings)
      obj.labelMatrix = labelMatrix;
      obj.embeddings = embeddings;
      obj.modelWeights = [];
    end
    function train(obj, epochs, lr)
      % Train the classifier.
    end
    function probs = predict(obj, embedding)
      % Predict label probabilities for a single embedding.
      probs = [];
    end
    function save(obj, path)
      % Serialize model to disk.
    end
  end
end



classdef ProjectionHead
  %PROJECTIONHEAD MLP or shallow network for embedding transformation.
  properties
    inputDim
    outputDim
    parameters
  end
  methods
    function obj = ProjectionHead(inputDim, outputDim)
      obj.inputDim = inputDim;
      obj.outputDim = outputDim;
      obj.parameters = struct();
    end
    function fit(obj, X, Y, epochs, lr)
      % Train projection head.
    end
    function Xtrans = transform(obj, X)
      % Apply transformation to embeddings.
      Xtrans = [];
    end
  end
end


classdef Encoder
  %ENCODER Fine-tuned model for contrastive learning.
  properties
    baseModel
    stateDict
  end
  methods
    function obj = Encoder(baseModel)
      obj.baseModel = baseModel;
      obj.stateDict = [];
    end
    function fineTune(obj, dataset, epochs, lr)
      % Contrastive fine-tuning procedure.
    end
    function emb = encode(obj, text)
      % Convert text to embedding.
      emb = [];
    end
  end
end


classdef Metrics
  %METRICS Encapsulates evaluation results.
  properties
    metricName
    scores  % e.g., containers.Map or struct
  end
  methods
    function obj = Metrics(metricName, scores)
      obj.metricName = metricName;
      obj.scores = scores;
    end
    function s = summary(obj)
      % Return human-readable summary of metrics.
      s = "";
    end
  end
end


classdef CorpusVersion
  %CORPUSVERSION Versioned corpus handling for diff operations.
  properties
    versionID
    documents  % Array of Document
  end
  methods
    function obj = CorpusVersion(versionID, documents)
      obj.versionID = versionID;
      obj.documents = documents;
    end
    function diffResult = diff(obj, other)
      % Return differences between versions.
      diffResult = struct();
    end
  end
end


**View Layer (+view)**

classdef EvalReportView
  %EVALREPORTVIEW Renders evaluation metrics into report format.
  methods
    function renderPDF(~, metrics, path)
      % Generate PDF report.
    end
    function renderHTML(~, metrics, path)
      % Generate HTML report.
    end
  end
end

classdef DiffReportView
  %DIFFREPORTVIEW Renders document diffs between corpus versions.
  methods
    function render(~, diffResult, path, fmt)
      % Generate diff report in HTML or PDF.
      if nargin < 4
        fmt = "html";
      end
    end
  end
end


classdef MetricsPlotsView
  %METRICSPLOTSVIEW Creates visual plots for metrics and trends.
  methods
    function plotHeatmap(~, metrics, path)
      % Render heatmap from metric matrix.
    end
    function plotTrend(~, metricHistory, path)
      % Render line chart for metric trends over versions.
    end
  end
end


**Controller Layer (+controller)**

classdef IngestionController
  %INGESTIONCONTROLLER Parses PDFs and returns Document objects.
  methods
    function documents = run(~, sourcePaths)
      documents = [];
    end
  end
end


classdef ChunkingController
  %CHUNKINGCONTROLLER Splits documents into overlapping chunks.
  methods
    function chunks = run(~, documents, window, overlap)
      chunks = [];
    end
  end
end

classdef WeakLabelingController
  %WEAKLABELINGCONTROLLER Applies heuristic rules to label chunks.
  methods
    function labelMatrix = run(~, chunks, labelingRules)
      labelMatrix = [];
    end
  end
end


classdef EmbeddingController
  %EMBEDDINGCONTROLLER Generates embeddings for chunks.
  methods
    function embeddings = run(~, chunks, modelName)
      embeddings = [];
    end
  end
end


classdef BaselineController
  %BASELINECONTROLLER Trains baseline classifier and serves retrieval.
  methods
    function model = train(~, labelMatrix, embeddings)
      model = [];
    end
    function chunks = retrieve(~, queryEmbedding, topK)
      chunks = [];
    end
  end
end

classdef ProjectionHeadController
  %PROJECTIONHEADCONTROLLER Manages projection head training and usage.
  methods
    function head = fit(~, embeddings, labels)
      head = [];
    end
    function transformed = apply(~, projectionHead, embeddings)
      transformed = [];
    end
  end
end


classdef FineTuneController
  %FINETUNECONTROLLER Fine-tunes base models.
  methods
    function encoder = run(~, dataset, baseModel)
      encoder = [];
    end
  end
end


classdef EvaluationController
  %EVALUATIONCONTROLLER Computes metrics and generates reports.
  methods
    function metrics = evaluate(~, model, testEmbeddings, trueLabels)
      metrics = [];
    end
    function generateReports(~, metrics, outDir)
      % Use view layer to produce reports.
    end
  end
end


classdef DataAcquisitionController
  %DATAACQUISITIONCONTROLLER Fetches corpora and runs diffs.
  methods
    function corpus = fetch(~, sources)
      corpus = [];
    end
    function diffVersions(~, oldVersion, newVersion, outDir)
      % Run diff and trigger DiffReportView.
    end
  end
end


classdef PipelineController
  %PIPELINECONTROLLER High-level orchestration based on dependency graph.
  properties
    controllers % Struct or containers.Map holding controller instances
  end
  methods
    function obj = PipelineController(controllers)
      obj.controllers = controllers;
    end
    function execute(obj, config)
      % Execute pipeline steps using obj.controllers.
    end
  end
end


classdef TestController
  %TESTCONTROLLER Executes continuous test suite.
  methods
    function results = runTests(~, selectors)
      if nargin < 2
        selectors = [];
      end
      results = struct();
    end
  end
end


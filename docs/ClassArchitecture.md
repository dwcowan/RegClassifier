**Model Layer**

| Class           | Purpose & Key Data                                                                 |
| --------------- | ---------------------------------------------------------------------------------- |
| `Document`      | Represents raw PDF text with identifiers (`docId`, `text`)                         |
| `Chunk`         | Overlapping token segments of documents (`chunkId`, `docId`, `text`)               |
| `LabelMatrix`   | Sparse weak labels (`labelMat`) aligned to chunks and topics                       |
| `Embedding`     | Vector representation of each chunk (`embeddingVec`) produced by BERT or fallback models |
| `BaselineModel` | Multi‑label classifier and hybrid retrieval artifacts                              |
| `ProjectionHead`| MLP fine-tuning frozen embeddings to enhance retrieval                             |
| `Encoder`       | Fine‑tuned BERT weights for contrastive learning workflows                         |
| `Metrics`       | Evaluation results and per‑label performance data                                  |
| `CorpusVersion` | Versioned corpora for diff operations and reports (`versionId`, `documentVec`)      |

**View Layer**

| Class            | Purpose                                                     |
| ---------------- | ----------------------------------------------------------- |
| `EvalReportView` | Generates PDF/HTML reports summarizing metrics and trends   |
| `DiffReportView` | Presents HTML or PDF diffs between regulatory versions      |
| `MetricsPlotsView` | Visualizes metrics/heatmaps (e.g., coretrieval, trend plots) |

**Controller Layer**

| Class                      | Coordinates                                                                  |
| -------------------------- | ---------------------------------------------------------------------------- |
| `IngestionController`      | Runs `reg.ingestPdfs` to populate `Document` models                          |
| `ChunkingController`       | Splits documents into `Chunk` models via `reg.chunkText`                    |
| `WeakLabelingController`   | Applies heuristic rules to create `LabelMatrix` models                       |
| `EmbeddingController`      | Generates and caches `Embedding` models (`reg.docEmbeddingsBertGpu`)         |
| `BaselineController`       | Trains `BaselineModel` and serves retrieval (`reg.trainMultilabel`, `reg.hybridSearch`) |
| `ProjectionHeadController` | Fits `ProjectionHead` and integrates it into the pipeline                     |
| `FineTuneController`       | Builds contrastive datasets and produces `Encoder` models                     |
| `EvaluationController`     | Computes metrics and invokes `EvalReportView` and gold pack evaluation        |
| `DataAcquisitionController`| Fetches regulatory corpora and triggers diff analyses with `DiffReportView`   |
| `PipelineController`       | Orchestrates end‑to‑end execution based on module dependencies                |
| `TestController`           | Executes continuous test suite to maintain reliability                        |
## Class Definitions

**Model Layer (+model)**

classdef Document
    %DOCUMENT Represents a regulatory PDF document.
    
    properties
        docId   % Unique identifier
        text    % Raw text content
    end

    methods
        function obj = Document(docId, text)
            obj.docId = docId;
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
        chunkId
        docId
        text
        startIndex
        endIndex
    end

    methods
        function obj = Chunk(chunkId, docId, text, startIndex, endIndex)
            obj.chunkId = chunkId;
            obj.docId = docId;
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
        chunkIdVec
        topicIdVec
        labelMat  % Sparse representation
    end

    methods
        function obj = LabelMatrix(chunkIdVec, topicIdVec, labelMat)
            obj.chunkIdVec = chunkIdVec;
            obj.topicIdVec = topicIdVec;
            obj.labelMat = labelMat;
        end

        function addLabel(obj, chunkId, topicId, weight)
            % Insert or update a label weight.
        end

        function labels = getLabelsForChunk(obj, chunkId)
            % Return topic:weight pairs for a chunk.
            labels = struct();
        end
    end
end


classdef Embedding
    %EMBEDDING Vector representation of a chunk.
    
    properties
        chunkId
        embeddingVec
        modelName
    end

    methods
        function obj = Embedding(chunkId, embeddingVec, modelName)
            obj.chunkId = chunkId;
            obj.embeddingVec = embeddingVec;
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
        labelMat
        embeddingMat
        weightMat
    end

    methods
        function obj = BaselineModel(labelMat, embeddingMat)
            obj.labelMat = labelMat;
            obj.embeddingMat = embeddingMat;
            obj.weightMat = [];
        end
        
        function train(obj, epochs, lr)
            % Train the classifier.
        end
        
        function probs = predict(obj, embeddingVec)
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
        paramStruct
    end

    methods
        function obj = ProjectionHead(inputDim, outputDim)
            obj.inputDim = inputDim;
            obj.outputDim = outputDim;
            obj.paramStruct = struct();
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
        stateStruct
    end

    methods
        function obj = Encoder(baseModel)
            obj.baseModel = baseModel;
            obj.stateStruct = [];
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
        scoreStruct  % e.g., containers.Map or struct
    end

    methods
        function obj = Metrics(metricName, scoreStruct)
            obj.metricName = metricName;
            obj.scoreStruct = scoreStruct;
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
        versionId
        documentVec  % Array of Document
    end

    methods
        function obj = CorpusVersion(versionId, documentVec)
            obj.versionId = versionId;
            obj.documentVec = documentVec;
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
        
        function plotTrend(~, metricHistoryVec, path)
            % Render line chart for metric trends over versions.
        end
    end
end


**Controller Layer (+controller)**

classdef IngestionController
    %INGESTIONCONTROLLER Parses PDFs and returns Document objects.
    
    methods
        function documentVec = run(~, sourcePaths)
            documentVec = [];
        end
    end
end


classdef ChunkingController
    %CHUNKINGCONTROLLER Splits documents into overlapping chunks.
    
    methods
        function chunkVec = run(~, documentVec, window, overlap)
            chunkVec = [];
        end
    end
end

classdef WeakLabelingController
    %WEAKLABELINGCONTROLLER Applies heuristic rules to label chunks.
    
    methods
        function labelMat = run(~, chunkVec, labelingRules)
            labelMat = [];
        end
    end
end


classdef EmbeddingController
    %EMBEDDINGCONTROLLER Generates embeddings for chunks.
    
    methods
        function embeddingMat = run(~, chunkVec, modelName)
            embeddingMat = [];
        end
    end
end


classdef BaselineController
    %BASELINECONTROLLER Trains baseline classifier and serves retrieval.
    
    methods
        function model = train(~, labelMat, embeddingMat)
            model = [];
        end

        function chunkVec = retrieve(~, queryEmbeddingVec, topK)
            chunkVec = [];
        end
    end
end

classdef ProjectionHeadController
    %PROJECTIONHEADCONTROLLER Manages projection head training and usage.
    
    methods
        function head = fit(~, embeddingMat, labelMat)
            head = [];
        end

        function transformed = apply(~, projectionHead, embeddingMat)
            transformed = [];
        end
    end
end


classdef FineTuneController
    %FINETUNECONTROLLER Fine-tunes base models.
    
    methods
        function encoder = run(~, datasetTbl, baseModel)
            encoder = [];
        end
    end
end


classdef EvaluationController
    %EVALUATIONCONTROLLER Computes metrics and generates reports.
    
    methods
        function metrics = evaluate(~, model, testEmbeddingMat, trueLabelMat)
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
        function corpusStruct = fetch(~, sources)
            corpusStruct = [];
        end
        
        function diffVersions(~, oldVersionId, newVersionId, outDir)
            % Run diff and trigger DiffReportView.
        end
    end
end


classdef PipelineController
    %PIPELINECONTROLLER High-level orchestration based on dependency graph.
    
    properties
        controllerStruct % Struct or containers.Map holding controller instances
    end

    methods
        function obj = PipelineController(controllerStruct)
            obj.controllerStruct = controllerStruct;
        end

        function execute(obj, configStruct)
            % Execute pipeline steps using obj.controllerStruct.
        end
    end
end


classdef TestController
    %TESTCONTROLLER Executes continuous test suite.
    
    methods
        function results = runTests(~, selectorVec)
            if nargin < 2
                selectorVec = [];
            end
            results = struct();
        end
    end
end


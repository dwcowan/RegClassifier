**Model Layer**

| Class           | Purpose & Key Data                                                                 |
| --------------- | ---------------------------------------------------------------------------------- |
| `documentClass` | Represents raw PDF text with identifiers (`docId`, `text`)                         |
| `chunkClass`         | Overlapping token segments of documents (`chunkId`, `docId`, `text`)               |
| `labelMatrixClass`   | Sparse weak labels (`labelMat`) aligned to chunks and topics                       |
| `embeddingClass`     | Vector representation of each chunk (`embeddingVec`) produced by BERT or fallback models |
| `baselineModelClass` | Multi‑label classifier and hybrid retrieval artifacts                              |
| `projectionHeadClass`| MLP fine-tuning frozen embeddings to enhance retrieval                             |
| `encoderClass`       | Fine‑tuned BERT weights for contrastive learning workflows                         |
| `metricsClass`       | Evaluation results and per‑label performance data                                  |
| `corpusVersionClass` | Versioned corpora for diff operations and reports (`versionId`, `documentVec`)      |


**View Layer (+view)**


| Class Path                 | Purpose                                                                        |
| -------------------------- | ------------------------------------------------------------------------------ |
| `+view/evalReportViewClass.m`   | Generates PDF/HTML reports summarizing metrics and trends\\:codex-file-citation |
| `+view/diffReportViewClass.m`   | Presents HTML or PDF diffs between regulatory versions\\:codex-file-citation    |
| `+view/metricsPlotsViewClass.m` | Visualizes metrics/heatmaps (e.g., coretrieval, trend plots).                  |

**Controller Layer (+controller)**

| Class Path                               | Purpose                                                                       |
| ---------------------------------------- | ----------------------------------------------------------------------------- |
| `+controller/ingestionControllerClass.m`      | Runs `reg.ingest_pdfs` to populate `model.documentClass` models\:codex-file-citation |
| `+controller/chunkingControllerClass.m`       | Splits documents into `model.chunkClass` models via `reg.chunk_text`\:codex-file-citation |
| `+controller/weakLabelingControllerClass.m`   | Applies heuristic rules to create `model.labelMatrixClass` models\:codex-file-citation |
| `+controller/embeddingControllerClass.m`      | Generates and caches `model.embeddingClass` models (`reg.doc_embeddings_bert_gpu`)\:codex-file-citation |
| `+controller/baselineControllerClass.m`       | Trains `model.baselineModelClass` and serves retrieval (`reg.train_multilabel`, `reg.hybrid_search`)\:codex-file-citation |
| `+controller/projectionHeadControllerClass.m` | Fits `model.projectionHeadClass` and integrates it into the pipeline\:codex-file-citation |
| `+controller/fineTuneControllerClass.m`       | Builds contrastive datasets and produces `model.encoderClass` models\:codex-file-citation |
| `+controller/evaluationControllerClass.m`     | Computes metrics and invokes `view.evalReportViewClass` and gold pack evaluation\:codex-file-citation |
| `+controller/dataAcquisitionControllerClass.m`| Fetches regulatory corpora and triggers diff analyses with `view.diffReportViewClass`\:codex-file-citation |
| `+controller/pipelineControllerClass.m`       | Orchestrates end‑to‑end execution based on module dependencies\:codex-file-citation |
| `+controller/testControllerClass.m`           | Executes continuous test suite to maintain reliability\:codex-file-citation |

## Class Definitions

**Model Layer (+model)**

% +model/documentClass.m
classdef documentClass
    %DOCUMENT Represents a regulatory PDF document.
    
    properties
        docId   % Unique identifier
        text    % Raw text content
    end

    methods
        function obj = documentClass(docId, text)
            obj.docId = docId;
            obj.text = text;
        end
        
        function n = tokenCount(obj)
            % Return number of tokens in text.
            n = numel(obj.text);
        end
        
        function metadataStruct = metadata(obj)
            % Return additional metadata (source, title, etc.).
            metadataStruct = struct();
        end
    end
end


% +model/chunkClass.m
classdef chunkClass
    %CHUNK Overlapping text segment from a document.
    
    properties
        chunkId
        docId
        text
        startIndex
        endIndex
    end

    methods
        function obj = chunkClass(chunkId, docId, text, startIndex, endIndex)
            obj.chunkId = chunkId;
            obj.docId = docId;
            obj.text = text;
            obj.startIndex = startIndex;
            obj.endIndex = endIndex;
        end
        
        function n = tokenCount(obj)
            % Return number of tokens in text.
            n = numel(obj.text);
        end
        
        function tf = overlaps(obj, other)
            % Determine if two chunks overlap in a document.
            tf = false;
        end
    end
end


% +model/labelMatrixClass.m
classdef labelMatrixClass
    %LABELMATRIX Sparse weak labels per chunk and topic.
    
    properties
        chunkIdVec
        topicIdVec
        labelMat  % Sparse representation
    end

    methods
        function obj = labelMatrixClass(chunkIdVec, topicIdVec, labelMat)
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


% +model/embeddingClass.m
classdef embeddingClass
    %EMBEDDING Vector representation of a chunk.
    
    properties
        chunkId
        embeddingVec
        modelName
    end

    methods
        function obj = embeddingClass(chunkId, embeddingVec, modelName)
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

% +model/baselineModelClass.m
classdef baselineModelClass
    %BASELINEMODEL Multi-label classifier and hybrid retrieval index.
    
    properties
        labelMat
        embeddingMat
        weightMat
    end

    methods
        function obj = baselineModelClass(labelMat, embeddingMat)
            obj.labelMat = labelMat;
            obj.embeddingMat = embeddingMat;
            obj.weightMat = [];
        end

        function train(obj, numEpochs, learningRate)
            % Train the classifier.
        end

        function probabilityVec = predict(obj, embeddingVec)
            % Predict label probabilities for a single embedding.
            probabilityVec = [];
        end
        
        function save(obj, path)
            % Serialize model to disk.
        end
    end
end



% +model/projectionHeadClass.m
classdef projectionHeadClass
    %PROJECTIONHEAD MLP or shallow network for embedding transformation.
    
    properties
        inputDim
        outputDim
        paramStruct
    end

    methods
        function obj = projectionHeadClass(inputDim, outputDim)
            obj.inputDim = inputDim;
            obj.outputDim = outputDim;
            obj.paramStruct = struct();
        end

        function fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            % Train projection head.
        end

        function embeddingMatTrans = transform(obj, embeddingMat)
            % Apply transformation to embeddings.
            embeddingMatTrans = [];
        end
    end
end


% +model/encoderClass.m
classdef encoderClass
    %ENCODER Fine-tuned model for contrastive learning.
    
    properties
        baseModel
        stateStruct
    end

    methods
        function obj = encoderClass(baseModel)
            obj.baseModel = baseModel;
            obj.stateStruct = [];
        end

        function fineTune(obj, dataset, numEpochs, learningRate)
            % Contrastive fine-tuning procedure.
        end
        
        function emb = encode(obj, text)
            % Convert text to embedding.
            emb = [];
        end
    end
end


% +model/metricsClass.m
classdef metricsClass
    %METRICS Encapsulates evaluation results.
    
    properties
        metricName
        scoreStruct  % e.g., containers.Map or struct
    end

    methods
        function obj = metricsClass(metricName, scoreStruct)
            obj.metricName = metricName;
            obj.scoreStruct = scoreStruct;
        end
        
        function s = summary(obj)
            % Return human-readable summary of metrics.
            s = "";
        end
    end
end


% +model/corpusVersionClass.m
classdef corpusVersionClass
    %CORPUSVERSION Versioned corpus handling for diff operations.
    
    properties
        versionId
        documentVec  % Array of documentClass
    end

    methods
        function obj = corpusVersionClass(versionId, documentVec)
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

% +view/evalReportViewClass.m
classdef evalReportViewClass
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

% +view/diffReportViewClass.m
classdef diffReportViewClass
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


% +view/metricsPlotsViewClass.m
classdef metricsPlotsViewClass
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

% +controller/ingestionControllerClass.m
classdef ingestionControllerClass
    %INGESTIONCONTROLLER Parses PDFs and returns documentClass objects.
    
    methods
        function documentVec = run(~, sourcePaths)
            documentVec = [];
        end
    end
end


% +controller/chunkingControllerClass.m
classdef chunkingControllerClass
    %CHUNKINGCONTROLLER Splits documents into overlapping chunks.
    
    methods
        function chunkVec = run(~, documentVec, window, overlap)
            chunkVec = [];
        end
    end
end

% +controller/weakLabelingControllerClass.m
classdef weakLabelingControllerClass
    %WEAKLABELINGCONTROLLER Applies heuristic rules to label chunks.
    
    methods
        function labelMat = run(~, chunkVec, labelingRules)
            labelMat = [];
        end
    end
end


% +controller/embeddingControllerClass.m
classdef embeddingControllerClass
    %EMBEDDINGCONTROLLER Generates embeddings for chunks.
    
    methods
        function embeddingMat = run(~, chunkVec, modelName)
            embeddingMat = [];
        end
    end
end


% +controller/baselineControllerClass.m
classdef baselineControllerClass
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

% +controller/projectionHeadControllerClass.m
classdef projectionHeadControllerClass
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


% +controller/fineTuneControllerClass.m
classdef fineTuneControllerClass
    %FINETUNECONTROLLER Fine-tunes base models.
    
    methods
        function encoder = run(~, datasetTbl, baseModel)
            encoder = [];
        end
    end
end


% +controller/evaluationControllerClass.m
classdef evaluationControllerClass
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


% +controller/dataAcquisitionControllerClass.m
classdef dataAcquisitionControllerClass
    %DATAACQUISITIONCONTROLLER Fetches corpora and runs diffs.
    
    methods
        function corpusStruct = fetch(~, sources)
            corpusStruct = [];
        end
        
        function diffVersions(~, oldVersionId, newVersionId, outDir)
            % Run diff and trigger diffReportViewClass.
        end
    end
end


% +controller/pipelineControllerClass.m
classdef pipelineControllerClass
    %PIPELINECONTROLLER High-level orchestration based on dependency graph.
    
    properties
        controllerStruct % Struct or containers.Map holding controller instances
    end

    methods
        function obj = pipelineControllerClass(controllerStruct)
            obj.controllerStruct = controllerStruct;
        end

        function execute(obj, configStruct)
            % Execute pipeline steps using obj.controllerStruct.
        end
    end
end


% +controller/testControllerClass.m
classdef testControllerClass
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


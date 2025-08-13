**Model Layer**

| Class           | Purpose & Key Data                                                                 |
| --------------- | ---------------------------------------------------------------------------------- |
| `documentClass` | Represents raw PDF text with identifiers (`docId`, `text`)                         |
| `chunkClass`         | Overlapping token segments of documents (`chunkId`, `docId`, `text`)               |
| `labelMatrixClass`   | Sparse weak labels (`labelMat`) aligned to chunks and topics                       |
| `embeddingClass`     | Vector representation of each chunk (`embeddingVec`) produced by BERT or fallback models |
| `baselineModelClass` | Multi‑label classifier and hybrid retrieval artifacts                              |
| `projectionHeadClass`| MLP fine-tuning frozen embeddings; defines `fit` and `transform` so training stays in the model layer |
| `encoderClass`       | Fine‑tuned BERT weights for contrastive learning workflows                         |
| `metricsClass`       | Evaluation results and per‑label performance data                                  |
| `corpusVersionClass` | Versioned corpora for diff operations and reports (`versionId`, `documentVec`)      |


**View Layer (+view)**


| Class Path                 | Purpose                                                                        |
| -------------------------- | ------------------------------------------------------------------------------ |
| `+view/evalReportViewClass.m`   | Generates PDF/HTML reports summarizing metrics and trends |
| `+view/diffReportViewClass.m`   | Presents HTML or PDF diffs between regulatory versions    |
| `+view/metricsPlotsViewClass.m` | Visualizes metrics/heatmaps (e.g., coretrieval, trend plots).                  |

**Controller Layer (+controller)**

| Class Path                               | Purpose                                                                       |
| ---------------------------------------- | ----------------------------------------------------------------------------- |
| `+controller/ingestionControllerClass.m`      | Runs `reg.ingestPdfs` to populate `model.documentClass` models |
| `+controller/chunkingControllerClass.m`       | Splits documents into `model.chunkClass` models via `reg.chunkText` |
| `+controller/weakLabelingControllerClass.m`   | Applies heuristic rules to create `model.labelMatrixClass` models |
| `+controller/embeddingControllerClass.m`      | Generates and caches `model.embeddingClass` models (`reg.docEmbeddingsBertGpu`) |
| `+controller/baselineControllerClass.m`       | Trains `model.baselineModelClass` and serves retrieval (`reg.trainMultilabel`, `reg.hybridSearch`) |
| `+controller/projectionHeadControllerClass.m` | Instantiates `model.projectionHeadClass` and delegates calls without duplicate training logic |
| `+controller/fineTuneControllerClass.m`       | Builds contrastive datasets and produces `model.encoderClass` models |
| `+controller/evaluationControllerClass.m`     | Computes metrics and invokes `view.evalReportViewClass` and gold pack evaluation |
| `+controller/dataAcquisitionControllerClass.m`| Fetches regulatory corpora and triggers diff analyses with `view.diffReportViewClass` |
| `+controller/pipelineControllerClass.m`       | Orchestrates end‑to‑end execution based on module dependencies |
| `+controller/testControllerClass.m`           | Executes continuous test suite to maintain reliability |

## Class Definitions

**Model Layer (+model)**

% +model/documentClass.m
classdef documentClass
    %DOCUMENT Represents a regulatory PDF document.

    properties (Access=public)
        docId   % Unique identifier
        text    % Raw text content
    end

    methods (Access=public)
        function obj = documentClass(docId, text)
            %DOCUMENTCLASS Construct a documentClass instance.
            %   obj = documentClass(docId, text)
            %   docId (string): Unique identifier.
            %   text (string): Raw text content.
            %   obj (documentClass): New instance.
            %
            %   Side effects: none.
            obj.docId = docId;
            obj.text = text;
        end

        function n = tokenCount(obj)
            %TOKENCOUNT Return number of tokens in text.
            %   n = tokenCount(obj)
            %   obj (documentClass): Instance.
            %   n (double): Number of tokens.
            %
            %   Side effects: none.
            n = numel(obj.text);
        end

        function metadataStruct = metadata(obj)
            %METADATA Return additional metadata.
            %   metadataStruct = metadata(obj)
            %   obj (documentClass): Instance.
            %   metadataStruct (struct): Meta information.
            %
            %   Side effects: none.
            metadataStruct = struct();
        end
    end
end


% +model/chunkClass.m
classdef chunkClass
    %CHUNK Overlapping text segment from a document.

    properties (Access=public)
        chunkId   % double: Chunk identifier
        docId
        text
        startIndex
        endIndex
    end

    methods (Access=public)
        function obj = chunkClass(chunkId, docId, text, startIndex, endIndex)
            %CHUNKCLASS Construct chunkClass instance.
            %   obj = chunkClass(chunkId, docId, text, startIndex, endIndex)
            %   chunkId (double): Chunk identifier.
            %   docId (string): Document identifier.
            %   text (string): Chunk text.
            %   startIndex (double): Start token index.
            %   endIndex (double): End token index.
            %   obj (chunkClass): New instance.
            %
            %   Side effects: none.
            obj.chunkId = chunkId;
            obj.docId = docId;
            obj.text = text;
            obj.startIndex = startIndex;
            obj.endIndex = endIndex;
        end

        function n = tokenCount(obj)
            %TOKENCOUNT Return number of tokens in text.
            %   n = tokenCount(obj)
            %   obj (chunkClass): Instance.
            %   n (double): Number of tokens.
            %
            %   Side effects: none.
            n = numel(obj.text);
        end

        function tf = overlaps(obj, other)
            %OVERLAPS Determine if two chunks overlap.
            %   tf = overlaps(obj, other)
            %   obj (chunkClass): First chunk.
            %   other (chunkClass): Second chunk.
            %   tf (logical): True if overlapping.
            %
            %   Side effects: none.
            tf = false;
        end
    end
end


% +model/labelMatrixClass.m
classdef labelMatrixClass
    %LABELMATRIX Sparse weak labels per chunk and topic.
    
    properties (Access=public)
        chunkIdVec  % double Vec: Chunk identifiers
        topicIdVec  % double Vec: Topic identifiers
        labelMat    % sparse double Mat: Label weights
    end

    methods (Access=public)
        function obj = labelMatrixClass(chunkIdVec, topicIdVec, labelMat)
            %LABELMATRIXCLASS Construct labelMatrixClass instance.
            %   obj = labelMatrixClass(chunkIdVec, topicIdVec, labelMat)
            %   chunkIdVec (double Vec): Chunk identifiers.
            %   topicIdVec (double Vec): Topic identifiers.
            %   labelMat (sparse double Mat): Label weights.
            %   obj (labelMatrixClass): New instance.
            %
            %   Side effects: none.
            obj.chunkIdVec = chunkIdVec;
            obj.topicIdVec = topicIdVec;
            obj.labelMat = labelMat;
        end

        function addLabel(obj, chunkId, topicId, weight)
            %ADDLABEL Insert or update a label weight.
            %   addLabel(obj, chunkId, topicId, weight)
            %   obj (labelMatrixClass): Instance.
            %   chunkId (double): Chunk identifier.
            %   topicId (double): Topic identifier.
            %   weight (double): Label weight.
            %
            %   Side effects: modifies labelMat.
        end

        function labels = getLabelsForChunk(obj, chunkId)
            %GETLABELSFORCHUNK Return topic-weight pairs for a chunk.
            %   labels = getLabelsForChunk(obj, chunkId)
            %   obj (labelMatrixClass): Instance.
            %   chunkId (double): Chunk identifier.
            %   labels (struct): Topics and weights.
            %
            %   Side effects: none.
            labels = struct();
        end
    end
end


% +model/embeddingClass.m
classdef embeddingClass
    %EMBEDDING Vector representation of a chunk.

    properties (Access=public)
        chunkId      % double: Chunk identifier
        embeddingVec % double Vec: Embedding vector
        modelName    % string: Source model name
    end

    methods (Access=public)
        function obj = embeddingClass(chunkId, embeddingVec, modelName)
            %EMBEDDINGCLASS Construct embeddingClass instance.
            %   obj = embeddingClass(chunkId, embeddingVec, modelName)
            %   chunkId (double): Chunk identifier.
            %   embeddingVec (double Vec): Embedding vector.
            %   modelName (string): Source model name.
            %   obj (embeddingClass): New instance.
            %
            %   Side effects: none.
            obj.chunkId = chunkId;
            obj.embeddingVec = embeddingVec;
            obj.modelName = modelName;
        end

        function sim = cosineSimilarity(obj, other)
            %COSINESIMILARITY Compute cosine similarity with another embedding.
            %   sim = cosineSimilarity(obj, other)
            %   obj (embeddingClass): First embedding.
            %   other (embeddingClass): Second embedding.
            %   sim (double): Cosine similarity score.
            %
            %   Side effects: none.
            sim = 0;
        end

        function normalize(obj)
            %NORMALIZE Normalize vector in-place.
            %   normalize(obj)
            %   obj (embeddingClass): Instance.
            %
            %   Side effects: modifies embeddingVec.
        end
    end
end

% +model/baselineModelClass.m
classdef baselineModelClass
    %BASELINEMODEL Multi-label classifier and hybrid retrieval index.

    properties (Access=public)
        labelMat     % double Mat: Label matrix
        embeddingMat % double Mat: Embedding matrix
        weightMat    % double Mat: Model weights
    end

    methods (Access=public)
        function obj = baselineModelClass(labelMat, embeddingMat)
            %BASELINEMODELCLASS Construct baseline model.
            %   obj = baselineModelClass(labelMat, embeddingMat)
            %   labelMat (double Mat): Label matrix.
            %   embeddingMat (double Mat): Embedding matrix.
            %   obj (baselineModelClass): New instance.
            %
            %   Side effects: none.
            obj.labelMat = labelMat;
            obj.embeddingMat = embeddingMat;
            obj.weightMat = [];
        end

        function train(obj, numEpochs, learningRate)
            %TRAIN Train the classifier.
            %   train(obj, numEpochs, learningRate)
            %   obj (baselineModelClass): Instance.
            %   numEpochs (double): Number of training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates weightMat.
        end

        function probabilityVec = predict(obj, embeddingVec)
            %PREDICT Predict label probabilities for a single embedding.
            %   probabilityVec = predict(obj, embeddingVec)
            %   obj (baselineModelClass): Instance.
            %   embeddingVec (double Vec): Input embedding.
            %   probabilityVec (double Vec): Predicted probabilities.
            %
            %   Side effects: none.
            probabilityVec = [];
        end

        function chunkVec = retrieve(obj, queryEmbeddingVec, topK)
            %RETRIEVE Retrieve top chunks for query embedding.
            %   chunkVec = retrieve(obj, queryEmbeddingVec, topK)
            %   obj (baselineModelClass): Instance.
            %   queryEmbeddingVec (double Vec): Query embedding.
            %   topK (double): Number of results.
            %   chunkVec (chunkClass Vec): Retrieved chunks.
            %
            %   Side effects: none.
            chunkVec = [];
        end

        function save(obj, path)
            %SAVE Serialize model to disk.
            %   save(obj, path)
            %   obj (baselineModelClass): Instance.
            %   path (string): File path.
            %
            %   Side effects: writes model to disk.
        end
    end
end



% +model/projectionHeadClass.m
classdef projectionHeadClass
    %PROJECTIONHEAD MLP or shallow network for embedding transformation.

    properties (Access=public)
        inputDim    % double: Input dimension
        outputDim   % double: Output dimension
        paramStruct % struct: Learnable parameters
    end

    methods (Access=public)
        function obj = projectionHeadClass(inputDim, outputDim)
            %PROJECTIONHEADCLASS Construct projection head.
            %   obj = projectionHeadClass(inputDim, outputDim)
            %   inputDim (double): Input dimension.
            %   outputDim (double): Output dimension.
            %   obj (projectionHeadClass): New instance.
            %
            %   Side effects: initializes paramStruct.
            obj.inputDim = inputDim;
            obj.outputDim = outputDim;
            obj.paramStruct = struct();
        end

        function fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %FIT Train projection head.
            %   fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %   obj (projectionHeadClass): Instance.
            %   embeddingMat (double Mat): Embedding matrix.
            %   labelMat (double Mat): Labels.
            %   numEpochs (double): Training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates paramStruct.
        end

        function embeddingMatTrans = transform(obj, embeddingMat)
            %TRANSFORM Apply transformation to embeddings.
            %   embeddingMatTrans = transform(obj, embeddingMat)
            %   obj (projectionHeadClass): Instance.
            %   embeddingMat (double Mat): Input embeddings.
            %   embeddingMatTrans (double Mat): Transformed embeddings.
            %
            %   Side effects: none.
            embeddingMatTrans = [];
        end
    end
end

% +model/encoderClass.m
classdef encoderClass
    %ENCODER Fine-tuned model for contrastive learning.

    properties (Access=public)
        baseModel   % struct: Base model data
        stateStruct % struct: Fine-tuned weights
    end

    methods (Access=public)
        function obj = encoderClass(baseModel)
            %ENCODERCLASS Construct encoderClass.
            %   obj = encoderClass(baseModel)
            %   baseModel (struct): Base model data.
            %   obj (encoderClass): New instance.
            %
            %   Side effects: none.
            obj.baseModel = baseModel;
            obj.stateStruct = [];
        end

        function fineTune(obj, dataset, numEpochs, learningRate)
            %FINETUNE Contrastive fine-tuning procedure.
            %   fineTune(obj, dataset, numEpochs, learningRate)
            %   obj (encoderClass): Instance.
            %   dataset (Tbl): Training dataset.
            %   numEpochs (double): Training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates stateStruct.
        end

        function emb = encode(obj, text)
            %ENCODE Convert text to embedding.
            %   emb = encode(obj, text)
            %   obj (encoderClass): Instance.
            %   text (string): Input text.
            %   emb (double Vec): Embedding.
            %
            %   Side effects: none.
            emb = [];
        end
    end
end


% +model/metricsClass.m
classdef metricsClass
    %METRICS Encapsulates evaluation results.

    properties (Access=public)
        metricName  % string: Name of metric set
        scoreStruct % struct: Metric scores
    end

    methods (Access=public)
        function obj = metricsClass(metricName, scoreStruct)
            %METRICSCLASS Construct metricsClass instance.
            %   obj = metricsClass(metricName, scoreStruct)
            %   metricName (string): Name of metric set.
            %   scoreStruct (struct): Scores.
            %   obj (metricsClass): New instance.
            %
            %   Side effects: none.
            obj.metricName = metricName;
            obj.scoreStruct = scoreStruct;
        end

        function s = summary(obj)
            %SUMMARY Return human-readable summary of metrics.
            %   s = summary(obj)
            %   obj (metricsClass): Instance.
            %   s (string): Summary text.
            %
            %   Side effects: none.
            s = "";
        end
    end
end


% +model/corpusVersionClass.m
classdef corpusVersionClass
    %CORPUSVERSION Versioned corpus handling for diff operations.

    properties (Access=public)
        versionId   % string: Corpus version identifier
        documentVec % documentClass Vec: Documents in version
    end

    methods (Access=public)
        function obj = corpusVersionClass(versionId, documentVec)
            %CORPUSVERSIONCLASS Construct corpusVersionClass.
            %   obj = corpusVersionClass(versionId, documentVec)
            %   versionId (string): Identifier for corpus version.
            %   documentVec (documentClass Vec): Documents.
            %   obj (corpusVersionClass): New instance.
            %
            %   Side effects: none.
            obj.versionId = versionId;
            obj.documentVec = documentVec;
        end

        function diffResult = diff(obj, other)
            %DIFF Return differences between versions.
            %   diffResult = diff(obj, other)
            %   obj (corpusVersionClass): First version.
            %   other (corpusVersionClass): Second version.
            %   diffResult (struct): Differences.
            %
            %   Side effects: none.
            diffResult = struct();
        end
    end
end


**View Layer (+view)**

% +view/evalReportViewClass.m
classdef evalReportViewClass
    %EVALREPORTVIEW Renders evaluation metrics into report format.
    
    methods (Access=public)
        function renderPDF(~, metrics, path)
            %RENDERPDF Generate PDF report.
            %   renderPDF(obj, metrics, path)
            %   metrics (metricsClass): Metrics to report.
            %   path (string): Output PDF path.
            %
            %   Side effects: writes file to disk.
        end

        function renderHTML(~, metrics, path)
            %RENDERHTML Generate HTML report.
            %   renderHTML(obj, metrics, path)
            %   metrics (metricsClass): Metrics to report.
            %   path (string): Output HTML path.
            %
            %   Side effects: writes file to disk.
        end
    end
end

% +view/diffReportViewClass.m
classdef diffReportViewClass
    %DIFFREPORTVIEW Renders document diffs between corpus versions.
    %   Expects diff results from a controller or caller that computes
    %   version differences.
    
    methods (Access=public)
        function render(~, diffResult, path, fmt)
            %RENDER Generate diff report in HTML or PDF.
            %   render(obj, diffResult, path, fmt)
            %   diffResult (struct): Differences to display.
            %   path (string): Output path.
            %   fmt (string): 'html' or 'pdf'.
            %
            %   Side effects: writes file to disk.
            if nargin < 4
                fmt = "html";
            end
        end
    end
end


% +view/metricsPlotsViewClass.m
classdef metricsPlotsViewClass
    %METRICSPLOTSVIEW Creates visual plots for metrics and trends.
    
    methods (Access=public)
        function plotHeatmap(~, metrics, path)
            %PLOTHEATMAP Render heatmap from metric matrix.
            %   plotHeatmap(obj, metrics, path)
            %   metrics (metricsClass): Metrics to visualize.
            %   path (string): Output path.
            %
            %   Side effects: writes file to disk.
        end

        function plotTrend(~, metricHistoryVec, path)
            %PLOTTREND Render line chart for metric trends.
            %   plotTrend(obj, metricHistoryVec, path)
            %   metricHistoryVec (metricsClass Vec): Metrics over time.
            %   path (string): Output path.
            %
            %   Side effects: writes file to disk.
        end
    end
end


**Controller Layer (+controller)**

% +controller/ingestionControllerClass.m
classdef ingestionControllerClass
    %INGESTIONCONTROLLER Parses PDFs and returns documentClass objects.
    
    methods (Access=public)
        function documentVec = run(~, sourcePaths)
            %RUN Parse PDFs to documents.
            %   documentVec = run(obj, sourcePaths)
            %   sourcePaths (string Cell): Paths to PDFs.
            %   documentVec (documentClass Vec): Parsed documents.
            %
            %   Side effects: reads files from disk.
            documentVec = [];
        end
    end
end


% +controller/chunkingControllerClass.m
classdef chunkingControllerClass
    %CHUNKINGCONTROLLER Splits documents into overlapping chunks.
    
    methods (Access=public)
        function chunkVec = run(~, documentVec, window, overlap)
            %RUN Split documents into chunks.
            %   chunkVec = run(obj, documentVec, window, overlap)
            %   documentVec (documentClass Vec): Documents.
            %   window (double): Window size.
            %   overlap (double): Overlap amount.
            %   chunkVec (chunkClass Vec): Generated chunks.
            %
            %   Side effects: none.
            chunkVec = [];
        end
    end
end

% +controller/weakLabelingControllerClass.m
classdef weakLabelingControllerClass
    %WEAKLABELINGCONTROLLER Applies heuristic rules to label chunks.
    
    methods (Access=public)
        function labelMatrixObj = run(~, chunkVec, labelingRules)
            %RUN Apply weak labeling rules.
            %   labelMatrixObj = run(obj, chunkVec, labelingRules)
            %   chunkVec (chunkClass Vec): Chunks to label.
            %   labelingRules (cell): Rules.
            %   labelMatrixObj (labelMatrixClass): Generated labels.
            %
            %   Side effects: none.
            labelMat = [];
            labelMatrixObj = model.labelMatrixClass([], [], labelMat);
        end
    end
end


% +controller/embeddingControllerClass.m
classdef embeddingControllerClass
    %EMBEDDINGCONTROLLER Generates embeddings for chunks.
    
    methods (Access=public)
        function embeddingVec = run(~, chunkVec, modelName)
            %RUN Generate embeddings.
            %   embeddingVec = run(obj, chunkVec, modelName)
            %   chunkVec (chunkClass Vec): Chunks to embed.
            %   modelName (string): Model to use.
            %   embeddingVec (embeddingClass Vec): Embeddings.
            %
            %   Side effects: may cache embeddings.
            embeddingVec = model.embeddingClass.empty();
        end
    end
end


% +controller/baselineControllerClass.m
classdef baselineControllerClass
    %BASELINECONTROLLER Constructs baseline model and delegates operations.

    methods (Access=public)
        function model = train(~, labelMatrixObj, embeddingVec, numEpochs, learningRate)
            %TRAIN Fit baseline classifier via model.
            %   model = train(obj, labelMatrixObj, embeddingVec, numEpochs, learningRate)
            %   labelMatrixObj (labelMatrixClass): Labels.
            %   embeddingVec (embeddingClass Vec): Embeddings.
            %   numEpochs (double): Number of training epochs.
            %   learningRate (double): Step size.
            %   model (baselineModelClass): Trained model.
            %
            %   Side effects: none.
            baselineModel = model.baselineModelClass(labelMatrixObj, embeddingVec);
            baselineModel.train(numEpochs, learningRate);
            model = baselineModel;
        end

        function chunkVec = retrieve(~, model, queryEmbeddingVec, topK)
            %RETRIEVE Retrieve top chunks using model.
            %   chunkVec = retrieve(obj, model, queryEmbeddingVec, topK)
            %   model (baselineModelClass): Model to query.
            %   queryEmbeddingVec (double Vec): Query embedding.
            %   topK (double): Number of results.
            %   chunkVec (chunkClass Vec): Retrieved chunks.
            %
            %   Side effects: none.
            chunkVec = model.retrieve(queryEmbeddingVec, topK);
        end
    end
end

% +controller/projectionHeadControllerClass.m
classdef projectionHeadControllerClass
    %PROJECTIONHEADCONTROLLERCLASS Instantiates projection head model and delegates work.

    properties (Access=private)
        head % projectionHeadClass instance
    end

    methods (Access=public)
        function obj = projectionHeadControllerClass(inputDim, outputDim)
            %PROJECTIONHEADCONTROLLERCLASS Construct controller and underlying model.
            %   obj = projectionHeadControllerClass(inputDim, outputDim)
            %   inputDim (double): Input dimension.
            %   outputDim (double): Output dimension.
            %   obj (projectionHeadControllerClass): New instance.
            obj.head = model.projectionHeadClass(inputDim, outputDim);
        end

        function train(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %TRAIN Delegate training to projectionHeadClass.
            obj.head.fit(embeddingMat, labelMat, numEpochs, learningRate);
        end

        function embeddingMatTrans = project(obj, embeddingMat)
            %PROJECT Delegate projection to projectionHeadClass.
            embeddingMatTrans = obj.head.transform(embeddingMat);
        end
    end
end

% +controller/fineTuneControllerClass.m
classdef fineTuneControllerClass
    %FINETUNECONTROLLER Fine-tunes base models.
    
    methods (Access=public)
        function encoder = run(~, datasetTbl, baseModel)
            %RUN Fine-tune encoder.
            %   encoder = run(obj, datasetTbl, baseModel)
            %   datasetTbl (Tbl): Training data.
            %   baseModel (encoderClass): Base model.
            %   encoder (encoderClass): Fine-tuned encoder.
            %
            %   Side effects: none.
            encoder = [];
        end
    end
end


% +controller/evaluationControllerClass.m
classdef evaluationControllerClass
    %EVALUATIONCONTROLLER Computes metrics and generates reports.
    
    methods (Access=public)
        function metrics = evaluate(~, model, testEmbeddingMat, trueLabelMat)
            %EVALUATE Compute metrics for model.
            %   metrics = evaluate(obj, model, testEmbeddingMat, trueLabelMat)
            %   model (baselineModelClass): Model to evaluate.
            %   testEmbeddingMat (double Mat): Test embeddings.
            %   trueLabelMat (double Mat): True labels.
            %   metrics (metricsClass): Results.
            %
            %   Side effects: none.
            metrics = [];
        end

        function generateReports(~, metrics, outDir, viewHandle)
            %GENERATEREPORTS Use supplied view to produce reports.
            %   generateReports(obj, metrics, outDir, viewHandle)
            %   metrics (metricsClass): Evaluation results.
            %   outDir (string): Output directory.
            %   viewHandle (evalReportViewClass|function_handle): View dependency.
            %       Must implement: render(metrics, outDir)
            %
            %   Side effects: writes reports to disk.
            if isa(viewHandle, 'function_handle')
                viewObj = viewHandle();
            else
                viewObj = viewHandle;
            end
            viewObj.render(metrics, outDir);
        end
    end
end


% +controller/dataAcquisitionControllerClass.m
classdef dataAcquisitionControllerClass
%DATAACQUISITIONCONTROLLER Fetches corpora and returns raw or diff data.
%   Report generation is handled by the caller or a dedicated controller
%   using diffReportViewClass.
    
    methods (Access=public)
        function corpusStruct = fetch(~, sources)
            %FETCH Retrieve corpora from sources.
            %   corpusStruct = fetch(obj, sources)
            %   sources (string Cell): Data sources.
            %   corpusStruct (struct): Retrieved corpus data.
            %
            %   Side effects: accesses external resources.
            corpusStruct = [];
        end

        function diffStruct = diffVersions(~, oldVersionId, newVersionId)
            %DIFFVERSIONS Compute differences between corpus versions.
            %   diffStruct = diffVersions(obj, oldVersionId, newVersionId)
            %   oldVersionId (string): Baseline version.
            %   newVersionId (string): New version.
            %   diffStruct (struct): Differences between versions.
            %
            %   Side effects: accesses external resources.
        end
    end
end


% +controller/pipelineControllerClass.m
classdef pipelineControllerClass
    %PIPELINECONTROLLER High-level orchestration based on dependency graph.
    
    properties (Access=public)
        controllerStruct % Struct or containers.Map holding controller instances
    end

    methods (Access=public)
        function obj = pipelineControllerClass(controllerStruct)
            %PIPELINECONTROLLERCLASS Construct pipeline controller.
            %   obj = pipelineControllerClass(controllerStruct)
            %   controllerStruct (struct): Controller instances.
            %   obj (pipelineControllerClass): New instance.
            %
            %   Side effects: none.
            obj.controllerStruct = controllerStruct;
        end

        function execute(obj, configStruct)
            %EXECUTE Execute pipeline steps using controllerStruct.
            %   execute(obj, configStruct)
            %   obj (pipelineControllerClass): Instance.
            %   configStruct (struct): Configuration for steps.
            %
            %   Side effects: orchestrates pipeline execution.
        end
    end
end


% +controller/testControllerClass.m
classdef testControllerClass
    %TESTCONTROLLER Executes continuous test suite.
    
    methods (Access=public)
        function results = runTests(~, selectorVec)
            %RUNTESTS Execute selected tests.
            %   results = runTests(obj, selectorVec)
            %   selectorVec (string Vec): Test selectors.
            %   results (struct): Test outcomes.
            %
            %   Side effects: runs tests.
            if nargin < 2
                selectorVec = [];
            end
            results = struct();
        end
    end
end


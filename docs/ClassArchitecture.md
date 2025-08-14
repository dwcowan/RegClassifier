**Model Layer**

| Class           | Purpose & Key Data                                                                 |
| --------------- | ---------------------------------------------------------------------------------- |
| `Document` | Represents raw PDF text with identifiers (`docId`, `text`)                         |
| `Chunk`         | Overlapping token segments of documents (`chunkId`, `docId`, `text`)               |
| `LabelMatrix`   | Sparse weak labels (`labelMat`) aligned to chunks and topics                       |
| `Embedding`     | Vector representation of each chunk (`embeddingVec`) produced by BERT or fallback models |
| `BaselineModel` | Multi‑label classifier and hybrid retrieval artifacts                              |
| `ProjectionHead`| MLP fine-tuning frozen embeddings; defines `fit` and `transform` so training stays in the model layer |
| `Encoder`       | Fine‑tuned BERT weights for contrastive learning workflows                         |
| `Metrics`       | Evaluation results and per‑label performance data                                  |
| `CorpusVersion` | Versioned corpora for diff operations and reports (`versionId`, `documentVec`)      |


**View Layer (+view)**


| Class Path                 | Purpose                                                                        |
| -------------------------- | ------------------------------------------------------------------------------ |
| `+view/EvalReportView.m`   | Provides `render` dispatcher for PDF/HTML metric reports |
| `+view/DiffReportView.m`   | Presents HTML or PDF diffs between regulatory versions    |
| `+view/MetricsPlotsView.m` | Visualizes metrics/heatmaps (e.g., coretrieval, trend plots).                  |

**Controller Layer (+controller)**

| Class Path                               | Purpose                                                                       |
| ---------------------------------------- | ----------------------------------------------------------------------------- |
| `+controller/IngestionController.m`      | Runs `reg.ingestPdfs` to populate `model.Document` models |
| `+controller/ChunkingController.m`       | Splits documents into `model.Chunk` models via `reg.chunkText` |
| `+controller/WeakLabelingController.m`   | Applies heuristic rules to create `model.LabelMatrix` models |
| `+controller/EmbeddingController.m`      | Generates and caches `model.Embedding` models (`reg.docEmbeddingsBertGpu`) |
| `+controller/BaselineController.m`       | Trains `model.BaselineModel` and serves retrieval (`reg.trainMultilabel`, `reg.hybridSearch`) |
| `+controller/ProjectionHeadController.m` | Instantiates `model.ProjectionHead` and delegates calls without duplicate training logic |
| `+controller/FineTuneController.m`       | Builds contrastive datasets and produces `model.Encoder` models |
| `+controller/EvaluationController.m`     | Computes metrics and invokes `view.EvalReportView.render` and gold pack evaluation |
| `+controller/DataAcquisitionController.m`| Fetches regulatory corpora and returns `diffStruct` for `view.DiffReportView.render` |
| `+controller/PipelineController.m`       | Orchestrates end‑to‑end execution based on module dependencies |
| `+controller/TestController.m`           | Executes continuous test suite to maintain reliability |

**Helper Functions (+helpers)**

| Function Path                  | Purpose                                                              |
| ------------------------------ | -------------------------------------------------------------------- |
| `+helpers/loadCorpus.m`        | Load `model.Document` vectors for a corpus version identifier        |
| `+helpers/docSetdiff.m`       | Return documents in first corpus missing from the second by `docId` |
| `+helpers/detectChanges.m`     | Detect documents with identical `docId` but modified `text` content  |

## Class Definitions

**Model Layer (+model)**

% +model/Document.m
classdef Document
    %DOCUMENT Represents a regulatory PDF document.

    properties (Access=public)
        docId   % Unique identifier
        text    % Raw text content
    end

    methods (Access=public)
        function obj = Document(docId, text)
            %DOCUMENT Construct a Document instance.
            %   obj = Document(docId, text)
            %   docId (string): Unique identifier.
            %   text (string): Raw text content.
            %   obj (Document): New instance.
            %
            %   Side effects: none.
            obj.docId = docId;
            obj.text = text;
        end

        function n = tokenCount(obj)
            %TOKENCOUNT Return number of tokens in text.
            %   Tokens are whitespace-separated words.
            %   n = tokenCount(obj)
            %   obj (Document): Instance.
            %   n (double): Number of tokens.
            %
            %   Side effects: none.
            tokens = strsplit(obj.text);
            n = numel(tokens);
        end

        function metadataStruct = metadata(obj)
            %METADATA Return additional metadata.
            %   metadataStruct = metadata(obj)
            %   obj (Document): Instance.
            %   metadataStruct (struct): Meta information.
            %
            %   Side effects: none.
            metadataStruct = struct();
        end
    end
end


% +model/Chunk.m
classdef Chunk
    %CHUNK Overlapping text segment from a document.

    properties (Access=public)
        chunkId   % double: Chunk identifier
        docId
        text
        startIndex
        endIndex
    end

    methods (Access=public)
        function obj = Chunk(chunkId, docId, text, startIndex, endIndex)
            %CHUNK Construct Chunk instance.
            %   obj = Chunk(chunkId, docId, text, startIndex, endIndex)
            %   chunkId (double): Chunk identifier.
            %   docId (string): Document identifier.
            %   text (string): Chunk text.
            %   startIndex (double): Start token index.
            %   endIndex (double): End token index.
            %   obj (Chunk): New instance.
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
            %   Tokens are whitespace-separated words.
            %   n = tokenCount(obj)
            %   obj (Chunk): Instance.
            %   n (double): Number of tokens.
            %
            %   Side effects: none.
            tokens = strsplit(obj.text);
            n = numel(tokens);
        end

        function tf = overlaps(obj, other)
            %OVERLAPS Determine if two chunks overlap.
            %   tf = overlaps(obj, other)
            %   obj (Chunk): First chunk.
            %   other (Chunk): Second chunk.
            %   tf (logical): True if overlapping.
            %
            %   Side effects: none.
            tf = false;
        end
    end
end


% +model/LabelMatrix.m
classdef LabelMatrix
    %LABELMATRIX Sparse weak labels per chunk and topic.
    
    properties (Access=public)
        chunkIdVec  % double Vec: Chunk identifiers
        topicIdVec  % double Vec: Topic identifiers
        labelMat    % sparse double Mat: Label weights
    end

    methods (Access=public)
        function obj = LabelMatrix(chunkIdVec, topicIdVec, labelMat)
            %LABELMATRIX Construct LabelMatrix instance.
            %   obj = LabelMatrix(chunkIdVec, topicIdVec, labelMat)
            %   chunkIdVec (double Vec): Chunk identifiers.
            %   topicIdVec (double Vec): Topic identifiers.
            %   labelMat (sparse double Mat): Label weights.
            %   obj (LabelMatrix): New instance.
            %
            %   Side effects: none.
            obj.chunkIdVec = chunkIdVec;
            obj.topicIdVec = topicIdVec;
            obj.labelMat = labelMat;
        end

        function addLabel(obj, chunkId, topicId, weight)
            %ADDLABEL Insert or update a label weight.
            %   addLabel(obj, chunkId, topicId, weight)
            %   obj (LabelMatrix): Instance.
            %   chunkId (double): Chunk identifier.
            %   topicId (double): Topic identifier.
            %   weight (double): Label weight.
            %
            %   Side effects: modifies labelMat.
        end

        function labels = getLabelsForChunk(obj, chunkId)
            %GETLABELSFORCHUNK Return topic-weight pairs for a chunk.
            %   labels = getLabelsForChunk(obj, chunkId)
            %   obj (LabelMatrix): Instance.
            %   chunkId (double): Chunk identifier.
            %   labels (struct): Topics and weights.
            %
            %   Side effects: none.
            labels = struct();
        end
    end
end


% +model/Embedding.m
classdef Embedding
    %EMBEDDING Vector representation of a chunk.

    properties (Access=public)
        chunkId      % double: Chunk identifier
        embeddingVec % double Vec: Embedding vector
        modelName    % string: Source model name
    end

    methods (Access=public)
        function obj = Embedding(chunkId, embeddingVec, modelName)
            %EMBEDDING Construct Embedding instance.
            %   obj = Embedding(chunkId, embeddingVec, modelName)
            %   chunkId (double): Chunk identifier.
            %   embeddingVec (double Vec): Embedding vector.
            %   modelName (string): Source model name.
            %   obj (Embedding): New instance.
            %
            %   Side effects: none.
            obj.chunkId = chunkId;
            obj.embeddingVec = embeddingVec;
            obj.modelName = modelName;
        end

        function sim = cosineSimilarity(obj, other)
            %COSINESIMILARITY Compute cosine similarity with another embedding.
            %   sim = cosineSimilarity(obj, other)
            %   obj (Embedding): First embedding.
            %   other (Embedding): Second embedding.
            %   sim (double): Cosine similarity score.
            %
            %   Side effects: none.
            sim = 0;
        end

        function normalize(obj)
            %NORMALIZE Normalize vector in-place.
            %   normalize(obj)
            %   obj (Embedding): Instance.
            %
            %   Side effects: modifies embeddingVec.
        end
    end
end

% +model/BaselineModel.m
classdef BaselineModel
    %BASELINEMODEL Multi-label classifier and hybrid retrieval index.

    properties (Access=public)
        labelMatrixObj % LabelMatrix: Weak labels
        embeddingVec   % Embedding Vec: Embeddings
        weightMat      % double Mat: Model weights
    end

    methods (Access=public)
        function obj = BaselineModel(labelMatrixObj, embeddingVec)
            %BASELINEMODEL Construct baseline model.
            %   obj = BaselineModel(labelMatrixObj, embeddingVec)
            %   labelMatrixObj (LabelMatrix): Weak labels.
            %   embeddingVec (Embedding Vec): Embeddings.
            %   obj (BaselineModel): New instance.
            %
            %   Side effects: none.
            obj.labelMatrixObj = labelMatrixObj;
            obj.embeddingVec = embeddingVec;
            obj.weightMat = [];
        end

        function train(obj, numEpochs, learningRate)
            %TRAIN Train the classifier.
            %   train(obj, numEpochs, learningRate)
            %   obj (BaselineModel): Instance.
            %   numEpochs (double): Number of training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates weightMat.
        end

        function probabilityVec = predict(obj, embeddingObj)
            %PREDICT Predict label probabilities for a single embedding.
            %   probabilityVec = predict(obj, embeddingObj)
            %   obj (BaselineModel): Instance.
            %   embeddingObj (Embedding): Input embedding.
            %   probabilityVec (double Vec): Predicted probabilities.
            %
            %   Side effects: none.
            probabilityVec = [];
        end

        function chunkVec = retrieve(obj, queryEmbeddingObj, topK)
            %RETRIEVE Retrieve top chunks for query embedding.
            %   chunkVec = retrieve(obj, queryEmbeddingObj, topK)
            %   obj (BaselineModel): Instance.
            %   queryEmbeddingObj (Embedding): Query embedding.
            %   topK (double): Number of results.
            %   chunkVec (Chunk Vec): Retrieved chunks.
            %
            %   Side effects: none.
            chunkVec = [];
        end

        function save(obj, path)
            %SAVE Serialize model to disk.
            %   save(obj, path)
            %   obj (BaselineModel): Instance.
            %   path (string): File path.
            %
            %   Side effects: writes model to disk.
        end
    end
end



% +model/ProjectionHead.m
classdef ProjectionHead
    %PROJECTIONHEAD MLP or shallow network for embedding transformation.

    properties (Access=public)
        inputDim    % double: Input dimension
        outputDim   % double: Output dimension
        paramStruct % struct: Learnable parameters
    end

    methods (Access=public)
        function obj = ProjectionHead(inputDim, outputDim)
            %PROJECTIONHEAD Construct projection head.
            %   obj = ProjectionHead(inputDim, outputDim)
            %   inputDim (double): Input dimension.
            %   outputDim (double): Output dimension.
            %   obj (ProjectionHead): New instance.
            %
            %   Side effects: initializes paramStruct.
            obj.inputDim = inputDim;
            obj.outputDim = outputDim;
            obj.paramStruct = struct();
        end

        function fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %FIT Train projection head.
            %   fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %   obj (ProjectionHead): Instance.
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
            %   obj (ProjectionHead): Instance.
            %   embeddingMat (double Mat): Input embeddings.
            %   embeddingMatTrans (double Mat): Transformed embeddings.
            %
            %   Side effects: none.
            embeddingMatTrans = [];
        end
    end
end

% +model/Encoder.m
classdef Encoder
    %ENCODER Fine-tuned model for contrastive learning.

    properties (Access=public)
        baseModel   % struct: Base model data
        stateStruct % struct: Fine-tuned weights
    end

    methods (Access=public)
        function obj = Encoder(baseModel)
            %ENCODER Construct Encoder.
            %   obj = Encoder(baseModel)
            %   baseModel (struct): Base model data.
            %   obj (Encoder): New instance.
            %
            %   Side effects: none.
            obj.baseModel = baseModel;
            obj.stateStruct = [];
        end

        function fineTune(obj, dataset, numEpochs, learningRate)
            %FINETUNE Contrastive fine-tuning procedure.
            %   fineTune(obj, dataset, numEpochs, learningRate)
            %   obj (Encoder): Instance.
            %   dataset (Tbl): Training dataset.
            %   numEpochs (double): Training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates stateStruct.
        end

        function emb = encode(obj, text)
            %ENCODE Convert text to embedding.
            %   emb = encode(obj, text)
            %   obj (Encoder): Instance.
            %   text (string): Input text.
            %   emb (double Vec): Embedding.
            %
            %   Side effects: none.
            emb = [];
        end
    end
end


% +model/Metrics.m
classdef Metrics
    %METRICS Encapsulates evaluation results.

    properties (Access=public)
        metricName  % string: Name of metric set
        scoreStruct % struct: Metric scores
    end

    methods (Access=public)
        function obj = Metrics(metricName, scoreStruct)
            %METRICS Construct Metrics instance.
            %   obj = Metrics(metricName, scoreStruct)
            %   metricName (string): Name of metric set.
            %   scoreStruct (struct): Scores.
            %   obj (Metrics): New instance.
            %
            %   Side effects: none.
            obj.metricName = metricName;
            obj.scoreStruct = scoreStruct;
        end

        function s = summary(obj)
            %SUMMARY Return human-readable summary of metrics.
            %   s = summary(obj)
            %   obj (Metrics): Instance.
            %   s (string): Summary text.
            %
            %   Side effects: none.
            s = "";
        end
    end
end


% +model/CorpusVersion.m
classdef CorpusVersion
    %CORPUSVERSION Versioned corpus handling for diff operations.

    properties (Access=public)
        versionId   % string: Corpus version identifier
        documentVec % Document Vec: Documents in version
    end

    methods (Access=public)
        function obj = CorpusVersion(versionId, documentVec)
            %CORPUSVERSION Construct CorpusVersion.
            %   obj = CorpusVersion(versionId, documentVec)
            %   versionId (string): Identifier for corpus version.
            %   documentVec (Document Vec): Documents.
            %   obj (CorpusVersion): New instance.
            %
            %   Side effects: none.
            obj.versionId = versionId;
            obj.documentVec = documentVec;
        end

        function diffResult = diff(obj, other)
            %DIFF Return differences between versions.
            %   diffResult = diff(obj, other)
            %   obj (CorpusVersion): First version.
            %   other (CorpusVersion): Second version.
            %   diffResult (struct): Differences.
            %
            %   Side effects: none.
            diffResult = struct();
        end
    end
end


**View Layer (+view)**

% +view/EvalReportView.m
classdef EvalReportView
    %EVALREPORTVIEW Renders evaluation metrics into report format.
    
    methods (Access=public)
        function render(obj, metrics, reportPath)
            %RENDER Dispatch to PDF or HTML renderer.
            %   render(obj, metrics, reportPath)
            %   metrics (Metrics): Metrics to report.
            %   reportPath (string): Output file path.
            %
            %   Side effects: writes file to disk.
            if endsWith(lower(reportPath), ".pdf")
                obj.renderPDF(metrics, reportPath);
            else
                obj.renderHTML(metrics, reportPath);
            end
        end

        function renderPDF(~, metrics, pdfPath)
            %RENDERPDF Generate PDF report.
            %   renderPDF(obj, metrics, pdfPath)
            %   metrics (Metrics): Metrics to report.
            %   pdfPath (string): Output PDF path.
            %
            %   Side effects: writes file to disk.
        end

        function renderHTML(~, metrics, htmlPath)
            %RENDERHTML Generate HTML report.
            %   renderHTML(obj, metrics, htmlPath)
            %   metrics (Metrics): Metrics to report.
            %   htmlPath (string): Output HTML path.
            %
            %   Side effects: writes file to disk.
        end
    end
end

% +view/DiffReportView.m
classdef DiffReportView
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


% +view/MetricsPlotsView.m
classdef MetricsPlotsView
    %METRICSPLOTSVIEW Creates visual plots for metrics and trends.
    
    methods (Access=public)
        function plotHeatmap(~, metrics, path)
            %PLOTHEATMAP Render heatmap from metric matrix.
            %   plotHeatmap(obj, metrics, path)
            %   metrics (Metrics): Metrics to visualize.
            %   path (string): Output path.
            %
            %   Side effects: writes file to disk.
        end

        function plotTrend(~, metricHistoryVec, path)
            %PLOTTREND Render line chart for metric trends.
            %   plotTrend(obj, metricHistoryVec, path)
            %   metricHistoryVec (Metrics Vec): Metrics over time.
            %   path (string): Output path.
            %
            %   Side effects: writes file to disk.
        end
    end
end


**Controller Layer (+controller)**

% +controller/IngestionController.m
classdef IngestionController
    %INGESTIONCONTROLLER Parses PDFs and returns Document objects.
    
    methods (Access=public)
        function documentVec = run(~, sourcePaths)
            %RUN Parse PDFs to documents.
            %   documentVec = run(obj, sourcePaths)
            %   sourcePaths (string Cell): Paths to PDFs.
            %   documentVec (Document Vec): Parsed documents.
            %
            %   Side effects: reads files from disk.
            documentVec = [];
        end
    end
end


% +controller/ChunkingController.m
classdef ChunkingController
    %CHUNKINGCONTROLLER Splits documents into overlapping chunks.
    
    methods (Access=public)
        function chunkVec = run(~, documentVec, window, overlap)
            %RUN Split documents into chunks.
            %   chunkVec = run(obj, documentVec, window, overlap)
            %   documentVec (Document Vec): Documents.
            %   window (double): Window size.
            %   overlap (double): Overlap amount.
            %   chunkVec (Chunk Vec): Generated chunks.
            %
            %   Side effects: none.
            chunkVec = [];
        end
    end
end

% +controller/WeakLabelingController.m
classdef WeakLabelingController
    %WEAKLABELINGCONTROLLER Applies heuristic rules to label chunks.
    
    methods (Access=public)
        function labelMatrixObj = run(~, chunkVec, labelingRules)
            %RUN Apply weak labeling rules.
            %   labelMatrixObj = run(obj, chunkVec, labelingRules)
            %   chunkVec (Chunk Vec): Chunks to label.
            %   labelingRules (cell): Rules.
            %   labelMatrixObj (LabelMatrix): Generated labels.
            %
            %   Side effects: none.
            labelMat = [];
            labelMatrixObj = model.LabelMatrix([], [], labelMat);
        end
    end
end


% +controller/EmbeddingController.m
classdef EmbeddingController
    %EMBEDDINGCONTROLLER Generates embeddings for chunks.
    
    methods (Access=public)
        function embeddingVec = run(~, chunkVec, modelName)
            %RUN Generate embeddings.
            %   embeddingVec = run(obj, chunkVec, modelName)
            %   chunkVec (Chunk Vec): Chunks to embed.
            %   modelName (string): Model to use.
            %   embeddingVec (Embedding Vec): Embeddings.
            %
            %   Side effects: may cache embeddings.
            embeddingVec = model.Embedding.empty();
        end
    end
end


% +controller/BaselineController.m
classdef BaselineController
    %BASELINECONTROLLER Constructs baseline model and delegates operations.

    methods (Access=public)
        function model = train(~, labelMatrixObj, embeddingVec, numEpochs, learningRate)
            %TRAIN Fit baseline classifier via model.
            %   model = train(obj, labelMatrixObj, embeddingVec, numEpochs, learningRate)
            %   labelMatrixObj (LabelMatrix): Labels.
            %   embeddingVec (Embedding Vec): Embeddings.
            %   numEpochs (double): Number of training epochs.
            %   learningRate (double): Step size.
            %   model (BaselineModel): Trained model.
            %
            %   Side effects: none.
            baselineModel = model.BaselineModel(labelMatrixObj, embeddingVec);
            baselineModel.train(numEpochs, learningRate);
            model = baselineModel;
        end

        function chunkVec = retrieve(~, model, queryEmbeddingObj, topK)
            %RETRIEVE Retrieve top chunks using model.
            %   chunkVec = retrieve(obj, model, queryEmbeddingObj, topK)
            %   model (BaselineModel): Model to query.
            %   queryEmbeddingObj (Embedding): Query embedding.
            %   topK (double): Number of results.
            %   chunkVec (Chunk Vec): Retrieved chunks.
            %
            %   Side effects: none.
            chunkVec = model.retrieve(queryEmbeddingObj, topK);
        end
    end
end

% +controller/ProjectionHeadController.m
classdef ProjectionHeadController
    %PROJECTIONHEADCONTROLLER Instantiates projection head model and delegates work.

    properties (Access=private)
        head % ProjectionHead instance
    end

    methods (Access=public)
        function obj = ProjectionHeadController(inputDim, outputDim)
            %PROJECTIONHEADCONTROLLER Construct controller and underlying model.
            %   obj = ProjectionHeadController(inputDim, outputDim)
            %   inputDim (double): Input dimension.
            %   outputDim (double): Output dimension.
            %   obj (ProjectionHeadController): New instance.
            obj.head = model.ProjectionHead(inputDim, outputDim);
        end

        function train(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %TRAIN Delegate training to ProjectionHead.
            obj.head.fit(embeddingMat, labelMat, numEpochs, learningRate);
        end

        function embeddingMatTrans = project(obj, embeddingMat)
            %PROJECT Delegate projection to ProjectionHead.
            embeddingMatTrans = obj.head.transform(embeddingMat);
        end
    end
end

% +controller/FineTuneController.m
classdef FineTuneController
    %FINETUNECONTROLLER Fine-tunes base models.
    
    methods (Access=public)
        function encoder = run(~, datasetTbl, baseModel)
            %RUN Fine-tune encoder.
            %   encoder = run(obj, datasetTbl, baseModel)
            %   datasetTbl (Tbl): Training data.
            %   baseModel (Encoder): Base model.
            %   encoder (Encoder): Fine-tuned encoder.
            %
            %   Side effects: none.
            encoder = [];
        end
    end
end


% +controller/EvaluationController.m
classdef EvaluationController
    %EVALUATIONCONTROLLER Computes metrics and generates reports.
    
    methods (Access=public)
        function metrics = evaluate(~, model, testEmbeddingMat, trueLabelMat)
            %EVALUATE Compute metrics for model.
            %   metrics = evaluate(obj, model, testEmbeddingMat, trueLabelMat)
            %   model (BaselineModel): Model to evaluate.
            %   testEmbeddingMat (double Mat): Test embeddings.
            %   trueLabelMat (double Mat): True labels.
            %   metrics (Metrics): Results.
            %
            %   Side effects: none.
            metrics = [];
        end

        function generateReports(~, metrics, outDir, viewHandle)
            %GENERATEREPORTS Use supplied view's unified render interface.
            %   generateReports(obj, metrics, outDir, viewHandle)
            %   metrics (Metrics): Evaluation results.
            %   outDir (string): Directory for output file.
            %   viewHandle (EvalReportView|function_handle): View dependency.
            %       Must implement: render(metrics, reportPath)
            %
            %   Side effects: writes report to disk.
            if isa(viewHandle, 'function_handle')
                viewObj = viewHandle();
            else
                viewObj = viewHandle;
            end
            reportPath = fullfile(outDir, "metricsReport.pdf");
            viewObj.render(metrics, reportPath);
        end
    end
end


**Helper Functions (+helpers)**

% +helpers/loadCorpus.m
function documentVec = loadCorpus(versionId)
    %LOADCORPUS Load corpus documents from a MAT file.
    %   documentVec = loadCorpus(versionId)
    %   versionId (string): Corpus version identifier.
    %   documentVec (model.Document Vec): Loaded documents.
    %
    %   Side effects: reads `<versionId>.mat` from disk containing variable
    %   `documentVec`.
    dataStruct = load(versionId + ".mat", "documentVec");
    if isfield(dataStruct, "documentVec")
        documentVec = dataStruct.documentVec;
    else
        documentVec = model.Document.empty();
    end
end

% +helpers/docSetdiff.m
function diffDocsVec = docSetdiff(corpusAVec, corpusBVec)
    %DOCSETDIFF Documents in corpusAVec but not corpusBVec by `docId`.
    %   diffDocsVec = docSetdiff(corpusAVec, corpusBVec)
    %   corpusAVec (model.Document Vec): Candidate corpus.
    %   corpusBVec (model.Document Vec): Corpus to subtract.
    %   diffDocsVec (model.Document Vec): Unique documents.
    %
    %   Side effects: none.
    [~, idxVec] = builtin('setdiff', {corpusAVec.docId}, {corpusBVec.docId});
    diffDocsVec = corpusAVec(idxVec);
end

% +helpers/detectChanges.m
function changedDocsVec = detectChanges(oldCorpusVec, newCorpusVec)
    %DETECTCHANGES Documents with same `docId` but different `text`.
    %   changedDocsVec = detectChanges(oldCorpusVec, newCorpusVec)
    %   oldCorpusVec (model.Document Vec): Baseline corpus.
    %   newCorpusVec (model.Document Vec): Updated corpus.
    %   changedDocsVec (model.Document Vec): Modified documents.
    %
    %   Side effects: none.
    changedDocsVec = model.Document.empty();
    for i = 1:numel(newCorpusVec)
        newDoc = newCorpusVec(i);
        idx = find(strcmp(newDoc.docId, {oldCorpusVec.docId}), 1);
        if ~isempty(idx) && ~strcmp(newDoc.text, oldCorpusVec(idx).text)
            changedDocsVec(end+1) = newDoc; %#ok<AGROW>
        end
    end
end


% +controller/DataAcquisitionController.m
classdef DataAcquisitionController
%DATAACQUISITIONCONTROLLER Fetches corpora and returns raw or diff data.
%   Report generation is handled by the caller or a dedicated controller
%   using DiffReportView.
    
    methods (Access=public)
        function corpusVersion = fetch(~, sources)
            %FETCH Retrieve corpora from sources.
            %   corpusVersion = fetch(obj, sources)
            %   sources (string Cell): Data sources.
            %   corpusVersion (model.CorpusVersion): Retrieved corpus with fields:
            %       versionId (string): Corpus version identifier.
            %       documentVec (Document Vec): Documents in the corpus.
            %
            %   Side effects: accesses external resources.
            documentVec = model.Document.empty;
            corpusVersion = model.CorpusVersion("versionId", documentVec);
        end

        function diffStruct = diffVersions(~, oldVersionId, newVersionId)
            %DIFFVERSIONS Compute differences between corpus versions.
            %   diffStruct = diffVersions(obj, oldVersionId, newVersionId)
            %   oldVersionId (string): Baseline version.
            %   newVersionId (string): New version.
            %   diffStruct (struct): Differences between versions with fields:
            %       addedDocs (Document Vec): Only in newVersionId.
            %       removedDocs (Document Vec): Only in oldVersionId.
            %       changedDocs (Document Vec): Present in both but modified.
            %   Callers can pass diffStruct to DiffReportView.render.
            %
            %   Side effects: accesses external resources.
            oldCorpus = helpers.loadCorpus(oldVersionId);
            newCorpus = helpers.loadCorpus(newVersionId);
            diffStruct.addedDocs = helpers.docSetdiff(newCorpus, oldCorpus);
            diffStruct.removedDocs = helpers.docSetdiff(oldCorpus, newCorpus);
            diffStruct.changedDocs = helpers.detectChanges(oldCorpus, newCorpus);
        end
    end
end

% Example diff workflow
%   Demonstrates computing corpus diffs and rendering a report.
%   documentVec = [model.Document("d1","A"), model.Document("d2","B")];
%   save("v1.mat", "documentVec");
%   documentVec = [model.Document("d2","B2"), model.Document("d3","C")];
%   save("v2.mat", "documentVec");
%   diffStruct = controller.DataAcquisitionController().diffVersions("v1", "v2");
%   view.DiffReportView().render(diffStruct, "out/diff", "html");
%
%   % tests/testDiffWorkflow.m
%   classdef testDiffWorkflow < matlab.unittest.TestCase
%       methods (Test, TestTags={"Integration"})
%           function verifiesEndToEndDiff(testCase)
%               import model.Document
%               documentVec = [Document("d1","A"), Document("d2","B")];
%               save("v1.mat", "documentVec");
%               documentVec = [Document("d2","B2"), Document("d3","C")];
%               save("v2.mat", "documentVec");
%               diffStruct = controller.DataAcquisitionController().diffVersions("v1", "v2");
%               testCase.verifyEqual({diffStruct.addedDocs.docId}, {"d3"});
%               testCase.verifyEqual({diffStruct.removedDocs.docId}, {"d1"});
%               testCase.verifyEqual({diffStruct.changedDocs.docId}, {"d2"});
%           end
%       end
%   end

% +controller/PipelineController.m
classdef PipelineController
    %PIPELINECONTROLLER High-level orchestration based on dependency graph.
    
    properties (Access=public)
        controllerStruct % Struct or containers.Map holding controller instances
    end

    methods (Access=public)
        function obj = PipelineController(controllerStruct)
            %PIPELINECONTROLLER Construct pipeline controller.
            %   obj = PipelineController(controllerStruct)
            %   controllerStruct (struct): Controller instances.
            %   obj (PipelineController): New instance.
            %
            %   Side effects: none.
            obj.controllerStruct = controllerStruct;
        end

        function execute(obj, configStruct)
            %EXECUTE Execute pipeline steps using controllerStruct.
            %   execute(obj, configStruct)
            %   obj (PipelineController): Instance.
            %   configStruct (struct): Configuration for steps.
            %
            %   Side effects: orchestrates pipeline execution.
        end
    end
end


% +controller/TestController.m
classdef TestController
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


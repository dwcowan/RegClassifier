classdef ConfigModel < reg.mvc.BaseModel
    %CONFIGMODEL Centralised configuration shared across models.

    properties
        % Directory containing source PDF documents
        inputDir string = "data/pdfs";

        % Flag indicating whether GPU acceleration is allowed
        gpuEnabled logical = true;

        % === Chunking ===
        % Number of tokens per text chunk
        chunkSizeTokens double = 300;
        % Overlap in tokens between consecutive chunks
        chunkOverlap double = 80;

        % === BERT embedding ===
        % Mini-batch size for BERT embeddings
        bertMiniBatchSize double = 96;
        % Maximum sequence length for BERT model inputs
        bertMaxSeqLength double = 256;

        % === Projection head ===
        % Dimensionality of projected embeddings
        projDim double = 384;
        % Number of epochs to train the projection head
        projEpochs double = 5;
        % Training mini-batch size for projection head
        projBatchSize double = 768;
        % Learning rate for projection head optimiser
        projLR double = 1e-3;
        % Margin used in triplet loss during projection training
        projMargin double = 0.2;

        % === Encoder fine-tuning ===
        % Loss function for encoder fine-tuning
        fineTuneLoss string = "triplet";
        % Mini-batch size during encoder fine-tuning
        fineTuneBatchSize double = 32;
        % Maximum sequence length for fine-tuning inputs
        fineTuneMaxSeqLength double = 256;
        % Number of top encoder layers to unfreeze
        fineTuneUnfreezeTopLayers double = 4;
        % Epochs for encoder fine-tuning
        fineTuneEpochs double = 4;
        % Learning rate applied to encoder weights
        fineTuneEncoderLR double = 1e-5;
        % Learning rate applied to added head parameters
        fineTuneHeadLR double = 1e-3;

        % === Miscellaneous ===
        % Minimum confidence to accept weak rule labels
        minRuleConf double = 0.7;
        % Number of folds for cross-validation
        kfold double = 5;
        % Number of latent Dirichlet allocation topics
        ldaTopics double = 12;
        % Title used in generated reports
        reportTitle string = "Banking Regulation Topic Classifier — Snapshot";
        % Database connection settings
        db struct = struct('enable', false, 'vendor','postgres', ...
            'dbname','reg_topics', 'user','user', 'pass','pass', ...
            'server','localhost', 'port',5432, ...
            'sqlitePath','./data/db/my_reg_topics.sqlite');
    end

    methods
        function obj = ConfigModel(args)
            %CONFIGMODEL Construct configuration model with overrides.
            %   OBJ = CONFIGMODEL(args) accepts a struct of fields to
            %   override defaults defined as properties above.
            if nargin > 0
                f = fieldnames(args);
                for i = 1:numel(f)
                    if isprop(obj, f{i})
                        obj.(f{i}) = args.(f{i});
                    end
                end
            end
        end

        function validatePaths(obj)
            %VALIDATEPATHS Ensure required file system paths exist.
            %   VALIDATEPATHS(obj) throws when mandatory paths are missing.
            if ~isfolder(obj.inputDir)
                error("reg:model:InvalidPath", ...
                    "Input directory not found: %s", obj.inputDir);
            end
        end

        function validateGPUAvailability(obj)
            %VALIDATEGPUAVAILABILITY Confirm GPU can be used when requested.
            %   VALIDATEGPUAVAILABILITY(obj) errors if gpuEnabled is true
            %   but no GPU device is present.
            if obj.gpuEnabled && exist('gpuDeviceCount','file') == 2
                if gpuDeviceCount == 0
                    error("reg:model:NoGPU", ...
                        "Configuration requests GPU but none available.");
                end
            elseif obj.gpuEnabled
                error("reg:model:NoGPU", ...
                    "GPU support is not available in this environment.");
            end
        end

        function cfgStruct = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve configuration from source.
            %   cfgStruct = LOAD(obj) reads knob settings.
            %   This stub retains legacy semantics of `load_knobs` and
            %   should be overridden by concrete implementations.
            error("reg:model:NotImplemented", ...
                "ConfigModel.load is not implemented.");
        end

        function validatedCfg = process(~, cfgStruct) %#ok<INUSD>
            %PROCESS Validate configuration values.
            %   validatedCfg = PROCESS(obj, cfgStruct) performs sanity checks.
            %   Override in subclasses to apply custom validation logic.
            error("reg:model:NotImplemented", ...
                "ConfigModel.process is not implemented.");
        end
    end
end


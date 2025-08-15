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

        % Loaded knob configuration
        knobs struct = struct();

        % Seeds applied for reproducibility
        seeds struct = struct();
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

        function K = loadKnobs(obj, varargin)
            %LOADKNOBS Load knob values from JSON and apply overrides.
            %   K = LOADKNOBS(obj, jsonPath) reads knob settings from
            %   `jsonPath` (default 'knobs.json') and stores them on the
            %   model. Known fields override corresponding properties.
            if ~isempty(varargin)
                jsonPath = varargin{1};
            else
                jsonPath = "knobs.json";
            end
            try
                K = reg.load_knobs(jsonPath);
            catch ME
                warning("reg:model:KnobsLoadFailed", ...
                    "Knobs load failed: %s", ME.message);
                K = struct();
            end
            obj.knobs = K;

            % Apply knob overrides to properties when present
            if isfield(K, 'BERT')
                if isfield(K.BERT, 'MiniBatchSize')
                    obj.bertMiniBatchSize = K.BERT.MiniBatchSize;
                end
                if isfield(K.BERT, 'MaxSeqLength')
                    obj.bertMaxSeqLength = K.BERT.MaxSeqLength;
                end
            end
            if isfield(K, 'Projection')
                if isfield(K.Projection, 'ProjDim')
                    obj.projDim = K.Projection.ProjDim;
                end
                if isfield(K.Projection, 'BatchSize')
                    obj.projBatchSize = K.Projection.BatchSize;
                end
                if isfield(K.Projection, 'Epochs')
                    obj.projEpochs = K.Projection.Epochs;
                end
                if isfield(K.Projection, 'LR')
                    obj.projLR = K.Projection.LR;
                end
                if isfield(K.Projection, 'Margin')
                    obj.projMargin = K.Projection.Margin;
                end
            end
            if isfield(K, 'FineTune')
                if isfield(K.FineTune, 'Loss')
                    obj.fineTuneLoss = string(K.FineTune.Loss);
                end
                if isfield(K.FineTune, 'BatchSize')
                    obj.fineTuneBatchSize = K.FineTune.BatchSize;
                end
                if isfield(K.FineTune, 'Epochs')
                    obj.fineTuneEpochs = K.FineTune.Epochs;
                end
                if isfield(K.FineTune, 'MaxSeqLength')
                    obj.fineTuneMaxSeqLength = K.FineTune.MaxSeqLength;
                end
                if isfield(K.FineTune, 'UnfreezeTopLayers')
                    obj.fineTuneUnfreezeTopLayers = K.FineTune.UnfreezeTopLayers;
                end
                if isfield(K.FineTune, 'EncoderLR')
                    obj.fineTuneEncoderLR = K.FineTune.EncoderLR;
                end
                if isfield(K.FineTune, 'HeadLR')
                    obj.fineTuneHeadLR = K.FineTune.HeadLR;
                end
            end
            if isfield(K, 'Chunk')
                if isfield(K.Chunk, 'SizeTokens')
                    obj.chunkSizeTokens = K.Chunk.SizeTokens;
                end
                if isfield(K.Chunk, 'Overlap')
                    obj.chunkOverlap = K.Chunk.Overlap;
                end
            end
        end

        function validateKnobs(obj)
            %VALIDATEKNOBS Perform basic sanity checks on loaded knobs.
            if ~isempty(obj.knobs)
                reg.validate_knobs(obj.knobs);
            end
        end

        function printActiveKnobs(obj)
            %PRINTACTIVEKNOBS Pretty-print active knob configuration.
            reg.print_active_knobs(struct('knobs', obj.knobs));
        end

        function S = applySeeds(obj, varargin)
            %APPLYSEEDS Set RNG seeds for reproducibility.
            if ~isempty(varargin)
                seed = varargin{1};
            else
                seed = [];
            end
            S = reg.set_seeds(seed);
            obj.seeds = S;
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


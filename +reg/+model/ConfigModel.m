classdef ConfigModel < reg.mvc.BaseModel
    %CONFIGMODEL Centralised configuration shared across models.

    properties
        % Directory containing source PDF documents
        inputDir string = "";

        % Flag indicating whether GPU acceleration is allowed
        gpuEnabled logical = false;

        % === Chunking ===
        % Number of tokens per text chunk
        chunkSizeTokens double = 0;
        % Overlap in tokens between consecutive chunks
        chunkOverlap double = 0;

        % === BERT embedding ===
        % Mini-batch size for BERT embeddings
        bertMiniBatchSize double = 0;
        % Maximum sequence length for BERT model inputs
        bertMaxSeqLength double = 0;

        % === Projection head ===
        % Dimensionality of projected embeddings
        projDim double = 0;
        % Number of epochs to train the projection head
        projEpochs double = 0;
        % Training mini-batch size for projection head
        projBatchSize double = 0;
        % Learning rate for projection head optimiser
        projLR double = 0;
        % Margin used in triplet loss during projection training
        projMargin double = 0;

        % === Encoder fine-tuning ===
        % Loss function for encoder fine-tuning
        fineTuneLoss string = "";
        % Mini-batch size during encoder fine-tuning
        fineTuneBatchSize double = 0;
        % Maximum sequence length for fine-tuning inputs
        fineTuneMaxSeqLength double = 0;
        % Number of top encoder layers to unfreeze
        fineTuneUnfreezeTopLayers double = 0;
        % Epochs for encoder fine-tuning
        fineTuneEpochs double = 0;
        % Learning rate applied to encoder weights
        fineTuneEncoderLR double = 0;
        % Learning rate applied to added head parameters
        fineTuneHeadLR double = 0;

        % === Miscellaneous ===
        % Minimum confidence to accept weak rule labels
        minRuleConf double = 0;
        % Number of folds for cross-validation
        kfold double = 0;
        % Number of latent Dirichlet allocation topics
        ldaTopics double = 0;
        % Title used in generated reports
        reportTitle string = "";
        % Database connection settings
        db struct = struct('enable', false, 'vendor','', ...
            'dbname','', 'user','', 'pass','', ...
            'server','', 'port',0, ...
            'sqlitePath','');

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

        function K = loadKnobs(obj, varargin) %#ok<INUSD>
            %LOADKNOBS Load knob values from JSON and apply overrides.
            %   K = LOADKNOBS(obj, jsonPath) reads knob settings and stores
            %   them on the model.
            %   Legacy Reference
            %       Equivalent to `reg.load_knobs`.
            %   Pseudocode:
            %       1. Read knob JSON file
            %       2. Apply overrides to configuration properties
            %       3. Return struct of knob values
            error("reg:model:NotImplemented", ...
                "ConfigModel.loadKnobs is not implemented.");
        end

        function validateKnobs(obj) %#ok<MANU>
            %VALIDATEKNOBS Perform basic sanity checks on loaded knobs.
            %   Intended to error when knob values fall outside supported
            %   ranges.
            %   Legacy Reference
            %       Equivalent to `reg.validate_knobs`.
            error("reg:model:NotImplemented", ...
                "ConfigModel.validateKnobs is not implemented.");
        end

        function printActiveKnobs(obj) %#ok<MANU>
            %PRINTACTIVEKNOBS Pretty-print active knob configuration.
            %   Legacy Reference
            %       Equivalent to `reg.print_active_knobs`.
            %   Pseudocode:
            %       1. Format knob values into readable table
            %       2. Display via fprintf or logging facility
            error("reg:model:NotImplemented", ...
                "ConfigModel.printActiveKnobs is not implemented.");
        end

        function S = applySeeds(obj, varargin) %#ok<INUSD,MANU>
            %APPLYSEEDS Set RNG seeds for reproducibility.
            %   S = APPLYSEEDS(obj, seed) returns the applied seed struct.
            %   Legacy Reference
            %       Equivalent to `reg.set_seeds`.
            %   Pseudocode:
            %       1. Initialise random number generators
            %       2. Store seeds on obj.seeds
            %       3. Return seed struct
            error("reg:model:NotImplemented", ...
                "ConfigModel.applySeeds is not implemented.");
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


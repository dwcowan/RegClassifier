classdef FeatureModel < reg.mvc.BaseModel
    %FEATUREMODEL Stub model generating feature representations.
    %   Dense embedding generation has been split into
    %   `reg.model.EmbeddingModel` and is no longer handled here.
    %
    % Input chunksTable schema (see TextChunkModel):
    %   chunk_id  (string) : chunk identifier
    %   doc_id    (string) : parent document identifier
    %   text      (string) : chunk text content
    %   start_idx (double) : starting token index
    %   end_idx   (double) : ending token index
    %
    % Outputs returned by PROCESS:
    %   features (table) : columns
    %       - chunk_id (string) : reference to source chunk
    %       - doc_id   (string) : parent document identifier
    %       - tfidf    (double vector 1xV) : TF-IDF features
    %   vocab    (string array 1×V)  : vocabulary terms corresponding to tfidf

    properties
        % Shared configuration reference
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = FeatureModel(cfg)
            %FEATUREMODEL Construct feature extraction model.
            %   OBJ = FEATUREMODEL(cfg) uses parameters such as
            %   cfg.bertMiniBatchSize when computing embeddings.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function chunksTable = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve text chunks for feature extraction.
            %   chunksTable = LOAD(obj) returns a table of text segments.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       chunksTable (table): Text segments awaiting embedding.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `precompute_embeddings` input gathering.
            %   Extension Point
            %       Override to supply chunks from alternative sources.
            % Pseudocode:
            %   1. Read chunk records from storage
            %   2. Return as chunksTable
            error("reg:model:NotImplemented", ...
                "FeatureModel.load is not implemented.");
        end
        function [features, vocab] = process(~, chunksTable) %#ok<INUSD>
            %PROCESS Generate sparse feature representations.
            %   [features, vocab] = PROCESS(obj, chunksTable) produces
            %   TF-IDF or other sparse features.  Any dense embedding
            %   computation should be handled by `reg.model.EmbeddingModel`.
            %   Parameters
            %       chunksTable (table): Text segments to featurize.
            %   Returns
            %       features (table): Derived feature table.
            %       vocab    (string array): Vocabulary mapping.
            %   Side Effects
            %       May update feature caches on disk.
            %   Legacy Reference
            %       Equivalent to the feature extraction portion of
            %       `precompute_embeddings`.
            %   Extension Point
            %       Customize feature extraction steps or vocab pruning.
            % Pseudocode:
            %   1. Tokenize text in chunksTable
            %   2. Compute sparse features and vocabulary
            error("reg:model:NotImplemented", ...
                "FeatureModel.process is not implemented.");
        end
    end
end

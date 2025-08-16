classdef RuntimeLabelModel < reg.mvc.BaseModel
    %RUNTIMELABELMODEL Ingest runtime-labelled chunk data.
    %   Provides helpers for loading and processing data sets created
    %   on-the-fly during annotation or other live workflows. The model
    %   focuses purely on formatting and validation of incoming labels
    %   without assuming any prior evaluation corpus.

    methods
        function cfg = load(~, source)
            %LOAD Prepare runtime label source for ingestion.
            %   cfg = LOAD(obj, source) records the input location or
            %   struct used to supply runtime-labelled data.
            %   Parameters
            %       source (string or struct): description of the label
            %           source such as a file path, URL or in-memory struct.
            %   Returns
            %       cfg (struct): struct with fields
            %           source - normalised reference to label data
            %   Pseudocode:
            %       1. Resolve `source` into a standard form
            %       2. Perform lightweight existence checks
            %       3. Return configuration for `process`
            arguments
                ~
                source {mustBeTextScalarOrStruct}
            end
            cfg = struct('source', source);
        end

        function labelTbl = process(~, cfg) %#ok<INUSD>
            %PROCESS Load and validate runtime labels.
            %   labelTbl = PROCESS(obj, cfg) reads labels from cfg.source
            %   and returns a normalised table.
            %   Input Schema:
            %       A table or struct array with variables/fields:
            %           chunkId (string) - unique chunk identifier
            %           label   (string) - assigned label name
            %           annotator (string) - identifier of labeler
            %           timestamp (datetime) - when label was recorded
            %   Output
            %       labelTbl (table): table with the above variables.
            %   Validation Stubs:
            %       assert(ismember('chunkId', vars))
            %       assert(ismember('label', vars))
            %       % TODO: additional type and value checks
            %   Pseudocode:
            %       1. Read data from cfg.source (file/struct/etc.)
            %       2. Convert to table if needed
            %       3. Validate required columns and types
            %       4. Return label table
            arguments
                ~
                cfg (1,1) struct
                cfg.source
            end
            % Placeholder; actual implementation pending
            error("reg:model:NotImplemented", ...
                "RuntimeLabelModel.process is not implemented.");
        end
    end
end

function mustBeTextScalarOrStruct(value)
%MUSTBETEXTSCALARORSTRUCT Validate text or struct input.
%   Accepts string/char vectors or structs; throws error otherwise.
    if ~(ischar(value) || isstring(value) || isstruct(value))
        error("reg:model:InvalidSource", ...
            "Source must be text or struct.");
    end
end

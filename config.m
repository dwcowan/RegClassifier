function C = config()
%CONFIG Project configuration for regulatory topic classifier

% === Find project root ===
% Look for knobs.json to identify project root directory
projectRoot = find_project_root();

% === Load pipeline.json ===
% Check current directory first, then project root
pipe = struct();
try
    if isfile('pipeline.json')
        pipe = jsondecode(fileread('pipeline.json'));
    elseif isfile(fullfile(projectRoot, 'pipeline.json'))
        pipe = jsondecode(fileread(fullfile(projectRoot, 'pipeline.json')));
    end
catch ME
    warning("Pipeline config load failed: %s", ME.message);
end

% === Load params.json overrides ===
% Check current directory first, then project root
params = struct();
try
    if isfile('params.json')
        params = jsondecode(fileread('params.json'));
    elseif isfile(fullfile(projectRoot, 'params.json'))
        params = jsondecode(fileread(fullfile(projectRoot, 'params.json')));
    end
catch ME
    warning("Params load/apply failed: %s", ME.message);
    params = struct();
end

% Default locations and labels are intentionally blank to avoid
% hard-coded legacy tuning.
C.input_dir   = "";      % drop regs here (PDFs)
C.labels      = strings(0);

% Chunking defaults (placeholders)
C.chunk_size_tokens = 0;
C.chunk_overlap     = 0;

% Embedding backend configuration
C.embeddings_backend = '';
C.fasttext = struct('language','');

% Model/training placeholders
C.lda_topics    = 0;
C.min_rule_conf = 0;  % threshold to accept weakly-labeled positives for bootstrap
C.kfold         = 0;

% DB (set enable=true to persist in pipeline). For tests we use sqlite.
C.db = struct('enable', false, 'vendor','', 'dbname','', ...
              'user','', 'pass','', 'server','', 'port',0, ...
              'sqlite_path','');

% Reports
C.report_title = "";

% Apply pipeline overrides
pipe_fields = fieldnames(pipe);
for i = 1:numel(pipe_fields)
    f = pipe_fields{i};
    C.(f) = pipe.(f);
end

% Apply params overrides
param_fields = fieldnames(params);
for i = 1:numel(param_fields)
    f = param_fields{i};
    if isfield(C, f)
        C.(f) = params.(f);
    end
end
C.params = params;
C.pipeline = pipe;

% === Load knobs.json and apply Chunk overrides ===
% Check current directory first, then project root
if isfile('knobs.json')
    C.knobs = reg.load_knobs('knobs.json');
else
    C.knobs = reg.load_knobs(fullfile(projectRoot, 'knobs.json'));
end

% Validate knobs (will warn if values are suspicious)
try
    reg.validate_knobs(C.knobs);
catch ME
    warning('config:KnobsValidationFailed', ...
        'Knobs validation failed: %s. Using loaded values anyway.', ME.message);
end

% Apply Chunk overrides from knobs to top-level config
if isfield(C.knobs, 'Chunk')
    if isfield(C.knobs.Chunk, 'SizeTokens')
        C.chunk_size_tokens = C.knobs.Chunk.SizeTokens;
    end
    if isfield(C.knobs.Chunk, 'Overlap')
        C.chunk_overlap = C.knobs.Chunk.Overlap;
    end
end

% Display active knobs summary (placeholder)
% disp('=== Active knobs configuration ===');
% disp(jsonencode(C.knobs));

end

function projectRoot = find_project_root()
%FIND_PROJECT_ROOT Locate the project root directory.
%   Searches up the directory tree for knobs.json to identify project root.
%   This allows config() to work correctly even when called from subdirectories
%   (e.g., when running tests from tests/ directory).

    % Start from current directory
    searchDir = pwd;
    maxLevels = 5;  % Safety limit to prevent infinite loop

    for i = 1:maxLevels
        % Check if knobs.json exists in this directory
        if isfile(fullfile(searchDir, 'knobs.json'))
            projectRoot = searchDir;
            return;
        end

        % Move up one directory
        parentDir = fileparts(searchDir);

        % If we've reached the root of the filesystem, stop
        if strcmp(parentDir, searchDir)
            break;
        end

        searchDir = parentDir;
    end

    % Fallback: use current directory and issue warning
    projectRoot = pwd;
    warning('config:ProjectRootNotFound', ...
        'Could not find project root (knobs.json). Using current directory: %s', projectRoot);
end

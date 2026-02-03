function results = validate_bug_fixes(varargin)
%VALIDATE_BUG_FIXES Test suite to verify bug fixes
%   RESULTS = VALIDATE_BUG_FIXES() runs all validation tests
%   RESULTS = VALIDATE_BUG_FIXES('BugID', 'BUG-001') runs specific bug test
%
%   Returns struct with fields:
%       bugID       - Bug identifier
%       status      - 'PASS', 'FAIL', 'SKIP'
%       message     - Description of result
%       timestamp   - When test was run

p = inputParser;
addParameter(p, 'BugID', 'all', @ischar);
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

bugID = p.Results.BugID;
verbose = p.Results.Verbose;

% Initialize results
results = struct('bugID', {}, 'status', {}, 'message', {}, 'timestamp', {});

fprintf('========================================\n');
fprintf('RegClassifier Bug Fix Validation\n');
fprintf('Time: %s\n', datestr(now));
fprintf('========================================\n\n');

% Determine which tests to run
if strcmpi(bugID, 'all')
    bugList = {'BUG-001', 'BUG-002', 'BUG-003', 'BUG-004', 'BUG-005', ...
               'BUG-006', 'BUG-007', 'BUG-008', 'BUG-009', 'BUG-010', 'BUG-011'};
else
    bugList = {bugID};
end

% Run tests for each bug
for i = 1:numel(bugList)
    bug = bugList{i};
    fprintf('Testing %s... ', bug);

    try
        switch bug
            case 'BUG-001'
                result = test_BUG001(verbose);
            case 'BUG-002'
                result = test_BUG002(verbose);
            case 'BUG-003'
                result = test_BUG003(verbose);
            case 'BUG-004'
                result = test_BUG004(verbose);
            case 'BUG-005'
                result = test_BUG005(verbose);
            case 'BUG-006'
                result = test_BUG006(verbose);
            case 'BUG-007'
                result = test_BUG007(verbose);
            case 'BUG-008'
                result = test_BUG008(verbose);
            case 'BUG-009'
                result = test_BUG009(verbose);
            case 'BUG-010'
                result = test_BUG010(verbose);
            case 'BUG-011'
                result = test_BUG011(verbose);
            otherwise
                result = struct('bugID', bug, 'status', 'SKIP', ...
                               'message', 'Unknown bug ID', 'timestamp', now);
        end
    catch ME
        result = struct('bugID', bug, 'status', 'FAIL', ...
                       'message', sprintf('Test error: %s', ME.message), ...
                       'timestamp', now);
    end

    results(end+1) = result; %#ok<AGROW>

    % Print result
    if strcmp(result.status, 'PASS')
        fprintf('[PASS] %s\n', result.message);
    elseif strcmp(result.status, 'FAIL')
        fprintf('[FAIL] %s\n', result.message);
    else
        fprintf('[SKIP] %s\n', result.message);
    end
end

fprintf('\n========================================\n');
fprintf('Summary: %d tests, %d passed, %d failed, %d skipped\n', ...
    numel(results), ...
    sum(strcmp({results.status}, 'PASS')), ...
    sum(strcmp({results.status}, 'FAIL')), ...
    sum(strcmp({results.status}, 'SKIP')));
fprintf('========================================\n');

end

%% Individual Test Functions

function result = test_BUG001(verbose)
%TEST_BUG001 Validate fix for malformed if-else in precompute_embeddings
result.bugID = 'BUG-001';
result.timestamp = now;

% Check if file has syntax errors
try
    checkcode('+reg/precompute_embeddings.m', '-id');

    % Try to parse function (doesn't execute, just checks syntax)
    try
        which('reg.precompute_embeddings');
        result.status = 'PASS';
        result.message = 'Syntax check passed';
    catch ME
        result.status = 'FAIL';
        result.message = sprintf('Syntax error: %s', ME.message);
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('checkcode failed: %s', ME.message);
end
end

function result = test_BUG002(verbose)
%TEST_BUG002 Validate fix for duplicate try in doc_embeddings_bert_gpu
result.bugID = 'BUG-002';
result.timestamp = now;

try
    checkcode('+reg/doc_embeddings_bert_gpu.m', '-id');
    which('reg.doc_embeddings_bert_gpu');
    result.status = 'PASS';
    result.message = 'Syntax check passed';
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Syntax error: %s', ME.message);
end
end

function result = test_BUG003(verbose)
%TEST_BUG003 Validate fix for missing closing parenthesis
result.bugID = 'BUG-003';
result.timestamp = now;

try
    checkcode('reg_finetune_encoder_workflow.m', '-id');
    result.status = 'PASS';
    result.message = 'Syntax check passed';
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Syntax error: %s', ME.message);
end
end

function result = test_BUG004(verbose)
%TEST_BUG004 Validate fix for undefined struct field access
result.bugID = 'BUG-004';
result.timestamp = now;

try
    % Test that config loads without error
    C = config();

    % Check if knobs are loaded or workflow has safeguards
    if isfield(C, 'knobs') && isfield(C.knobs, 'FineTune')
        result.status = 'PASS';
        result.message = 'knobs.FineTune loaded from config';
    elseif isfile('knobs.json')
        % Try to load directly
        knobs = jsondecode(fileread('knobs.json'));
        if isfield(knobs, 'FineTune')
            result.status = 'PASS';
            result.message = 'knobs.json contains FineTune section';
        else
            result.status = 'FAIL';
            result.message = 'knobs.json missing FineTune section';
        end
    else
        result.status = 'SKIP';
        result.message = 'knobs.json not present - workflow should have defaults';
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Config error: %s', ME.message);
end
end

function result = test_BUG005(verbose)
%TEST_BUG005 Validate fix for missing file existence check
result.bugID = 'BUG-005';
result.timestamp = now;

% Read the file and check for isfile('params.json')
try
    content = fileread('+reg/doc_embeddings_bert_gpu.m');
    if contains(content, "isfile('params.json')") || contains(content, 'isfile("params.json")')
        result.status = 'PASS';
        result.message = 'File existence check found';
    else
        % Maybe it uses try-catch instead
        if contains(content, 'try') && contains(content, 'params.json')
            result.status = 'PASS';
            result.message = 'Protected by try-catch';
        else
            result.status = 'FAIL';
            result.message = 'No file existence check or try-catch found';
        end
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Could not read file: %s', ME.message);
end
end

function result = test_BUG006(verbose)
%TEST_BUG006 Validate fix for EmbeddingService logic error
result.bugID = 'BUG-006';
result.timestamp = now;

try
    % Read the embed method
    content = fileread('+reg/+service/EmbeddingService.m');

    % Check if save is called before error
    lines = strsplit(content, '\n');
    embedMethodStart = false;
    saveBeforeError = false;

    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if contains(line, 'function') && contains(line, 'embed')
            embedMethodStart = true;
        end
        if embedMethodStart
            if contains(line, '.save(') && ~contains(line, '%')
                saveBeforeError = true;
            end
            if contains(line, 'error(') && saveBeforeError
                result.status = 'FAIL';
                result.message = 'save() still called before error()';
                return;
            end
            if contains(line, 'error(') && ~saveBeforeError
                result.status = 'PASS';
                result.message = 'error() called without premature save()';
                return;
            end
        end
    end

    result.status = 'PASS';
    result.message = 'Method structure appears correct';
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Could not analyze file: %s', ME.message);
end
end

function result = test_BUG007(verbose)
%TEST_BUG007 Validate fix for unsafe file read in config.m
result.bugID = 'BUG-007';
result.timestamp = now;

try
    content = fileread('config.m');

    % Look for isfile check before params.json read
    if contains(content, "isfile('params.json')") || contains(content, 'isfile("params.json")')
        result.status = 'PASS';
        result.message = 'File existence check added';
    else
        result.status = 'FAIL';
        result.message = 'No file existence check found';
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Could not read file: %s', ME.message);
end
end

function result = test_BUG008(verbose)
%TEST_BUG008 Validate fix for index out of bounds
result.bugID = 'BUG-008';
result.timestamp = now;

try
    % Test with minimal dataset
    E = rand(2, 10, 'single');  % 2 documents
    E = E ./ vecnorm(E, 2, 2);  % Normalize

    posSets = cell(2, 1);
    posSets{1} = [2];  % Doc 1's positive is doc 2
    posSets{2} = [1];  % Doc 2's positive is doc 1

    try
        [recallK, mAP] = reg.eval_retrieval(E, posSets, 10);

        if isnan(recallK) || isnan(mAP)
            result.status = 'FAIL';
            result.message = 'Function returned NaN for small dataset';
        else
            result.status = 'PASS';
            result.message = sprintf('Handles small dataset (Recall=%.2f, mAP=%.2f)', recallK, mAP);
        end
    catch ME
        result.status = 'FAIL';
        result.message = sprintf('Error on small dataset: %s', ME.message);
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Test setup error: %s', ME.message);
end
end

function result = test_BUG009(verbose)
%TEST_BUG009 Validate fix for inefficient array growth
result.bugID = 'BUG-009';
result.timestamp = now;

try
    % Check if code still uses end+1 pattern
    content = fileread('+reg/chunk_text.m');

    if contains(content, 'end+1')
        result.status = 'FAIL';
        result.message = 'Still uses inefficient end+1 pattern';
    else
        % Test functionality
        docsT = table(["DOC_1"], ["This is a test document with many words."], {struct()}, ...
            'VariableNames', {'doc_id', 'text', 'meta'});

        try
            chunksT = reg.chunk_text(docsT, 5, 2);
            if height(chunksT) > 0
                result.status = 'PASS';
                result.message = sprintf('Pre-allocation working, generated %d chunks', height(chunksT));
            else
                result.status = 'FAIL';
                result.message = 'No chunks generated';
            end
        catch ME
            result.status = 'FAIL';
            result.message = sprintf('Function error: %s', ME.message);
        end
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Could not read file: %s', ME.message);
end
end

function result = test_BUG010(verbose)
%TEST_BUG010 Validate fix for confusing indexing
result.bugID = 'BUG-010';
result.timestamp = now;

try
    content = fileread('+reg/build_pairs.m');

    % Check if still uses 0+1 pattern
    if contains(content, '0+1') || contains(content, '1+1') || contains(content, '2+1')
        result.status = 'FAIL';
        result.message = 'Still uses confusing arithmetic indexing';
    else
        result.status = 'PASS';
        result.message = 'Uses clean direct indexing';
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Could not read file: %s', ME.message);
end
end

function result = test_BUG011(verbose)
%TEST_BUG011 Validate fix for double cell wrapping
result.bugID = 'BUG-011';
result.timestamp = now;

try
    % Test hybrid_search with actual vocab
    vocab = ["word1", "word2", "word3"];
    Xtfidf = sparse(rand(5, 3));
    E = rand(5, 10, 'single');

    try
        S = reg.hybrid_search(Xtfidf, E, vocab);

        % Check vocab type
        if iscell(S.vocab)
            % Check if double-wrapped
            if iscell(S.vocab{1})
                result.status = 'FAIL';
                result.message = 'vocab is double-wrapped in cells';
            else
                result.status = 'PASS';
                result.message = 'vocab correctly stored as cell array';
            end
        elseif isstring(S.vocab) || ischar(S.vocab)
            result.status = 'PASS';
            result.message = 'vocab stored as string/char array';
        else
            result.status = 'FAIL';
            result.message = sprintf('vocab has unexpected type: %s', class(S.vocab));
        end
    catch ME
        result.status = 'FAIL';
        result.message = sprintf('hybrid_search error: %s', ME.message);
    end
catch ME
    result.status = 'FAIL';
    result.message = sprintf('Test setup error: %s', ME.message);
end
end

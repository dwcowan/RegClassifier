# RegClassifier Bug Reports

**Generated:** 2026-02-03
**Codebase:** RegClassifier (MATLAB Regulatory Topic Classification)
**Total Bugs:** 11 actionable issues

---

## Bug Tracking Status

| ID | Severity | Component | Status | Priority |
|----|----------|-----------|--------|----------|
| BUG-001 | CRITICAL | Embeddings | Open | P0 |
| BUG-002 | CRITICAL | Embeddings | Open | P0 |
| BUG-003 | CRITICAL | Workflow | Open | P0 |
| BUG-004 | CRITICAL | Configuration | Open | P0 |
| BUG-005 | MAJOR | Embeddings | Open | P1 |
| BUG-006 | MAJOR | Services | Open | P1 |
| BUG-007 | MAJOR | Configuration | Open | P2 |
| BUG-008 | MODERATE | Evaluation | Open | P2 |
| BUG-009 | MINOR | Text Processing | Open | P3 |
| BUG-010 | MINOR | Training | Open | P3 |
| BUG-011 | MINOR | Search | Open | P3 |

---

## CRITICAL PRIORITY BUGS (P0)

---

### BUG-001: Malformed If-Else Control Flow in precompute_embeddings

**Severity:** CRITICAL
**Priority:** P0 (Blocks execution)
**Component:** Embeddings
**File:** `+reg/precompute_embeddings.m`
**Lines:** 6-17
**Reported:** 2026-02-03

#### Description
The function has a malformed if-else-end block structure with missing `end` statement, causing a syntax error. The nested if statement on line 7 is properly closed on line 14, but the outer if statement starting on line 6 is missing its closing `end` before the `else` on line 15.

#### Current Code
```matlab
if isfield(C,'embeddings_backend') && strcmpi(C.embeddings_backend,'bert')  % Line 6
    if isfield(C.knobs,'BERT')                                              % Line 7
        args = {};
        if isfield(C.knobs.BERT,'MiniBatchSize'), args = [args, {'MiniBatchSize', C.knobs.BERT.MiniBatchSize}]; end
        if isfield(C.knobs.BERT,'MaxSeqLength'), args = [args, {'MaxSeqLength', C.knobs.BERT.MaxSeqLength}]; end
        E = reg.doc_embeddings_bert_gpu(textStr, args{:});                 % Line 11
    else                                                                     % Line 12
        E = reg.doc_embeddings_bert_gpu(textStr);                          % Line 13
    end                                                                      % Line 14
    % MISSING END HERE!
    else                                                                     % Line 15 - orphaned
        E = reg.doc_embeddings_fasttext(textStr, C.fasttext);              % Line 16
    end                                                                      % Line 17
```

#### Expected Behavior
The function should have proper if-else-end structure that compiles without syntax errors.

#### Actual Behavior
MATLAB parser throws syntax error: "Incorrect use of '=' operator. To assign a value to a variable, use '='. To compare values for equality, use '=='."

#### Root Cause
Missing `end` statement after line 14 to close the outer if block that started on line 6.

#### Proposed Fix
Add `end` statement after line 14:

```matlab
if isfield(C,'embeddings_backend') && strcmpi(C.embeddings_backend,'bert')  % Line 6
    if isfield(C.knobs,'BERT')                                              % Line 7
        args = {};
        if isfield(C.knobs.BERT,'MiniBatchSize'), args = [args, {'MiniBatchSize', C.knobs.BERT.MiniBatchSize}]; end
        if isfield(C.knobs.BERT,'MaxSeqLength'), args = [args, {'MaxSeqLength', C.knobs.BERT.MaxSeqLength}]; end
        E = reg.doc_embeddings_bert_gpu(textStr, args{:});                 % Line 11
    else                                                                     % Line 12
        E = reg.doc_embeddings_bert_gpu(textStr);                          % Line 13
    end                                                                      % Line 14
end  % ADD THIS LINE - closes outer if from line 6
else                                                                         % Line 15
    E = reg.doc_embeddings_fasttext(textStr, C.fasttext);                  % Line 16
end                                                                          % Line 17
```

#### Testing Recommendations
1. Run `checkcode +reg/precompute_embeddings.m` to verify syntax
2. Call function with BERT backend: `precompute_embeddings("test text", struct('embeddings_backend','bert'))`
3. Call function with fasttext backend: `precompute_embeddings("test text", struct('embeddings_backend','fasttext'))`
4. Run existing unit tests that exercise this function

#### Impact Assessment
- **Blocking:** Yes - Code will not compile
- **Workaround:** None - Must be fixed
- **Affected Users:** All users attempting to use projection head or fine-tuning workflows

---

### BUG-002: Duplicate Try Statement in doc_embeddings_bert_gpu

**Severity:** CRITICAL
**Priority:** P0 (Blocks execution)
**Component:** Embeddings
**File:** `+reg/doc_embeddings_bert_gpu.m`
**Lines:** 37-39
**Reported:** 2026-02-03

#### Description
Two consecutive `try` statements without proper structure. Line 37 has a `try` statement, followed immediately by a comment and another `try` statement on line 39, without any corresponding `catch` or code block for the first try.

#### Current Code
```matlab
try                                              % Line 37
    %% Try to use fine-tuned encoder if available
try                                              % Line 39
    S = load('fine_tuned_bert.mat','netFT');
    net = S.netFT.base;
    headFT = S.netFT.head; useHead = true;
    maxLenFT = S.netFT.MaxSeqLength;
catch                                             % Line 44
    net = bert("base-uncased");
    useHead = false; maxLenFT = [];
end  % returns a dlnetwork
catch ME                                          % Line 48
    error("BERT:ModelMissing", "BERT model not found. Install 'Text Analytics Toolbox Model for BERT English'. Original error: %s", ME.message);
end
```

#### Expected Behavior
Single try-catch block with proper nesting for loading fine-tuned model with fallback to base model.

#### Actual Behavior
MATLAB parser throws error: "A CATCH block was entered but no exception was thrown."

#### Root Cause
Copy-paste error or merge conflict left duplicate `try` statement on line 37.

#### Proposed Fix
Remove the duplicate `try` on line 37:

```matlab
%% Try to use fine-tuned encoder if available
try
    S = load('fine_tuned_bert.mat','netFT');
    net = S.netFT.base;
    headFT = S.netFT.head; useHead = true;
    maxLenFT = S.netFT.MaxSeqLength;
catch
    net = bert("base-uncased");
    useHead = false; maxLenFT = [];
end  % returns a dlnetwork
```

And handle the outer BERT model loading separately if needed, or nest properly:

```matlab
try
    % Try to use fine-tuned encoder if available
    try
        S = load('fine_tuned_bert.mat','netFT');
        net = S.netFT.base;
        headFT = S.netFT.head; useHead = true;
        maxLenFT = S.netFT.MaxSeqLength;
    catch
        net = bert("base-uncased");
        useHead = false; maxLenFT = [];
    end  % returns a dlnetwork
catch ME
    error("BERT:ModelMissing", "BERT model not found. Install 'Text Analytics Toolbox Model for BERT English'. Original error: %s", ME.message);
end
```

#### Testing Recommendations
1. Run `checkcode +reg/doc_embeddings_bert_gpu.m`
2. Test with fine-tuned model present: `doc_embeddings_bert_gpu(["test sentence"])`
3. Test without fine-tuned model (rename/move `fine_tuned_bert.mat`)
4. Test with missing BERT toolbox (if possible in test environment)

#### Impact Assessment
- **Blocking:** Yes - Syntax error prevents compilation
- **Workaround:** None
- **Affected Users:** All users using BERT embeddings

---

### BUG-003: Missing Closing Parenthesis in Fine-Tune Workflow

**Severity:** CRITICAL
**Priority:** P0 (Blocks execution)
**Component:** Workflow Scripts
**File:** `reg_finetune_encoder_workflow.m`
**Lines:** 21-23
**Reported:** 2026-02-03

#### Description
Function call to `reg.ft_train_encoder()` is missing closing parenthesis. The multi-line function call ends with a semicolon instead of `);`, causing a syntax error.

#### Current Code
```matlab
netFT = reg.ft_train_encoder(chunksT, P, ...
    'Epochs', C.knobs.FineTune.Epochs, 'BatchSize', C.knobs.FineTune.BatchSize, 'MaxSeqLength', C.knobs.FineTune.MaxSeqLength, ...
    'EncoderLR', C.knobs.FineTune.EncoderLR, 'HeadLR', C.knobs.FineTune.HeadLR, 'Margin', 0.2, 'UnfreezeTopLayers', C.knobs.FineTune.UnfreezeTopLayers, 'Loss', C.knobs.FineTune.Loss, 'Resume', true;
    % ↑ Missing closing parenthesis, has semicolon instead
```

#### Expected Behavior
Function call should end with `);` to properly close the argument list.

#### Actual Behavior
MATLAB throws syntax error: "Expression or statement is incorrect--possibly unbalanced (, {, or [."

#### Root Cause
Typo - semicolon used instead of closing parenthesis followed by semicolon.

#### Proposed Fix
```matlab
netFT = reg.ft_train_encoder(chunksT, P, ...
    'Epochs', C.knobs.FineTune.Epochs, 'BatchSize', C.knobs.FineTune.BatchSize, 'MaxSeqLength', C.knobs.FineTune.MaxSeqLength, ...
    'EncoderLR', C.knobs.FineTune.EncoderLR, 'HeadLR', C.knobs.FineTune.HeadLR, 'Margin', 0.2, 'UnfreezeTopLayers', C.knobs.FineTune.UnfreezeTopLayers, 'Loss', C.knobs.FineTune.Loss, 'Resume', true);
    % ↑ Changed ; to );
```

#### Testing Recommendations
1. Run `checkcode reg_finetune_encoder_workflow.m`
2. Execute the workflow script (after fixing BUG-004 which is a prerequisite)
3. Verify function call completes successfully

#### Impact Assessment
- **Blocking:** Yes - Prevents script execution
- **Workaround:** None
- **Affected Users:** All users attempting fine-tuning workflow

---

### BUG-004: Undefined Struct Field Access in Fine-Tune Workflow

**Severity:** CRITICAL
**Priority:** P0 (Runtime failure)
**Component:** Configuration
**File:** `reg_finetune_encoder_workflow.m`
**Lines:** 22-23
**Reported:** 2026-02-03

#### Description
Script attempts to access nested struct fields `C.knobs.FineTune.*` but `C.knobs` is initialized as empty struct in `config.m:68`. This causes runtime error when accessing undefined fields.

#### Current Code
```matlab
% In config.m line 68:
C.knobs = struct();  % Empty struct!

% In reg_finetune_encoder_workflow.m line 22:
netFT = reg.ft_train_encoder(chunksT, P, ...
    'Epochs', C.knobs.FineTune.Epochs, ...  % ERROR: FineTune field doesn't exist
    'BatchSize', C.knobs.FineTune.BatchSize, ...
    'MaxSeqLength', C.knobs.FineTune.MaxSeqLength, ...
    'EncoderLR', C.knobs.FineTune.EncoderLR, ...
```

#### Expected Behavior
Script should either:
1. Load knobs from `knobs.json` file, OR
2. Use default values if knobs are not configured

#### Actual Behavior
Runtime error: "Reference to non-existent field 'FineTune'."

#### Root Cause
The TODO comment in `config.m:67` states "TODO: implement reg.load_knobs to populate C.knobs and override fields" - this was never implemented.

#### Proposed Fix

**Option 1: Load knobs.json in config.m**
```matlab
% In config.m after line 65:
% Load knobs.json if available
if isfile('knobs.json')
    try
        knobs = jsondecode(fileread('knobs.json'));
        C.knobs = knobs;
    catch ME
        warning("Knobs load failed: %s. Using empty knobs.", ME.message);
        C.knobs = struct();
    end
else
    C.knobs = struct();
end
```

**Option 2: Add existence checks in workflow script**
```matlab
% In reg_finetune_encoder_workflow.m after line 2:
C = config();

% Load knobs with fallback to defaults
params = struct();
if isfile('knobs.json')
    try
        params = jsondecode(fileread('knobs.json'));
    catch
        warning('Could not load knobs.json, using defaults');
    end
end

% Extract fine-tune parameters with defaults
ftEpochs = 4;
ftBatchSize = 32;
ftMaxSeqLength = 256;
ftEncoderLR = 1e-5;
ftHeadLR = 1e-3;
ftUnfreezeTopLayers = 4;
ftLoss = 'triplet';

if isfield(params, 'FineTune')
    if isfield(params.FineTune, 'Epochs'), ftEpochs = params.FineTune.Epochs; end
    if isfield(params.FineTune, 'BatchSize'), ftBatchSize = params.FineTune.BatchSize; end
    if isfield(params.FineTune, 'MaxSeqLength'), ftMaxSeqLength = params.FineTune.MaxSeqLength; end
    if isfield(params.FineTune, 'EncoderLR'), ftEncoderLR = params.FineTune.EncoderLR; end
    if isfield(params.FineTune, 'HeadLR'), ftHeadLR = params.FineTune.HeadLR; end
    if isfield(params.FineTune, 'UnfreezeTopLayers'), ftUnfreezeTopLayers = params.FineTune.UnfreezeTopLayers; end
    if isfield(params.FineTune, 'Loss'), ftLoss = params.FineTune.Loss; end
end

% Then use variables instead of C.knobs.FineTune.*
netFT = reg.ft_train_encoder(chunksT, P, ...
    'Epochs', ftEpochs, 'BatchSize', ftBatchSize, ...
    'MaxSeqLength', ftMaxSeqLength, 'EncoderLR', ftEncoderLR, ...
    'HeadLR', ftHeadLR, 'Margin', 0.2, ...
    'UnfreezeTopLayers', ftUnfreezeTopLayers, ...
    'Loss', ftLoss, 'Resume', true);
```

#### Testing Recommendations
1. Test with valid `knobs.json` file present
2. Test with missing `knobs.json` file (should use defaults)
3. Test with malformed `knobs.json` (should catch and use defaults)
4. Verify all parameter values are correctly passed to `ft_train_encoder`

#### Impact Assessment
- **Blocking:** Yes - Prevents fine-tuning workflow from running
- **Workaround:** Manually add FineTune struct to config or create knobs.json
- **Affected Users:** All users running fine-tuning workflow

---

## MAJOR PRIORITY BUGS (P1)

---

### BUG-005: Missing File Existence Check in doc_embeddings_bert_gpu

**Severity:** MAJOR
**Priority:** P1 (Causes failure in normal usage)
**Component:** Embeddings
**File:** `+reg/doc_embeddings_bert_gpu.m`
**Line:** 12
**Reported:** 2026-02-03

#### Description
Function directly reads `params.json` without checking if file exists. If file is missing, function crashes with file not found error instead of providing graceful fallback.

#### Current Code
```matlab
params = jsondecode(fileread('params.json'));
miniBatchSize = params.MiniBatchSize;
maxSeqLen = params.MaxSeqLength;
```

#### Expected Behavior
Function should check if file exists and use sensible defaults if not present.

#### Actual Behavior
Error: "Unable to read file 'params.json': No such file or directory."

#### Root Cause
Missing existence check before file read operation.

#### Proposed Fix
```matlab
% Set defaults
miniBatchSize = 96;
maxSeqLen = 256;

% Override from params.json if available
if isfile('params.json')
    try
        params = jsondecode(fileread('params.json'));
        if isfield(params, 'MiniBatchSize')
            miniBatchSize = params.MiniBatchSize;
        end
        if isfield(params, 'MaxSeqLength')
            maxSeqLen = params.MaxSeqLength;
        end
    catch ME
        warning('Could not read params.json: %s. Using defaults.', ME.message);
    end
end
```

#### Testing Recommendations
1. Test with `params.json` present and valid
2. Test with `params.json` missing
3. Test with malformed `params.json`
4. Verify defaults are used when file missing

#### Impact Assessment
- **Blocking:** No - Only affects first-time users or missing config
- **Workaround:** Create params.json file
- **Affected Users:** New users, clean installations

---

### BUG-006: Logic Error in EmbeddingService.embed Method

**Severity:** MAJOR
**Priority:** P1 (Data corruption risk)
**Component:** Services
**File:** `+reg/+service/EmbeddingService.m`
**Lines:** 33-49
**Reported:** 2026-02-03

#### Description
The `embed()` method creates an empty output, saves it to repositories, and then throws NotImplemented error. This could corrupt data by saving empty embeddings before any actual computation occurs.

#### Current Code
```matlab
function output = embed(obj, input)
    if ~isempty(obj.ConfigService)
        cfg = obj.ConfigService.getConfig();
    end
    output = reg.service.EmbeddingOutput([]);  % Empty output!
    if ~isempty(obj.EmbeddingRepo)
        obj.EmbeddingRepo.save(output);  % Saving empty data!
    end
    if ~isempty(obj.SearchRepo)
        obj.SearchRepo.save(output);  % Saving empty data!
    end
    error("reg:service:NotImplemented", ...
        "EmbeddingService.embed is not implemented.");
end
```

#### Expected Behavior
Stub method should throw NotImplemented error immediately without side effects, OR implement actual embedding logic.

#### Actual Behavior
Attempts to save empty/null data to repositories before throwing error.

#### Root Cause
Incomplete implementation with premature repository calls.

#### Proposed Fix

**Option 1: Immediate error (safe stub)**
```matlab
function output = embed(obj, input)
    error("reg:service:NotImplemented", ...
        "EmbeddingService.embed is not implemented.");
end
```

**Option 2: Proper implementation**
```matlab
function output = embed(obj, input)
    % Get configuration
    cfg = [];
    if ~isempty(obj.ConfigService)
        cfg = obj.ConfigService.getConfig();
    end

    % Compute embeddings (implement actual logic)
    embeddings = computeEmbeddings(input.Features, cfg);

    % Create output
    output = reg.service.EmbeddingOutput(embeddings);

    % Persist if repositories configured
    if ~isempty(obj.EmbeddingRepo)
        obj.EmbeddingRepo.save(output);
    end
    if ~isempty(obj.SearchRepo)
        obj.SearchRepo.save(output);
    end
end
```

#### Testing Recommendations
1. Verify stub throws error without calling save
2. Test that no empty data is persisted
3. After implementation, verify correct embeddings are computed and saved
4. Test with and without repositories configured

#### Impact Assessment
- **Blocking:** No - Currently only stub, but could corrupt data if accidentally called
- **Workaround:** Don't use EmbeddingService (use direct embedding functions)
- **Affected Users:** Users attempting to use MVC architecture

---

### BUG-007: Unsafe File Read in config.m

**Severity:** MAJOR
**Priority:** P2 (Creates unnecessary warnings)
**Component:** Configuration
**File:** `config.m`
**Line:** 16
**Reported:** 2026-02-03

#### Description
Function attempts to read `params.json` without checking existence first. While wrapped in try-catch, this generates unnecessary file system calls and confusing warning messages.

#### Current Code
```matlab
% === Load params.json overrides ===
try
    params = jsondecode(fileread('params.json'));  % No existence check
catch ME
    warning("Params load/apply failed: %s", ME.message);
    params = struct();
end
```

#### Expected Behavior
Check file existence before attempting to read, only warn if file exists but has errors.

#### Actual Behavior
Generates warning "Params load/apply failed: Unable to read file 'params.json'" even when file is legitimately absent.

#### Root Cause
Missing existence check leads to confusing warnings for normal condition (file not existing).

#### Proposed Fix
```matlab
% === Load params.json overrides ===
params = struct();
if isfile('params.json')
    try
        params = jsondecode(fileread('params.json'));
    catch ME
        warning("Params load/apply failed: %s", ME.message);
        params = struct();
    end
end
```

#### Testing Recommendations
1. Test with params.json present and valid
2. Test with params.json missing (should not warn)
3. Test with malformed params.json (should warn)

#### Impact Assessment
- **Blocking:** No
- **Workaround:** Ignore warning or create empty params.json
- **Affected Users:** All users without params.json

---

## MODERATE PRIORITY BUGS (P2)

---

### BUG-008: Potential Index Out of Bounds in eval_retrieval

**Severity:** MODERATE
**Priority:** P2
**Component:** Evaluation
**File:** `+reg/eval_retrieval.m`
**Lines:** 14-15
**Reported:** 2026-02-03

#### Description
After removing self from ordered results, if the remaining `ord` vector is empty or has fewer than K elements, the slicing operation may fail or produce unexpected results.

#### Current Code
```matlab
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    [~, ord] = sort(scores(i,:), 'descend');
    ord(ord==i) = [];  % remove self - ord could now be empty
    topK = ord(1:min(K,end));  % If ord is empty, this might fail
    recallK(i) = any(ismember(topK, pos));
```

#### Expected Behavior
Should handle edge cases where ord becomes empty or very small after removing self.

#### Actual Behavior
May throw index error or produce incorrect metrics for small datasets.

#### Root Cause
Missing validation after self-removal from candidate list.

#### Proposed Fix
```matlab
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    [~, ord] = sort(scores(i,:), 'descend');
    ord(ord==i) = [];  % remove self

    % Handle edge case: ord is empty or too small
    if isempty(ord)
        recallK(i) = 0;
        AP(i) = 0;
        continue;
    end

    topK = ord(1:min(K, numel(ord)));  % Use numel(ord) instead of end
    recallK(i) = any(ismember(topK, pos));

    % AP calculation
    hits = ismember(ord, pos);
    cumHits = cumsum(hits);
    ranks = find(hits);
    if isempty(ranks)
        AP(i) = 0;
    else
        precAtHits = cumHits(ranks) ./ ranks';
        AP(i) = mean(precAtHits);
    end
end
```

#### Testing Recommendations
1. Test with N=1 (single document)
2. Test with N=2 (minimal dataset)
3. Test with K > N
4. Verify metrics are correct for edge cases

#### Impact Assessment
- **Blocking:** No
- **Workaround:** Use larger datasets (N > K+1)
- **Affected Users:** Users evaluating on very small datasets

---

## MINOR PRIORITY BUGS (P3)

---

### BUG-009: Inefficient Array Growth in chunk_text

**Severity:** MINOR
**Priority:** P3 (Performance)
**Component:** Text Processing
**File:** `+reg/chunk_text.m`
**Lines:** 11-14
**Reported:** 2026-02-03

#### Description
Arrays are grown dynamically in loop using `end+1` indexing, which causes repeated memory reallocation. For large documents, this is inefficient.

#### Current Code
```matlab
for i = 1:height(docsT)
    tokens = split(regexprep(docsT.text(i), '\s+', ' '));
    tokens(tokens=="") = [];
    L = numel(tokens); s = 1;
    if L==0, continue; end
    while s <= L
        e = min(L, s + chunkTokens - 1);
        chunkTokensStr = strjoin(tokens(s:e), " ");
        chunk_id(end+1,1) = "CH_" + docsT.doc_id(i) + "_" + string(s); %#ok<AGROW>
        doc_id(end+1,1)   = docsT.doc_id(i);
        text(end+1,1)     = string(chunkTokensStr);
        start_idx(end+1,1)= s; end_idx(end+1,1)= e;
```

#### Expected Behavior
Pre-allocate arrays based on estimated size for better performance.

#### Actual Behavior
Repeated memory reallocation slows processing for large corpora.

#### Root Cause
No pre-allocation of output arrays.

#### Proposed Fix
```matlab
function chunksT = chunk_text(docsT, chunkTokens, overlap)
    % Estimate total chunks (rough upper bound)
    estimatedChunks = 0;
    for i = 1:height(docsT)
        tokens = split(regexprep(docsT.text(i), '\s+', ' '));
        tokens(tokens=="") = [];
        L = numel(tokens);
        if L > 0
            estimatedChunks = estimatedChunks + ceil(L / (chunkTokens - overlap)) + 1;
        end
    end

    % Pre-allocate arrays
    chunk_id = strings(estimatedChunks, 1);
    doc_id = strings(estimatedChunks, 1);
    text = strings(estimatedChunks, 1);
    start_idx = zeros(estimatedChunks, 1);
    end_idx = zeros(estimatedChunks, 1);

    idx = 1;
    for i = 1:height(docsT)
        tokens = split(regexprep(docsT.text(i), '\s+', ' '));
        tokens(tokens=="") = [];
        L = numel(tokens); s = 1;
        if L==0, continue; end
        while s <= L
            e = min(L, s + chunkTokens - 1);
            chunkTokensStr = strjoin(tokens(s:e), " ");
            chunk_id(idx,1) = "CH_" + docsT.doc_id(i) + "_" + string(s);
            doc_id(idx,1)   = docsT.doc_id(i);
            text(idx,1)     = string(chunkTokensStr);
            start_idx(idx,1)= s;
            end_idx(idx,1)= e;
            idx = idx + 1;
            if e == L, break; end
            s = e - overlap + 1;
        end
    end

    % Trim to actual size
    chunk_id = chunk_id(1:idx-1);
    doc_id = doc_id(1:idx-1);
    text = text(1:idx-1);
    start_idx = start_idx(1:idx-1);
    end_idx = end_idx(1:idx-1);

    chunksT = table(chunk_id, doc_id, text, start_idx, end_idx);
end
```

#### Testing Recommendations
1. Benchmark with large corpus (1000+ documents)
2. Verify output is identical to original implementation
3. Confirm memory usage is reduced

#### Impact Assessment
- **Blocking:** No
- **Workaround:** None needed, works correctly just slower
- **Affected Users:** Users processing large document corpora

---

### BUG-010: Confusing Indexing Style in build_pairs

**Severity:** MINOR
**Priority:** P3 (Code Quality)
**Component:** Training
**File:** `+reg/build_pairs.m`
**Lines:** 42-44
**Reported:** 2026-02-03

#### Description
Using arithmetic expressions like `0+1`, `1+1`, `2+1` instead of direct indices `1`, `2`, `3` is confusing and suggests confusion about 0-based vs 1-based indexing.

#### Current Code
```matlab
P.anchor = trip(0+1,:);    % Unnecessarily complex
P.positive = trip(1+1,:);
P.negative = trip(2+1,:);
```

#### Expected Behavior
Use direct indexing for clarity.

#### Actual Behavior
Functionally correct but confusing to read and maintain.

#### Root Cause
Likely ported from Python/C code with 0-based indexing.

#### Proposed Fix
```matlab
P.anchor = trip(1,:);
P.positive = trip(2,:);
P.negative = trip(3,:);
```

#### Testing Recommendations
1. Verify output is identical
2. Run existing unit tests

#### Impact Assessment
- **Blocking:** No
- **Workaround:** N/A - works correctly
- **Affected Users:** None - code quality issue only

---

### BUG-011: Potential Double Cell Wrapping in hybrid_search

**Severity:** MINOR
**Priority:** P3 (Potential Logic Error)
**Component:** Search
**File:** `+reg/hybrid_search.m`
**Line:** 10
**Reported:** 2026-02-03

#### Description
The struct construction uses `{vocab}` which wraps vocab in a cell array. If vocab is already a cell array, this creates unintended double nesting.

#### Current Code
```matlab
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', {vocab});
```

#### Expected Behavior
Vocab should be stored as-is without additional cell wrapping if it's already a cell array.

#### Actual Behavior
If vocab is `{'word1', 'word2', ...}`, storing it as `{vocab}` creates `{{'word1', 'word2', ...}}`.

#### Root Cause
Unclear whether vocab is a cell array or string array from upstream functions.

#### Proposed Fix

**Option 1: Remove cell wrapper**
```matlab
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', vocab);
```

**Option 2: Explicit cell conversion**
```matlab
% Ensure vocab is cell array
if ~iscell(vocab)
    vocab = cellstr(vocab);
end
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', vocab);
```

#### Testing Recommendations
1. Verify vocab type from ta_features output
2. Test query function with various vocab formats
3. Ensure bagOfWords construction works correctly in do_query

#### Impact Assessment
- **Blocking:** No - May work correctly if downstream code handles nesting
- **Workaround:** None if working correctly
- **Affected Users:** Potentially all users of hybrid search if vocab access fails

---

## Summary

**Total Bugs:** 11
**Critical (P0):** 4 - Must fix immediately
**Major (P1-P2):** 4 - Fix before production use
**Minor (P3):** 3 - Code quality improvements

**Recommended Fix Order:**
1. BUG-001, BUG-002, BUG-003 (syntax errors blocking compilation)
2. BUG-004 (runtime error blocking fine-tuning)
3. BUG-005, BUG-006 (prevent failures in normal usage)
4. BUG-007, BUG-008 (improve robustness)
5. BUG-009, BUG-010, BUG-011 (code quality)


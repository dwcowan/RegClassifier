function tok = init_bert_tokenizer()
%INIT_BERT_TOKENIZER Initialize BERT tokenizer with version compatibility
%
% Returns:
%   tok - bertTokenizer object
%
% This function tries multiple approaches to handle different MATLAB versions
% and BERT API changes across releases.

tok = [];

% Approach 1: Standard model name (R2025b preferred)
try
    tok = bertTokenizer("base-uncased");
    return;
catch ME1
    % Continue to fallback
end

% Approach 2: No arguments (older versions)
try
    tok = bertTokenizer();
    return;
catch ME2
    % Continue to fallback
end

% Approach 3: Alternative model name
try
    tok = bertTokenizer("bert-base-uncased");
    return;
catch ME3
    % All approaches failed
    error('RegClassifier:BERTTokenizerFailed', ...
        ['Failed to initialize BERT tokenizer with all methods.\n' ...
         'BERT is included by default in MATLAB R2025b+.\n' ...
         'For earlier versions, run: supportPackageInstaller\n\n' ...
         'Attempted methods:\n' ...
         '  bertTokenizer("base-uncased"): %s\n' ...
         '  bertTokenizer(): %s\n' ...
         '  bertTokenizer("bert-base-uncased"): %s'], ...
        ME1.message, ME2.message, ME3.message);
end

function tok = init_bert_tokenizer()
%INIT_BERT_TOKENIZER Initialize BERT tokenizer with version compatibility
%
% Returns:
%   tok - bertTokenizer object
%
% This function uses the correct R2025b API where bert() returns both
% the network and tokenizer together.

% Try multiple syntax variants for different MATLAB versions

% R2025b+ syntax: bert(Model="base") returns [net, tokenizer]
try
    [~, tok] = bert(Model="base");
    return;
catch ME1
end

% R2023b-R2024b syntax: bert("base") returns [net, tokenizer]
try
    [~, tok] = bert("base");
    return;
catch ME2
end

% Older syntax: bert() with no args, then create tokenizer separately
try
    [~, tok] = bert();
    return;
catch ME3
end

% Last resort: Create tokenizer directly (R2023b+)
try
    tok = bertTokenizer("base");
    return;
catch ME4
end

% All methods failed - provide helpful error
error('RegClassifier:BERTTokenizerFailed', ...
    ['Failed to initialize BERT tokenizer using any known syntax.\n\n' ...
     'Attempted methods:\n' ...
     '  1. bert(Model="base"): %s\n' ...
     '  2. bert("base"): %s\n' ...
     '  3. bert(): %s\n' ...
     '  4. bertTokenizer("base"): %s\n\n' ...
     'Please verify BERT support package is installed:\n' ...
     '  - Run: supportPackageInstaller\n' ...
     '  - Install: Text Analytics Toolbox Model for BERT-Base Network'], ...
    ME1.message, ME2.message, ME3.message, ME4.message);


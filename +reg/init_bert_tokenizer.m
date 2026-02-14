function tok = init_bert_tokenizer()
%INIT_BERT_TOKENIZER Initialize BERT tokenizer with version compatibility
%
% Returns:
%   tok - bertTokenizer object
%
% R2025b API: bert() with no arguments returns [net, tokenizer] for BERT-Base

% Try multiple syntax variants for different MATLAB versions

% R2025b syntax: bert() with no args returns [net, tokenizer] for BERT-Base
% This is the documented syntax from https://www.mathworks.com/help/textanalytics/ref/bert.html
try
    [~, tok] = bert();
    return;
catch ME1
end

% R2023b-R2024b syntax: bert(Model="base") with name-value pair
try
    [~, tok] = bert(Model="base");
    return;
catch ME2
end

% Alternative syntax: bert("base") with positional argument
try
    [~, tok] = bert("base");
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
     '  1. bert() [R2025b]: %s\n' ...
     '  2. bert(Model="base") [R2024b]: %s\n' ...
     '  3. bert("base") [positional]: %s\n' ...
     '  4. bertTokenizer("base") [direct]: %s\n\n' ...
     'Please verify BERT support package is installed:\n' ...
     '  - Run: supportPackageInstaller\n' ...
     '  - Install: Text Analytics Toolbox Model for BERT-Base Network'], ...
    ME1.message, ME2.message, ME3.message, ME4.message);


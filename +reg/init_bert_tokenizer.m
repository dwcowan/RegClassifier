function tok = init_bert_tokenizer()
%INIT_BERT_TOKENIZER Initialize BERT tokenizer with version compatibility
%
% Returns:
%   tok - bertTokenizer object
%
% This function uses the correct R2025b API where bert() returns both
% the network and tokenizer together.

% R2025b+ syntax: bert() returns [net, tokenizer]
try
    [~, tok] = bert(Model="base");
    return;
catch ME1
    % Fallback: Try without name-value syntax (older MATLAB)
    try
        [~, tok] = bert();
        return;
    catch ME2
        error('RegClassifier:BERTTokenizerFailed', ...
            ['Failed to initialize BERT tokenizer.\n' ...
             'BERT is included by default in MATLAB R2025b+.\n' ...
             'For earlier versions, run: supportPackageInstaller\n\n' ...
             'Errors:\n' ...
             '  bert(Model="base"): %s\n' ...
             '  bert(): %s'], ...
            ME1.message, ME2.message);
    end
end


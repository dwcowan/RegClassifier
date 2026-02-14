function G = load_gold(dirPath)
%LOAD_GOLD Load gold mini-pack from folder (chunks, labels, Ytrue, thresholds).
% Expects files:
%   sample_gold_chunks.csv       (chunk_id, doc_id, text)
%   sample_gold_labels.json      (labels array + synonyms map)
%   sample_gold_Ytrue.csv        (N x K matrix of 0/1)
%   expected_metrics.json        (overall + per_label thresholds)
if nargin<1, dirPath = "gold"; end
chunks = readtable(fullfile(dirPath,"sample_gold_chunks.csv"), "TextType","string");
% Some MATLAB/Octave versions rename the text column (e.g. to Var3 or
% text_).  Ensure the column containing the chunk text is consistently named
% "text" so downstream code can rely on it.
if ~ismember("text", chunks.Properties.VariableNames)
    idx = find(strcmpi(chunks.Properties.VariableNames, "text"), 1);
    if isempty(idx)
        idx = width(chunks); % assume last column holds text
    end
    chunks.Properties.VariableNames{idx} = 'text';  % Use char, not string
end
labJ = jsondecode(fileread(fullfile(dirPath,"sample_gold_labels.json")));
Y = readmatrix(fullfile(dirPath,"sample_gold_Ytrue.csv"));
expJ = jsondecode(fileread(fullfile(dirPath,"expected_metrics.json")));
G = struct('chunks',chunks,'labels',string(labJ.labels),'synonyms',labJ.synonyms,'Y',logical(Y),'expect',expJ);
end

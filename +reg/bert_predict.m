function out = bert_predict(net, ids, segs, mask)
%BERT_PREDICT Predict with correct input ordering for BERT dlnetwork.
%   OUT = BERT_PREDICT(NET, IDS, SEGS, MASK) calls predict on the BERT
%   dlnetwork NET, automatically mapping IDS (token IDs), SEGS (segment
%   IDs), and MASK (attention mask) to the correct positional arguments.
%
%   dlnetwork/predict maps positional arguments to input layers in
%   alphabetical order by layer Name. The BERT model's input layers may
%   be named e.g. "attention_mask", "input_ids", "segment_ids" — so the
%   alphabetical order differs from the logical (ids, segs, mask) order.
%   This function reads net.InputNames at runtime and routes each argument
%   to the correct position.

names = string(net.InputNames);
nInputs = numel(names);
args = cell(1, nInputs);

for i = 1:nInputs
    nm = lower(names(i));
    if contains(nm, "seg") || contains(nm, "type")
        args{i} = segs;
    elseif contains(nm, "mask") || contains(nm, "att")
        args{i} = mask;
    else
        % Default: token IDs (matches "ids", "input_ids", "input", etc.)
        args{i} = ids;
    end
end

out = predict(net, args{:});
end

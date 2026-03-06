% Full contrastive fine-tuning workflow (MATLAB R2025b)
C = config();
% TODO: set random seeds for reproducibility
% reg.set_seeds(42);
% TODO: display active knobs once reg.print_active_knobs is implemented
% reg.print_active_knobs(C);
% TODO: load knob definitions into C.knobs
% if ~isfield(C,'knobs'), C.knobs = reg.load_knobs(); end
if isempty(gcp('nocreate')), parpool('threads'); end

% 1) Prepare data
docsT = reg.ingest_pdfs(C.input_dir);
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% 2) Build triplets for contrastive training
P = reg.ft_build_contrastive_dataset(chunksT, Yboot, 'MaxTriplets', 300000);

% 3) Fine-tune encoder (start with top 4 layers unfreezed)
%    Use knobs with safe defaults so the script survives partial knobs.json
ftArgs = {};
if isfield(C.knobs, 'FineTune')
    FT = C.knobs.FineTune;
    if isfield(FT, 'Epochs'),     ftArgs = [ftArgs, {'Epochs', FT.Epochs}]; end
    if isfield(FT, 'BatchSize'),  ftArgs = [ftArgs, {'BatchSize', FT.BatchSize}]; end
    if isfield(FT, 'EncoderLR'),  ftArgs = [ftArgs, {'EncoderLR', FT.EncoderLR}]; end
    if isfield(FT, 'HeadLR'),     ftArgs = [ftArgs, {'HeadLR', FT.HeadLR}]; end
    if isfield(FT, 'Margin'),     ftArgs = [ftArgs, {'Margin', FT.Margin}]; end
    if isfield(FT, 'MaxSeqLength'),      ftArgs = [ftArgs, {'MaxSeqLength', FT.MaxSeqLength}]; end
    if isfield(FT, 'UnfreezeTopLayers'), ftArgs = [ftArgs, {'UnfreezeTopLayers', FT.UnfreezeTopLayers}]; end
    if isfield(FT, 'Loss'),              ftArgs = [ftArgs, {'Loss', FT.Loss}]; end
    if isfield(FT, 'Resume'),            ftArgs = [ftArgs, {'Resume', FT.Resume}]; end
end
netFT = reg.ft_train_encoder(chunksT, P, ftArgs{:});

% 4) Evaluate retrieval & clustering
metrics = reg.ft_eval(chunksT, Yboot, netFT, 'K', 10);
disp(metrics);

% 5) Save fine-tuned encoder for production embedding
save('fine_tuned_bert.mat','netFT','-v7.3');
fprintf('Saved fine-tuned encoder to fine_tuned_bert.mat\n');

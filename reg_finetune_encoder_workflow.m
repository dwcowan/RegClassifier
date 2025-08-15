% Full contrastive fine-tuning workflow (MATLAB R2024a)
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
netFT = reg.ft_train_encoder(chunksT, P, ...
    'Epochs', C.knobs.FineTune.Epochs, 'BatchSize', C.knobs.FineTune.BatchSize, 'MaxSeqLength', C.knobs.FineTune.MaxSeqLength, ...
    'EncoderLR', C.knobs.FineTune.EncoderLR, 'HeadLR', C.knobs.FineTune.HeadLR, 'Margin', 0.2, 'UnfreezeTopLayers', C.knobs.FineTune.UnfreezeTopLayers, 'Loss', C.knobs.FineTune.Loss, 'Resume', true;

% 4) Evaluate retrieval & clustering
metrics = reg.ft_eval(chunksT, Yboot, netFT, 'K', 10);
disp(metrics);

% 5) Save fine-tuned encoder for production embedding
save('fine_tuned_bert.mat','netFT','-v7.3');
fprintf('Saved fine-tuned encoder to fine_tuned_bert.mat\n');

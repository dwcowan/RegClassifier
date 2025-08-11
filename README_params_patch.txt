
To wire params.json into code:
1. In +reg/doc_embeddings_bert_gpu.m, at the top:
   params = jsondecode(fileread('params.json'));
   miniBatchSize = params.MiniBatchSize;
   maxSeqLen = params.MaxSeqLength;

2. In +reg/ft_train_encoder.m, at the top:
   params = jsondecode(fileread('params.json'));
   if isfield(params,'FineTune')
       p = params.FineTune;
       if ~isfield(args,'BatchSize'), args.BatchSize = p.BatchSize; end
       if ~isfield(args,'MaxSeqLength'), args.MaxSeqLength = params.MaxSeqLength; end
       if ~isfield(args,'UnfreezeTopLayers'), args.UnfreezeTopLayers = p.UnfreezeTopLayers; end
       if ~isfield(args,'EncoderLR'), args.EncoderLR = p.EncoderLR; end
       if ~isfield(args,'HeadLR'), args.HeadLR = p.HeadLR; end
       if ~isfield(args,'Epochs'), args.Epochs = p.Epochs; end
       if ~isfield(args,'Loss'), args.Loss = p.Loss; end
   end

This allows you to change training/batch parameters by editing params.json without touching code.

Fine-tune extras supported in `params.json > FineTune`:
 - `Margin` (0.2)
 - `UseFP16` (false)
 - `CheckpointDir` ("checkpoints")
 - `Resume` (true)
 - `EarlyStopPatience` (2)
 - `EarlyStopMinDelta` (0.01)
 - `EvalY` ([])
 - `EvalEvery` (1)
 - `HardNegatives` (true)
 - `HardNegMaxN` (2000)
 - `Yboot` ([])

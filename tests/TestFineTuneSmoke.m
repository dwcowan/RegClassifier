classdef TestFineTuneSmoke < RegTestCase
    methods (Test)
        function smoke_ft(tc)
            if gpuDeviceCount==0
                tc.assumeTrue(false, 'No GPU, skipping fine-tune smoke test.');
            end
            C = config();
            docsT = reg.ingest_pdfs(C.input_dir);
            chunksT = reg.chunk_text(docsT, 80, 16);
            Y = reg.weak_rules(chunksT.text, C.labels) >= 0.7;
            P = reg.ft_build_contrastive_dataset(chunksT, Y, 'MaxTriplets', 256);
            netFT = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, 'MaxSeqLength', 128, 'UnfreezeTopLayers', 2);
            tc.verifyTrue(isstruct(netFT) && isfield(netFT,'base') && isfield(netFT,'head'));
            save('fine_tuned_bert.mat','netFT','-v7.3');
            tc.verifyTrue(isfile('fine_tuned_bert.mat'));
        end
    end
end

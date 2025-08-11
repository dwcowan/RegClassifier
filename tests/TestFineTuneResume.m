classdef TestFineTuneResume < matlab.unittest.TestCase
    methods (Test)
        function resume_from_checkpoint(tc)
            if gpuDeviceCount==0
                tc.assumeFail("No GPU available; skipping fine-tune resume test.");
            end
            % Small synthetic setup
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            Yboot = Ytrue;  % use ground truth for stability
            P = reg.ft_build_contrastive_dataset(chunksT, Yboot, 'MaxTriplets', 300);
            % First short run to create a checkpoint
            netFT1 = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, 'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, 'CheckpointDir','checkpoints', 'Resume', false);
            list = dir(fullfile('checkpoints','ft_epoch*.mat'));
            tc.verifyNotEmpty(list, "Expected checkpoint not found.");
            % Second run with resume=true; should print 'Resumed' and continue
            out = evalc("netFT2 = reg.ft_train_encoder(chunksT, P, 'Epochs', 2, 'BatchSize', 16, 'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, 'CheckpointDir','checkpoints', 'Resume', true);");
            tc.verifyTrue(contains(out, "Resumed from checkpoint"), "Did not resume from checkpoint as expected.");
            % Cleanup
            if exist('netFT1','var'); end %#ok<NOSEM>
            if exist('netFT2','var'); end %#ok<NOSEM>
            delete('fine_tuned_bert.mat');
            if isfolder('checkpoints'), rmdir('checkpoints','s'); end
        end
    end
end

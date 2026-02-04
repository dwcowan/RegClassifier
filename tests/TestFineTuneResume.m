classdef TestFineTuneResume < RegTestCase
    methods (TestMethodSetup)
        function setupCleanup(tc)
            % Ensure cleanup of generated files and directories even if test fails
            tc.addTeardown(@() deleteIfExists('fine_tuned_bert.mat'));
            tc.addTeardown(@() deleteFolderIfExists('checkpoints'));
        end
    end

    methods (Test)
        function resume_from_checkpoint(tc)
            %RESUME_FROM_CHECKPOINT Test checkpoint save and resume functionality.
            %   Verifies that fine-tuning can save checkpoints and successfully
            %   resume from them in a subsequent training run.
            if gpuDeviceCount==0
                tc.assumeFail("No GPU available; skipping fine-tune resume test.");
            end
            % Small synthetic setup
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            Yboot = Ytrue;  % use ground truth for stability
            P = reg.ft_build_contrastive_dataset(chunksT, Yboot, 'MaxTriplets', 300);
            % First short run to create a checkpoint
            netFT1 = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, ...
                'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, ...
                'CheckpointDir','checkpoints', 'Resume', false);
            list = dir(fullfile('checkpoints','ft_epoch*.mat'));
            tc.verifyNotEmpty(list, "Expected checkpoint file after first training run");
            % Second run with resume=true; should print 'Resumed' and continue
            out = evalc("netFT2 = reg.ft_train_encoder(chunksT, P, 'Epochs', 2, 'BatchSize', 16, 'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, 'CheckpointDir','checkpoints', 'Resume', true);");
            tc.verifyTrue(contains(out, "Resumed from checkpoint"), ...
                "Training should resume from checkpoint when Resume=true");
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end

function deleteFolderIfExists(folderpath)
    if isfolder(folderpath)
        rmdir(folderpath, 's');
    end
end

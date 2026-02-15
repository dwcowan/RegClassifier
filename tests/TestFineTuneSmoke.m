classdef TestFineTuneSmoke < fixtures.RegTestCase
    methods (TestMethodSetup)
        function setupCleanup(tc)
            % Ensure cleanup of generated files even if test fails
            tc.addTeardown(@() deleteIfExists('fine_tuned_bert.mat'));
        end
    end

    methods (Test)
        function smoke_ft(tc)
            %SMOKE_FT Basic smoke test for encoder fine-tuning.
            %   Verifies that fine-tuning runs for 1 epoch without errors
            %   and produces a valid network structure with base and head.
            if gpuDeviceCount==0
                tc.assumeTrue(false, 'No GPU, skipping fine-tune smoke test.');
            end

            % Check if BERT is available
            try
                [~, ~] = bert("Model", "base");  % Load BERT model and tokenizer
            catch ME
                if contains(ME.identifier, 'BERTNotAvailable') || ...
                   contains(ME.identifier, 'specialTokensNotInVocab') || ...
                   contains(ME.message, 'special tokens')
                    tc.assumeTrue(false, 'BERT model not available. Run supportPackageInstaller to download.');
                else
                    rethrow(ME);  % Re-throw unexpected errors
                end
            end

            % Use simulated CRR data with known regulatory keywords
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            Yboot = Ytrue;  % use ground truth for stability
            P = reg.ft_build_contrastive_dataset(chunksT, Yboot, 'MaxTriplets', 256);
            netFT = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, ...
                'MaxSeqLength', 128, 'UnfreezeTopLayers', 2);
            tc.verifyTrue(isstruct(netFT) && isfield(netFT,'base') && isfield(netFT,'head'), ...
                'Fine-tuned network should be a struct with base and head fields');
            save('fine_tuned_bert.mat','netFT','-v7.3');
            tc.verifyTrue(isfile('fine_tuned_bert.mat'), ...
                'Fine-tuned model file should be saved successfully');
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end

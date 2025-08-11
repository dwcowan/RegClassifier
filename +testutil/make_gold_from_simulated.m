function make_gold_from_simulated(outDir)
%MAKE_GOLD_FROM_SIMULATED Write a gold mini-pack using the simulated CRR set.
% You can then manually expand the CSV with more rows (~50–200).
if nargin<1, outDir = "gold"; end
[chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
if ~isfolder(outDir), mkdir(outDir); end
% chunks
writetable(chunksT, fullfile(outDir,"sample_gold_chunks.csv"));
% labels + synonyms (basic)
L.labels = cellstr(labels);
L.synonyms = struct('IRB',{{'internal ratings based','downturn lgd','pd','lgd','ead','slotting','article 180'}}, ...
                    'Liquidity_LCR',{{'lcr','hqla','operational deposits','c 73.00','delegated act'}}, ...
                    'AML_KYC',{{'aml','kyc','cdd','pep','sanctions'}}, ...
                    'Securitisation',{{'securitisation','srt','sts','tranche'}}, ...
                    'LeverageRatio',{{'leverage ratio','exposure measure','ccf','off-balance-sheet'}});
fid = fopen(fullfile(outDir,"sample_gold_labels.json"),'w'); fprintf(fid, jsonencode(L,'PrettyPrint',true)); fclose(fid);
% Ytrue
writematrix(double(Ytrue), fullfile(outDir,"sample_gold_Ytrue.csv"));
% thresholds
EXP.overall = struct('RecallAt10_min',0.80,'mAP_min',0.60,'nDCG@10_min',0.60,'tolerance',0.02);
EXP.per_label = struct('IRB',0.80,'Liquidity_LCR',0.80,'AML_KYC',0.60,'Securitisation',0.60,'LeverageRatio',0.60);
fid = fopen(fullfile(outDir,"expected_metrics.json"),'w'); fprintf(fid, jsonencode(EXP,'PrettyPrint',true)); fclose(fid);
fprintf('Gold pack written to %s\n', outDir);
end

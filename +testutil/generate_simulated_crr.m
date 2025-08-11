function [chunksT, labels, Ytrue] = generate_simulated_crr()
%GENERATE_SIMULATED_CRR Build a small synthetic corpus mimicking CRR style with known labels.
% Returns:
%   chunksT: table(chunk_id, doc_id, text)
%   labels: string[] of label names
%   Ytrue: logical matrix (N x K) ground truth

labels = ["IRB","Liquidity_LCR","AML_KYC","Securitisation","LeverageRatio"];
docs = {
% IRB-heavy
"Article 180 — Internal Ratings Based (IRB) approach: PD, LGD and EAD calibration shall reflect downturn conditions. Banks shall estimate loss given default (LGD) using long-run averages. The estimation of exposure at default (EAD) includes credit conversion factors for undrawn commitments." , "DOC_IRB_1";
"Annex — IRB slotting criteria; supervisory mapping functions for specialised lending; references to downturn LGD and conservatism in parameter estimation." , "DOC_IRB_2";
% LCR-focused
"Part Six — Liquidity Coverage Ratio (LCR): Credit institutions shall hold high quality liquid assets (HQLA) to withstand 30 calendar days of stress outflows. Level 1, Level 2A and Level 2B asset caps apply; operational deposits outflow rates are prescribed." , "DOC_LCR_1";
"Template C 73.00: HQLA composition and outflow assumptions; contingent funding obligations and secured funding transactions as per Delegated Act." , "DOC_LCR_2";
% AML/KYC
"Chapter — AML and KYC: Institutions shall undertake customer due diligence (CDD), ongoing monitoring, and sanctions screening. Politically exposed persons require enhanced due diligence under AMLD." , "DOC_AML_1";
% Securitisation / SRT
"Title — Securitisation: significant risk transfer (SRT) tests; STS criteria; tranche maturity and risk weights; internal assessment approach where applicable." , "DOC_SEC_1";
% Leverage Ratio
"Part Seven — Leverage Ratio: exposure measure includes derivatives replacement cost and potential future exposure; off-balance-sheet items subject to credit conversion factors; public disclosure requirements." , "DOC_LR_1";
};

N = size(docs,1);
chunk_id = strings(N,1); doc_id = strings(N,1); text = strings(N,1);
for i=1:N
    chunk_id(i) = "CH_SIM_" + string(i);
    doc_id(i) = string(docs{i,2});
    text(i) = string(docs{i,1});
end
chunksT = table(chunk_id, doc_id, text);

% Ground truth label matrix
K = numel(labels);
Ytrue = false(N, K);
% IRB: rows 1-2
Ytrue(1,1) = true; Ytrue(2,1) = true;
% LCR: rows 3-4
Ytrue(3,2) = true; Ytrue(4,2) = true;
% AML: row 5
Ytrue(5,3) = true;
% Securitisation: row 6
Ytrue(6,4) = true;
% Leverage Ratio: row 7
Ytrue(7,5) = true;
end

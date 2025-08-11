function Yweak = weak_rules(textStr, labels)
%WEAK_RULES Simple keyword-based weak supervision
rules = containers.Map;
rules('IRB') = ["internal ratings based","irb","pd","lgd","ead","slotting"];
rules('CreditRisk') = ["credit risk","credit conversion factor","counterparty credit"];
rules('Securitisation') = ["securitisation","securitization","tranche","sts"];
rules('SRT') = ["significant risk transfer","srt","crt"];
rules('MarketRisk_FRTB') = ["frtb","market risk","ima","sa"];
rules('Liquidity_LCR') = ["lcr","liquidity coverage ratio","hqla"];
rules('Liquidity_NSFR') = ["nsfr","net stable funding"];
rules('LeverageRatio') = ["leverage ratio","lr","exposure measure"];
rules('OperationalRisk') = ["operational risk","ama","sma","loss event"];
rules('AML_KYC') = ["aml","kyc","money laundering","sanctions","cft"];
rules('Governance') = ["governance","remuneration","board","fit and proper"];
rules('Reporting_COREP_FINREP') = ["corep","finrep","xbrl","reporting templates"];
rules('StressTesting') = ["stress test","icaap","ilaap","scenario"];
rules('Outsourcing_ICT_DORA') = ["outsourcing","ict","dora","third-party"];

textStr = lower(string(textStr));
Yweak = zeros(numel(textStr), numel(labels));
for j = 1:numel(labels)
    lab = labels(j);
    pats = rules(lab);
    hit = false(numel(textStr),1);
    for p = 1:numel(pats)
        hit = hit | contains(textStr, lower(pats(p)));
    end
    Yweak(:,j) = hit * 0.9;  % confident prior when any rule hits
end
end

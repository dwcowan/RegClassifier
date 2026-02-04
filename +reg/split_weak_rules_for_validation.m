function [rules_train, rules_eval] = split_weak_rules_for_validation()
%SPLIT_WEAK_RULES_FOR_VALIDATION Create independent train/eval rule sets.
%   [rules_train, rules_eval] = SPLIT_WEAK_RULES_FOR_VALIDATION()
%   splits weak labeling keywords into two disjoint sets for training and
%   evaluation, addressing data leakage without manual annotation.
%
%   PRINCIPLE:
%       - Training rules: Primary/common keywords
%       - Evaluation rules: Alternative/synonymous keywords
%       - NO OVERLAP between sets
%       - Both sets capture same concepts but with different signals
%
%   OUTPUTS:
%       rules_train - Map of training rules (for weak supervision)
%       rules_eval  - Map of evaluation rules (for validation)
%
%   USAGE:
%       [train_rules, eval_rules] = reg.split_weak_rules_for_validation();
%
%       % Train on training rules
%       Yweak_train = compute_weak_labels(texts, train_rules);
%       model = train(features, Yweak_train);
%
%       % Evaluate on evaluation rules (independent signal)
%       Yweak_eval = compute_weak_labels(texts, eval_rules);
%       metrics = evaluate(model, Yweak_eval);
%
%   ADVANTAGES:
%       - Zero cost
%       - Addresses circular validation
%       - No annotation needed
%       - Can implement today
%
%   LIMITATIONS:
%       - Both sets still noisy (weak labels)
%       - Requires careful keyword splitting
%       - Evaluation set may be smaller (fewer keywords)
%
%   SEE ALSO: reg.weak_rules_improved, reg.weak_rules

% Training rules (primary/common keywords)
rules_train = containers.Map;
rules_train('IRB') = [
    "internal ratings based", "irb approach", "irb permission", ...
    "pd estimation", "lgd estimation", "ead estimation"
];

rules_train('CreditRisk') = [
    "credit risk", "credit conversion factor", "counterparty credit", ...
    "credit quality", "creditworthiness"
];

rules_train('Securitisation') = [
    "securitisation", "securitization", "tranche", ...
    "originator", "sponsor"
];

rules_train('SRT') = [
    "significant risk transfer", "srt assessment", ...
    "risk retention"
];

rules_train('MarketRisk_FRTB') = [
    "frtb", "fundamental review", "market risk capital", ...
    "trading book", "ima approval"
];

rules_train('Liquidity_LCR') = [
    "lcr", "liquidity coverage ratio", "liquidity buffer", ...
    "30-day stress"
];

rules_train('Liquidity_NSFR') = [
    "nsfr", "net stable funding ratio", ...
    "stable funding requirement"
];

rules_train('LeverageRatio') = [
    "leverage ratio", "tier 1 capital", ...
    "total exposure measure"
];

rules_train('OperationalRisk') = [
    "operational risk", "operational loss", ...
    "business environment"
];

rules_train('AML_KYC') = [
    "money laundering", "kyc", "customer due diligence", ...
    "sanctions screening"
];

rules_train('Governance') = [
    "governance", "board of directors", "management body", ...
    "remuneration policy"
];

rules_train('Reporting_COREP_FINREP') = [
    "corep", "finrep", "supervisory reporting", ...
    "reporting templates"
];

rules_train('StressTesting') = [
    "stress test", "stress scenario", "adverse scenario", ...
    "macroeconomic stress"
];

rules_train('Outsourcing_ICT_DORA') = [
    "outsourcing", "third-party", "service provider", ...
    "cloud services"
];

% Evaluation rules (alternative/specific keywords)
% IMPORTANT: No overlap with training rules
rules_eval = containers.Map;

rules_eval('IRB') = [
    "slotting", "specialized lending", ...
    "foundation irb", "f-irb", "advanced irb", "a-irb", ...
    "probability of default", "loss given default", "exposure at default", ...
    "corporate exposure", "retail exposure", "dilution risk"
];

rules_eval('CreditRisk') = [
    "capital requirement for credit", "standardised approach", "sa-cr", ...
    "risk weight", "exposure class", "mitigation techniques", ...
    "credit risk mitigation", "crm", "collateral"
];

rules_eval('Securitisation') = [
    "sts securitisation", "simple transparent standardised", ...
    "senior tranche", "mezzanine tranche", "residual risk", ...
    "synthetic securitisation", "traditional securitisation"
];

rules_eval('SRT') = [
    "credit risk transfer", "crt", "risk weight relief", ...
    "first loss", "protection seller"
];

rules_eval('MarketRisk_FRTB') = [
    "internal model approach", "ima", "standardised approach", "sa-tb", ...
    "market risk rwa", "desk-level", "non-modellable risk factors", ...
    "nmrf", "backtesting", "profit and loss attribution"
];

rules_eval('Liquidity_LCR') = [
    "high quality liquid assets", "hqla", "level 1 assets", "level 2a assets", ...
    "net cash outflow", "run-off rate", "inflow cap", ...
    "liquidity coverage requirement"
];

rules_eval('Liquidity_NSFR') = [
    "available stable funding", "asf", "required stable funding", "rsf", ...
    "stable funding ratio", "one-year horizon", ...
    "encumbered assets"
];

rules_eval('LeverageRatio') = [
    "lr requirement", "exposure measure", "off-balance-sheet items", ...
    "derivatives exposure", "securities financing transactions", "sft", ...
    "3% requirement"
];

rules_eval('OperationalRisk') = [
    "ama", "advanced measurement approach", "sma", "standardised measurement approach", ...
    "loss event", "business indicator", "internal loss data", ...
    "operational risk capital"
];

rules_eval('AML_KYC') = [
    "aml", "anti-money laundering", "know your customer", ...
    "cft", "counter financing of terrorism", "sanctions", ...
    "politically exposed person", "pep", "enhanced due diligence", "edd", ...
    "suspicious transaction"
];

rules_eval('Governance') = [
    "fit and proper", "suitability assessment", ...
    "internal governance", "risk appetite framework", "raf", ...
    "three lines of defence", "remuneration", ...
    "variable remuneration", "bonus cap"
];

rules_eval('Reporting_COREP_FINREP') = [
    "xbrl", "reporting framework", "validation rules", ...
    "corep templates", "finrep templates", "imorb", ...
    "data quality", "reporting frequency"
];

rules_eval('StressTesting') = [
    "icaap", "ilaap", "internal capital adequacy", ...
    "internal liquidity adequacy", "scenario analysis", ...
    "reverse stress test", "baseline scenario"
];

rules_eval('Outsourcing_ICT_DORA') = [
    "ict", "information and communication technology", ...
    "dora", "digital operational resilience", ...
    "critical functions", "intra-group outsourcing", ...
    "exit strategy", "concentration risk"
];

% Validate no overlap
all_train_keywords = [];
all_eval_keywords = [];

train_labels = keys(rules_train);
for i = 1:numel(train_labels)
    all_train_keywords = [all_train_keywords, rules_train(train_labels{i})];
end

eval_labels = keys(rules_eval);
for i = 1:numel(eval_labels)
    all_eval_keywords = [all_eval_keywords, rules_eval(eval_labels{i})];
end

% Check for overlap
overlap = intersect(lower(all_train_keywords), lower(all_eval_keywords));
if ~isempty(overlap)
    warning('reg:split_weak_rules:Overlap', ...
        'Found %d overlapping keywords between train and eval sets: %s', ...
        numel(overlap), strjoin(overlap, ', '));
end

% Print statistics
fprintf('\n=== Weak Rule Split Statistics ===\n');
fprintf('Training keywords: %d\n', numel(all_train_keywords));
fprintf('Evaluation keywords: %d\n', numel(all_eval_keywords));
fprintf('Overlap: %d keywords\n', numel(overlap));
fprintf('Labels covered: %d\n', numel(train_labels));
fprintf('=====================================\n\n');

end

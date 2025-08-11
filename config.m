function C = config()
%CONFIG Project configuration for regulatory topic classifier

% Default Chunking
C.chunk_size_tokens = 350;
C.chunk_overlap     = 60;

% Load knobs and apply overrides
try
    C.knobs = reg.load_knobs();
catch ME
    warning("Knobs load/apply failed: %s", ME.message);
    C.knobs = struct();
end

% Display active knobs summary
disp('=== Active knobs configuration ===');
disp(jsonencode(C.knobs));

% Apply Chunk overrides
if isfield(C.knobs,'Chunk')
    if isfield(C.knobs.Chunk,'SizeTokens'), C.chunk_size_tokens = C.knobs.Chunk.SizeTokens; end
    if isfield(C.knobs.Chunk,'Overlap'),    C.chunk_overlap = C.knobs.Chunk.Overlap; end
end

C.input_dir   = "data/pdfs";     % drop regs here (PDFs)
C.labels = ["IRB","CreditRisk","Securitisation","SRT","MarketRisk_FRTB", ...
            "Liquidity_LCR","Liquidity_NSFR","LeverageRatio","OperationalRisk", ...
            "AML_KYC","Governance","Reporting_COREP_FINREP","StressTesting","Outsourcing_ICT_DORA"];

% FastText embedding (Text Analytics Toolbox)
C.embeddings_backend = 'bert'; % 'bert' or 'fasttext'
C.fasttext = struct('language','en');  % auto-download on first use

% Model/training
C.lda_topics  = 12;
C.min_rule_conf = 0.7;  % threshold to accept weakly-labeled positives for bootstrap
C.kfold = 5;

% DB (set enable=true to persist in pipeline). For tests we use sqlite.
C.db = struct('enable', false, 'vendor','postgres', 'dbname','reg_topics', ...
              'user','user','pass','pass','server','localhost','port',5432, ...
              'sqlite_path', "tests/tmp/test_reg_topics.sqlite");

% Reports
C.report_title = "Banking Regulation Topic Classifier — Snapshot";

end

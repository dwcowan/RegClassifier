function C = config()
%CONFIG Project configuration for regulatory topic classifier

% Load knobs from knobs.json if present
C.knobs = reg.load_knobs();
if isfield(C.knobs,'Chunk')
    if isfield(C.knobs.Chunk,'SizeTokens'), C.chunk_size_tokens = C.knobs.Chunk.SizeTokens; end
    if isfield(C.knobs.Chunk,'Overlap'),    C.chunk_overlap = C.knobs.Chunk.Overlap; end
end

% Display active knobs summary
disp('=== Active knobs configuration ===');
disp(jsonencode(C.knobs));

C.input_dir   = "data/pdfs";     % drop regs here (PDFs)
C.labels = ["IRB","CreditRisk","Securitisation","SRT","MarketRisk_FRTB", ...
            "Liquidity_LCR","Liquidity_NSFR","LeverageRatio","OperationalRisk", ...
            "AML_KYC","Governance","Reporting_COREP_FINREP","StressTesting","Outsourcing_ICT_DORA"];

% Chunking
C.chunk_size_tokens = 350;
C.chunk_overlap     = 60;

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
              'sqlite_path', "./my_reg_topics.sqlite");

% Reports
C.report_title = "Banking Regulation Topic Classifier — Snapshot";

    % === Load knobs.json and apply Chunk overrides ===
    try
        K = reg.load_knobs();
        C.knobs = K;
        if isfield(K,'Chunk')
            if isfield(K.Chunk,'SizeTokens'), C.chunk_size_tokens = K.Chunk.SizeTokens; end
            if isfield(K.Chunk,'Overlap'),    C.chunk_overlap     = K.Chunk.Overlap;    end
        end
    catch ME
        warning("Knobs load/apply failed: %s", ME.message);
    end
    
end

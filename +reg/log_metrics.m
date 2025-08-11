function log_metrics(runId, variant, metrics, varargin)
%LOG_METRICS Append metrics to runs/metrics.csv (lightweight tracking).
% runId: string (e.g., datestr or uuid)
% variant: 'baseline' | 'projection' | 'finetuned' | custom
% metrics: struct with fields like recallAt10, mAP, ndcg (scalar doubles)
% Optional NV: 'Epoch' (double), 'Extra' (struct/string)

p = inputParser;
addParameter(p,'Epoch',NaN);
addParameter(p,'Extra',struct());
parse(p,varargin{:});
R = p.Results;

outDir = fullfile("runs");
if ~isfolder(outDir), mkdir(outDir); end
csvPath = fullfile(outDir, "metrics.csv");

ts = string(datetime('now','Format','yyyy-MM-dd''T''HH:mm:ss'));
fields = fieldnames(metrics);
rows = strings(numel(fields),1);
for i=1:numel(fields)
    key = fields{i}; val = metrics.(key);
    rows(i) = sprintf('%s,%s,%s,%s,%.6f,%s', ts, runId, variant, key, val, string(R.Epoch));
end

if ~isfile(csvPath)
    fid = fopen(csvPath,'w');
    fprintf(fid, "timestamp,run_id,variant,metric,value,epoch\n");
else
    fid = fopen(csvPath,'a');
end
fprintf(fid, "%s\n", strjoin(rows, "\n"));
fclose(fid);
end

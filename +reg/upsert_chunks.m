function upsert_chunks(conn, chunksT, labels, pred, scores)
%UPSERT_CHUNKS Insert/Upsert chunk rows, label columns and score columns
% Build a table with label columns (0/1) and numeric score columns
L = cellstr("lbl_" + labels);
P = array2table(pred, 'VariableNames', L);
if exist('scores','var') && ~isempty(scores)
    SL = cellstr("score_" + labels);
    S = array2table(scores, 'VariableNames', SL);
    T = [chunksT(:, {'chunk_id','doc_id','text'}) P S];
else
    T = [chunksT(:, {'chunk_id','doc_id','text'}) P];
end

if isstruct(conn) && isfield(conn,'sqlite')
    sconn = conn.sqlite;
    % Create label/score columns if needed
    cols = T.Properties.VariableNames;
    % Only retrieve column names to avoid NULL default values triggering errors
    cur = fetch(sconn, "SELECT name FROM pragma_table_info('reg_chunks');");
    if istable(cur)
        existing = string(cur{:,1});  % Only take the 'name' column
    else
        existing = string(cur(:,1));
    end
    toAdd = setdiff(string(cols), existing);
    for k = 1:numel(toAdd)
        colname = toAdd(k);
        % Validate column name to prevent SQL injection (alphanumeric + underscore only)
        if ~isempty(regexp(colname, '[^a-zA-Z0-9_]', 'once'))
            error('reg:upsert_chunks:InvalidColumnName', ...
                'Column name contains invalid characters: %s', colname);
        end
        if startsWith(colname, "score_")
            coltype = "REAL";
        else
            coltype = "INTEGER";
        end
        % Column name validated, safe to use in SQL
        exec(sconn, "ALTER TABLE reg_chunks ADD COLUMN " + colname + " " + coltype);
    end
    % Upsert rows (INSERT OR REPLACE) wrapped in a transaction.
    % Without a transaction, each INSERT auto-commits which is ~100x slower.
    exec(sconn, 'BEGIN TRANSACTION');
    try
        colnames = string(cols);
        for i = 1:height(T)
            row = T(i,:);
            vals = table2cell(row);
            sqlvals = strings(1, numel(vals));
            for j = 1:numel(vals)
                v = vals{j};
                if isstring(v) || ischar(v)
                    % SQL injection prevention: escape single quotes by doubling them
                    sqlvals(j) = "'" + strrep(string(v), "'", "''") + "'";
                elseif islogical(v)
                    sqlvals(j) = num2str(double(v));
                elseif isnumeric(v) && isscalar(v) && (isnan(v) || isinf(v))
                    sqlvals(j) = "NULL";
                else
                    sqlvals(j) = num2str(v);
                end
            end
            sql = "INSERT OR REPLACE INTO reg_chunks (" + join(colnames,",") + ") VALUES (" + join(sqlvals,",") + ")";
            exec(sconn, sql);
        end
        exec(sconn, 'COMMIT');
    catch txnErr
        exec(sconn, 'ROLLBACK');
        rethrow(txnErr);
    end
else
    % Database Toolbox server (e.g., Postgres) — naive approach: try sqlwrite then ignore conflicts
    try
        sqlwrite(conn, 'reg_chunks', T);
    catch ME1
        warning('Batch insert failed: %s. Trying row-by-row insert.', ME1.message);
        % Fallback: insert row by row (replace w/ vendor-specific upsert in prod)
        failCount = 0;
        for i = 1:height(T)
            try
                sqlwrite(conn, 'reg_chunks', T(i,:));
            catch ME2
                failCount = failCount + 1;
                if failCount == 1
                    % Log first failure for debugging
                    warning('First row insert failed: %s', ME2.message);
                end
            end
        end
        if failCount > 0
            warning('%d of %d rows failed to insert', failCount, height(T));
        end
    end
end
end

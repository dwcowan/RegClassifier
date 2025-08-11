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
    cur = fetch(sconn, "SELECT name FROM pragma_table_info(''reg_chunks'');");
    if istable(cur)
        existing = string(cur{:,:});
    else
        existing = string(cur(:,1));
    end
    toAdd = setdiff(string(cols), existing);
    for k = 1:numel(toAdd)
        colname = toAdd(k);
        if startsWith(colname, "score_")
            coltype = "REAL";
        else
            coltype = "TEXT";
        end
        exec(sconn, "ALTER TABLE reg_chunks ADD COLUMN " + colname + " " + coltype);
    end
    % Upsert rows (INSERT OR REPLACE)
    for i = 1:height(T)
        row = T(i,:);
        % Build REPLACE INTO with all columns
        colnames = string(cols);
        placeholders = join(repmat("?",1,numel(colnames)) , ",");
        sql = "INSERT OR REPLACE INTO reg_chunks (" + join(colnames,",") + ") VALUES (" + placeholders + ")";
        exec(sconn, sql, table2cell(row));
    end
else
    % Database Toolbox server (e.g., Postgres) — naive approach: try sqlwrite then ignore conflicts
    try
        sqlwrite(conn, 'reg_chunks', T);
    catch
        % Fallback: insert row by row (replace w/ vendor-specific upsert in prod)
        for i = 1:height(T)
            try, sqlwrite(conn, 'reg_chunks', T(i,:)); catch, end
        end
    end
end
end

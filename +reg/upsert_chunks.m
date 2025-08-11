function upsert_chunks(conn, chunksT, labels, pred, scores)
%UPSERT_CHUNKS Insert/Upsert chunk rows and label columns
% Build a table with label columns (0/1) and simple score cols (optional)
L = cellstr("lbl_" + labels);
P = array2table(pred, 'VariableNames', L);
T = [chunksT(:, {'chunk_id','doc_id','text'}) P];

if isstruct(conn) && isfield(conn,'sqlite')
    sconn = conn.sqlite;
    % Create label columns if needed
    cols = fieldnames(T)';
    cur = fetch(sconn, "SELECT name FROM pragma_table_info('reg_chunks');");
    existing = string(cur(:,1));
    toAdd = setdiff(string(cols), existing);
    for k = 1:numel(toAdd)
        exec(sconn, "ALTER TABLE reg_chunks ADD COLUMN " + toAdd(k) + " TEXT");
    end
    % Upsert rows (INSERT OR REPLACE)
    for i = 1:height(T)
        row = T(i,:);
        % Build REPLACE INTO with all columns
        colnames = string(T.Properties.VariableNames);
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

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
    existing = string(cur.name);
    toAdd = setdiff(string(cols), existing);
    for k = 1:numel(toAdd)
        exec(sconn, "ALTER TABLE reg_chunks ADD COLUMN " + toAdd(k) + " TEXT");
    end
    % Upsert rows (INSERT OR REPLACE)
    colnames = string(T.Properties.VariableNames);
    colList = join(colnames, ",");
    for i = 1:height(T)
        row = T(i,:);
        vals = table2cell(row);
        vstr = strings(1, numel(vals));
        for j = 1:numel(vals)
            v = vals{j};
            if isstring(v) || ischar(v)
                sv = string(v);
                sv = replace(sv, "'", "''");
                vstr(j) = "'" + sv + "'";
            elseif isnumeric(v) || islogical(v)
                vstr(j) = string(v);
            else
                error('Unsupported value type for SQLite upsert.');
            end
        end
        sql = "INSERT OR REPLACE INTO reg_chunks (" + colList + ") VALUES (" + join(vstr, ",") + ")";
        exec(sconn, sql);
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

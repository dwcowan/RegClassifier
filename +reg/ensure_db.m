function conn = ensure_db(DB)
%ENSURE_DB Returns a connection struct supporting Postgres or SQLite.
% For SQLite, it creates a file (DB.sqlite_path) and returns struct with .sqlite handle.
if isfield(DB,'vendor') && strcmpi(DB.vendor,'sqlite')
    if ~isfolder(fileparts(DB.sqlite_path)), mkdir(fileparts(DB.sqlite_path)); end
    if isfile(DB.sqlite_path)
        sconn = sqlite(DB.sqlite_path);          % open existing file
    else
        sconn = sqlite(DB.sqlite_path,'create'); % create new file
    end
    % ensure table
    createSQL = [
        'CREATE TABLE IF NOT EXISTS reg_chunks (' ...
        '  chunk_id TEXT PRIMARY KEY,' ...
        '  doc_id TEXT,' ...
        '  text TEXT' ...
        ');'];
    exec(sconn, createSQL);
    conn = struct('sqlite', sconn, 'vendor','sqlite');
else
    % Default to Database Toolbox server connection (e.g., Postgres)
    conn = database(DB.dbname, DB.user, DB.pass, 'Vendor', DB.vendor, ...
        'Server', DB.server, 'Port', DB.port);
    if ~isopen(conn)
        error("DB:ConnectFailed","Failed to connect to DB: %s", conn.Message);
    end
    createSQL = [
        'CREATE TABLE IF NOT EXISTS reg_chunks (' ...
        '  chunk_id TEXT PRIMARY KEY,' ...
        '  doc_id TEXT,' ...
        '  text TEXT' ...
        ');'];
    exec(conn, createSQL);
end
end

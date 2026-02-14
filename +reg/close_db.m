function close_db(conn)
%CLOSE_DB Close database connection and free resources.
%   CLOSE_DB(conn) closes the database connection created by reg.ensure_db
%   and releases associated system resources.
%
%   This function handles both SQLite and Database Toolbox connections.
%   It safely handles cases where connections are already closed or invalid.
%
%   Input:
%       conn - Connection struct from reg.ensure_db with fields:
%              For SQLite: conn.sqlite (sqlite connection handle)
%              For Database Toolbox: conn is the connection object directly
%
%   Example:
%       conn = reg.ensure_db(DB);
%       try
%           reg.upsert_chunks(conn, chunksT, labels, pred, scores);
%       catch ME
%           reg.close_db(conn);
%           rethrow(ME);
%       end
%       reg.close_db(conn);
%
%   See also: ensure_db, upsert_chunks

if isempty(conn)
    return;
end

try
    if isstruct(conn) && isfield(conn, 'sqlite')
        % SQLite connection
        sconn = conn.sqlite;
        if ~isempty(sconn) && isvalid(sconn)
            close(sconn);
        end
    elseif isa(conn, 'database.odbc.connection') || isa(conn, 'database.jdbc.connection')
        % Database Toolbox connection (JDBC or ODBC)
        if isopen(conn)
            close(conn);
        end
    end
catch ME
    % Log warning but don't error - connection may already be closed
    warning('reg:close_db:CloseFailed', ...
        'Failed to close database connection: %s', ME.message);
end
end

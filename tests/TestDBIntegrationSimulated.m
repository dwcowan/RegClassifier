classdef TestDBIntegrationSimulated < matlab.unittest.TestCase
    methods (Test)
        function sqlite_roundtrip(tc)
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            pred = logical(Ytrue); scores = double(Ytrue);
            C = config(); C.db.vendor = 'sqlite'; C.db.sqlite_path = "tests/tmp/sim_reg.sqlite";
            if isfile(C.db.sqlite_path), delete(C.db.sqlite_path); end
            conn = reg.ensure_db(C.db);
            reg.upsert_chunks(conn, chunksT, labels, pred, scores);
            if isstruct(conn) && isfield(conn,'sqlite')
                cur = fetch(conn.sqlite, "SELECT COUNT(*) FROM reg_chunks");
                tc.verifyGreaterThanOrEqual(cur{1}, height(chunksT));
                close(conn.sqlite);
            end
            if isfile(C.db.sqlite_path), delete(C.db.sqlite_path); end
        end
    end
end

classdef TestDBIntegrationSimulated < RegTestCase
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
                colNames = fetch(conn.sqlite, "SELECT name FROM pragma_table_info('reg_chunks');");
                if istable(colNames)
                    names = string(colNames{:,:});
                else
                    names = string(colNames(:,1));
                end
                scoreCol = char("score_" + labels(1));
                tc.verifyTrue(any(names == scoreCol));
                close(conn.sqlite);
            end
            if isfile(C.db.sqlite_path), delete(C.db.sqlite_path); end
        end
    end
end

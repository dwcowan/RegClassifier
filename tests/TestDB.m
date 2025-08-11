classdef TestDB < RegTestCase
    properties
        TempDB
    end
    methods (TestMethodSetup)
        function setupDB(tc)
            C = config();
            % Force sqlite for tests
            C.db.vendor = 'sqlite';
            if isfield(C.db,'sqlite_path'); deleteIfExists(C.db.sqlite_path); end
            tc.TempDB = C.db;
            assignin('base','Cdb',tc.TempDB); %#ok<NASGU>
        end
    end
    methods (TestMethodTeardown)
        function teardownDB(tc)
            if isfield(tc.TempDB,'sqlite_path')
                deleteIfExists(tc.TempDB.sqlite_path);
            end
        end
    end
    methods (Test)
        function test_upsert(tc)
            % Arrange data
            T = table(["CH_1";"CH_2"], ["DOC_1";"DOC_1"], ["IRB PD LGD";"LCR HQLA"], ...
                      'VariableNames', {'chunk_id','doc_id','text'});
            labels = ["IRB","Liquidity_LCR"];
            pred = logical([1 0; 0 1]);
            scores = rand(2, numel(labels));

            conn = reg.ensure_db(tc.TempDB);
            reg.upsert_chunks(conn, T, labels, pred, scores);

            if isstruct(conn) && isfield(conn,'sqlite')
                cur = fetch(conn.sqlite, "SELECT count(*) FROM reg_chunks");
                tc.verifyGreaterThanOrEqual(cur{1}, 2);
                colNames = fetch(conn.sqlite, "SELECT name FROM pragma_table_info(''reg_chunks'');");
                if istable(colNames)
                    names = string(colNames{:,:});
                else
                    names = string(colNames(:,1));
                end
                tc.verifyTrue(any(names == "score_IRB"));
                close(conn.sqlite);
            end
        end
    end
end

function deleteIfExists(p)
try, if isfile(p), delete(p); end, end
end

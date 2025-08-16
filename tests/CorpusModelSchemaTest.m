classdef CorpusModelSchemaTest < matlab.unittest.TestCase
    %CORPUSMODEL SCHEMA TEST Examples of expected output structures for stubs.
    methods (Test)
        function exampleOutputs(testCase)
            % fetchEba / fetchEbaParsed tables
            ebaTbl = table(["Art1";"Art2"],["T1";"T2"], ...
                'VariableNames', {'article','text'});
            testCase.verifyClass(ebaTbl, "table");
            ebaParsedTbl = table(["Art1"], 1, ...
                'VariableNames', {'article','article_num'});
            testCase.verifyClass(ebaParsedTbl, "table");

            % fetchEurlex path
            pdfPath = "data/raw/crr.pdf";
            testCase.verifyClass(pdfPath, "string");

            % sync output struct
            syncOut = struct('eba_dir', "data/eba", ...
                             'eba_index', "data/eba/index.csv");
            testCase.verifyClass(syncOut.eba_dir, "string");

            % queryIndex results table
            results = table(["d1";"d2"],[0.9;0.5],[1;2], ...
                'VariableNames',{'docId','score','rank'});
            testCase.verifyClass(results, "table");

            % runArticles result struct
            artResult = struct('diffTable', table(["1";"2"],[true;false], ...
                'VariableNames', {'article','changed'}));
            testCase.verifyTrue(ismember("diffTable", fieldnames(artResult)));

            % runVersions diff struct
            verDiff = struct('fileDiffs', table(["a";"b"],[10;5], ...
                'VariableNames', {'file','numChanges'}));
            testCase.verifyClass(verDiff.fileDiffs, "table");

            % runReport report struct
            report = struct('pdfPath', "out/report.pdf", ...
                            'htmlPath', "out/report.html");
            testCase.verifyClass(report.htmlPath, "string");

            % runMethods metrics struct
            methodsOut = struct('metrics', table(["m1";"m2"],[0.1;0.2], ...
                'VariableNames', {'method','score'}));
            testCase.verifyClass(methodsOut.metrics, "table");
        end
    end
end

classdef TestPipelineConfig < fixtures.RegTestCase
    methods (TestMethodSetup)
        function backupPipelineConfig(tc)
            % Backup pipeline.json and restore after test
            if isfile('pipeline.json')
                copyfile('pipeline.json', 'pipeline.json.bak');
                tc.addTeardown(@() movefile('pipeline.json.bak', 'pipeline.json'));
            else
                % If pipeline.json doesn't exist, delete it after test
                tc.addTeardown(@() deleteIfExists('pipeline.json'));
            end
        end
    end

    methods (Test)
        function pipeline_overrides(tc)
            % Test that pipeline.json overrides work correctly
            fid = fopen('pipeline.json','w');
            fprintf(fid,'{ "input_dir": "tests/fixtures", "lda_topics": 3 }');
            fclose(fid);
            C = config();
            tc.verifyEqual(C.input_dir, "tests/fixtures", ...
                'Input directory should match pipeline.json override');
            tc.verifyEqual(C.lda_topics, 3, ...
                'LDA topics should match pipeline.json override');
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end

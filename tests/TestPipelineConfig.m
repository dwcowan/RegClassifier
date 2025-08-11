classdef TestPipelineConfig < RegTestCase
    methods (Test)
        function pipeline_overrides(tc)
            orig = fileread('pipeline.json');
            fid = fopen('pipeline.json','w');
            fprintf(fid,'{ "input_dir": "tests/fixtures", "lda_topics": 3 }');
            fclose(fid);
            C = config();
            tc.verifyEqual(C.input_dir, "tests/fixtures");
            tc.verifyEqual(C.lda_topics, 3);
            fid = fopen('pipeline.json','w');
            fwrite(fid, orig);
            fclose(fid);
        end
    end
end

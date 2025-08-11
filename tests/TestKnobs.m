classdef TestKnobs < matlab.unittest.TestCase
    methods (Test)
        function chunk_overrides(tc)
            % Write a temporary knobs.json overriding chunk sizes
            fid = fopen('knobs.json','w'); fprintf(fid,'{ "Chunk": { "SizeTokens": 123, "Overlap": 45 } }'); fclose(fid);
            C = config();
            tc.verifyEqual(C.chunk_size_tokens, 123);
            tc.verifyEqual(C.chunk_overlap, 45);
            delete('knobs.json');
        end
    end
end

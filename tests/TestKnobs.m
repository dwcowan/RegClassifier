classdef TestKnobs < RegTestCase
    methods (TestMethodSetup)
        function backupConfig(tc)
            % Backup knobs.json if it exists and restore it after test
            if isfile('knobs.json')
                copyfile('knobs.json', 'knobs.json.bak');
                tc.addTeardown(@() movefile('knobs.json.bak', 'knobs.json'));
            else
                % If knobs.json doesn't exist initially, delete it after test
                tc.addTeardown(@() deleteIfExists('knobs.json'));
            end
        end
    end

    methods (Test)
        function chunk_overrides(tc)
            % Write a temporary knobs.json overriding chunk sizes
            fid = fopen('knobs.json','w');
            fprintf(fid,'{ "Chunk": { "SizeTokens": 123, "Overlap": 45 } }');
            fclose(fid);
            C = config();
            tc.verifyEqual(C.chunk_size_tokens, 123, ...
                'Chunk size tokens should match knobs.json override');
            tc.verifyEqual(C.chunk_overlap, 45, ...
                'Chunk overlap should match knobs.json override');
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end

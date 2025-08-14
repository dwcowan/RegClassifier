classdef TestSyncController < RegTestCase
    %TESTSYNCCONTROLLER Verify SyncController interface and outputs.
    methods(Test)
        function runProducesFiles(tc)
            view = reg.view.ReportView();
            ctrl = reg.controller.SyncController(view, @syncStub);
            result = ctrl.run('20250101');
            tc.verifyTrue(isfile(result.pdf));
            tc.verifyTrue(isfolder(result.eba_dir));
            tc.verifyTrue(isfile(result.eba_index));
            tc.verifyEqual(view.DisplayedData, result);
        end
    end
end

function out = syncStub(varargin)
    p = inputParser;
    addParameter(p, 'Date', '');
    parse(p, varargin{:});
    tmp = tempname;
    mkdir(tmp);
    pdfPath = fullfile(tmp, ['crr_' p.Results.Date '.pdf']);
    fid = fopen(pdfPath, 'w');
    fwrite(fid, 'PDF');
    fclose(fid);
    ebaDir = fullfile(tmp, 'eba');
    mkdir(ebaDir);
    idx = fullfile(ebaDir, 'index.csv');
    fid = fopen(idx, 'w');
    fclose(fid);
    out = struct('pdf', pdfPath, 'eba_dir', ebaDir, 'eba_index', idx);
end

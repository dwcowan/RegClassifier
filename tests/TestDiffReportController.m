classdef TestDiffReportController < RegTestCase
    %TESTDIFFREPORTCONTROLLER Verify diff report generation writes artifacts.

    properties
        WorkFolder
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
            tc.WorkFolder = pwd;
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.WorkFolder = [];
        end
    end

    methods(Test)
        function generatesReport(tc)
            tc.assumeTrue(exist('mlreportgen.report.Report','class') == 8, ...
                'Requires MATLAB Report Generator');
            dirA = fullfile(tc.WorkFolder,'A');
            dirB = fullfile(tc.WorkFolder,'B');
            mkdir(dirA); mkdir(dirB);
            writelines("foo", fullfile(dirA,'f.txt'));
            writelines("bar", fullfile(dirB,'f.txt'));
            outDir = fullfile(tc.WorkFolder,'out');
            reg_crr_diff_report(dirA, dirB, 'OutDir', outDir);
            tc.verifyTrue(isfile(fullfile(outDir,'crr_diff_report.pdf')));
            tc.verifyTrue(isfile(fullfile(outDir,'summary.csv')));
            tc.verifyTrue(isfile(fullfile(outDir,'patch.txt')));
        end
    end
end


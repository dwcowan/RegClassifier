classdef TestDiffReportController < fixtures.RegTestCase

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

        function generatesHtmlReport(tc)
            %GENERATESHTMLREPORT Verify HTML diff report generation.
            % Tests reg_crr_diff_report_html which requires index.csv
            % from fetch_crr_eba_parsed output format.
            tc.assumeTrue(exist('mlreportgen.report.Report','class') == 8, ...
                'Requires MATLAB Report Generator');

            dirA = fullfile(tc.WorkFolder,'HA');
            dirB = fullfile(tc.WorkFolder,'HB');
            mkdir(dirA); mkdir(dirB);

            % Create index.csv files (fetch_crr_eba_parsed output format)
            tA = table("Art1", "Title A1", "a1.html", "http://a/1", ...
                'VariableNames', {'article_num','title','html_file','url'});
            tB = table("Art1", "Title B1", "a1.html", "http://b/1", ...
                'VariableNames', {'article_num','title','html_file','url'});
            writetable(tA, fullfile(dirA,'index.csv'));
            writetable(tB, fullfile(dirB,'index.csv'));

            % Create corresponding text files (matched to html_file stem)
            writelines("article one version A", fullfile(dirA,'a1.txt'));
            writelines("article one version B changed", fullfile(dirB,'a1.txt'));

            outDir = fullfile(tc.WorkFolder,'html_out');
            reg_crr_diff_report_html(dirA, dirB, 'OutDir', outDir);
            tc.verifyTrue(isfile(fullfile(outDir,'crr_diff_report.html')));
            tc.verifyTrue(isfile(fullfile(outDir,'summary_by_article.csv')));
        end
    end
end


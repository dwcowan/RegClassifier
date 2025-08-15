classdef DiffModel < reg.mvc.BaseModel
    %DIFFMODEL Unified model for diff workflows.
    %   Provides convenience methods to diff articles, versions, generate
    %   reports and compare retrieval methods.

    methods
        function result = diffArticles(~, dirA, dirB, outDir)
            %DIFFARTICLES Compare corpora by article number.
            %   RESULT = DIFFARTICLES(obj, dirA, dirB, outDir) should align
            %   documents by article identifiers and compute differences.
            %   Legacy Reference
            %       Equivalent to `reg.crr_diff_articles`.
            error("reg:model:NotImplemented", ...
                "DiffModel.diffArticles is not implemented.");
        end

        function diff = diffVersions(~, dirA, dirB, outDir)
            %DIFFVERSIONS Compute file-level diffs between directories.
            %   DIFF = DIFFVERSIONS(obj, dirA, dirB, outDir) should compare
            %   file versions and report line-level changes.
            %   Legacy Reference
            %       Equivalent to `reg.crr_diff_versions`.
            error("reg:model:NotImplemented", ...
                "DiffModel.diffVersions is not implemented.");
        end

        function report = generateReport(~, dirA, dirB, outDir)
            %GENERATEREPORT Produce diff reports for two directories.
            %   REPORT = GENERATEREPORT(obj, dirA, dirB, outDir) should
            %   generate PDF and HTML artifacts summarising differences.
            %   Legacy Reference
            %       Equivalent to `reg_crr_diff_report` and
            %       `reg_crr_diff_report_html`.
            error("reg:model:NotImplemented", ...
                "DiffModel.generateReport is not implemented.");
        end

        function result = diffMethods(~, queries, chunksT, config)
            %DIFFMETHODS Compare retrieval across encoder variants.
            %   RESULT = DIFFMETHODS(obj, queries, chunksT, config) should
            %   evaluate alternative embedding methods on QUERY strings
            %   against CHUNKST table. CONFIG defaults to an empty struct.
            if nargin < 4
                config = struct();
            end %#ok<NASGU>
            error("reg:model:NotImplemented", ...
                "DiffModel.diffMethods is not implemented.");
        end
    end
end


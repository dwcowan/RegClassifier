classdef DiffVersionsController < reg.mvc.BaseController
    %DIFFVERSIONSCONTROLLER File-level diff of two CRR corpora.
    %   Wraps `crr_diff_versions` and exposes a simple controller interface
    %   for comparing two directories of plain text files.

    properties
        DiffFunction
    end

    methods
        function obj = DiffVersionsController(view, diffFunc)
            %DIFFVERSIONSCONTROLLER Construct controller with diff function.
            %   OBJ = DIFFVERSIONSCONTROLLER(view, diffFunc) wires a view
            %   and diff function. VIEW defaults to `reg.view.ReportView`
            %   and DIFFFUNC defaults to `@reg.crr_diff_versions`.
            if nargin < 1 || isempty(view)
                view = reg.view.ReportView();
            end
            if nargin < 2 || isempty(diffFunc)
                diffFunc = @reg.crr_diff_versions;
            end
            obj@reg.mvc.BaseController([], view);
            obj.DiffFunction = diffFunc;
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Diff directories on a file-by-file basis.
            %   RESULT = RUN(obj, dirA, dirB, outDir) aligns plain text
            %   files by name, records line-level changes and writes a CSV
            %   summary plus a patch file.
            %   Inputs
            %       dirA, dirB (char/string): Directories containing `.txt`
            %           files for comparison.
            %       outDir (char/string): Optional output directory for
            %           artefacts. Default runs/crr_diff.
            %   Returns
            %       result (struct): Counts of added, removed, changed and
            %       same files plus the output directory.
            %   Errors
            %       * Propagates errors from the diff function such as
            %         unreadable files.
            %       * Directory creation failures raise exceptions.
            if nargin < 4 || isempty(outDir)
                outDir = fullfile('runs', 'crr_diff');
            end
            result = obj.DiffFunction(dirA, dirB, 'OutDir', outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end


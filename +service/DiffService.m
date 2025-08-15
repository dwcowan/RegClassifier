classdef DiffService
    %DIFFSERVICE Compute article-level differences between corpora.
    %   Hosts transformation logic previously in DiffArticlesModel.

    methods
        function diff = compare(~, dirA, dirB, outDir) %#ok<INUSD>
            %COMPARE Align articles from DIRA and DIRB and summarize results.
            %   DIFF = COMPARE(DIRA, DIRB, OUTDIR) should return a
            %   `reg.model.CorpusDiff` describing differences.
            %   Legacy Reference
            %       Equivalent to `reg.crr_diff_articles`.
            error("reg:service:NotImplemented", ...
                "DiffService.compare is not implemented.");
        end
    end
end

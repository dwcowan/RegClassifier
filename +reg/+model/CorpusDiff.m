classdef CorpusDiff
    %CORPUSDIFF Domain entity summarizing differences between corpora.
    %   Captures the input directories and optional diff statistics.

    properties
        DirA string = ""
        DirB string = ""
        OutDir string = ""
        Summary struct = struct()
    end

    methods
        function obj = CorpusDiff(dirA, dirB, outDir, summary)
            %CORPUSDIFF Construct diff summary object.
            %   OBJ = CORPUSDIFF(dirA, dirB, outDir, summary) stores
            %   provenance of the comparison and an optional SUMMARY struct.
            if nargin >= 1, obj.DirA = dirA; end
            if nargin >= 2, obj.DirB = dirB; end
            if nargin >= 3, obj.OutDir = outDir; end
            if nargin >= 4, obj.Summary = summary; end
        end
    end
end
